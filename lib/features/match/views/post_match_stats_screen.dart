import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/player_stats.dart';
import '../models/player_stats_repository.dart';
import '../models/game_match.dart';
import '../models/match_repository.dart';
import '../../player/models/player.dart';
import '../../player/models/player_repository.dart';

/// Screen for manual post-match statistics entry
class PostMatchStatsScreen extends ConsumerStatefulWidget {
  final String matchId;
  final String teamId;
  final String leagueId;

  const PostMatchStatsScreen({
    super.key,
    required this.matchId,
    required this.teamId,
    required this.leagueId,
  });

  @override
  ConsumerState<PostMatchStatsScreen> createState() =>
      _PostMatchStatsScreenState();
}

class _PostMatchStatsScreenState extends ConsumerState<PostMatchStatsScreen> {
  final _formKey = GlobalKey<FormState>();
  late GameMatch match;

  // Controllers for adding new player
  final _newPlayerNameController = TextEditingController();
  final _newPlayerNumberController = TextEditingController();

  // Data for player being edited
  int _editingPoints = 0;
  int _editingAssists = 0;
  int _editingMinutes = 0;

  // Track selected player
  Player? _selectedPlayer;
  bool _isAddingNewPlayer = false;

  @override
  void dispose() {
    _newPlayerNameController.dispose();
    _newPlayerNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMatches = ref.watch(matchesProvider);

    try {
      match = allMatches.firstWhere((m) => m.id == widget.matchId);
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post-Match Stats')),
        body: const Center(child: Text('Match not found')),
      );
    }

    final playerStats = ref.watch(playerStatsByMatchProvider(widget.matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post-Match Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('DONE')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match header
            Text(
              '${match.homeTeamName} vs ${match.awayTeamName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Score: ${match.homeTeamScore} - ${match.awayTeamScore}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),

            // Stats table
            Expanded(
              child:
                  playerStats.isEmpty
                      ? Center(
                        child: Text(
                          'No player statistics recorded yet',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                      : _buildStatsTable(playerStats),
            ),

            // Add player button
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddPlayerDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Player Stats'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTable(List<PlayerStats> playerStats) {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Player')),
            DataColumn(label: Text('PTS')),
            DataColumn(label: Text('AST')),
            DataColumn(label: Text('MIN')),
            DataColumn(label: Text('Actions')),
          ],
          rows:
              playerStats.map((stat) {
                return DataRow(
                  cells: [
                    DataCell(Text('${stat.playerNumber}')),
                    DataCell(Text(stat.playerName)),
                    DataCell(Text('${stat.points}')),
                    DataCell(Text('${stat.assists}')),
                    DataCell(Text('${stat.minutes}')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed:
                                () => _showEditStatsDialog(context, stat),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _deletePlayerStats(stat),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    // Reset state
    setState(() {
      _selectedPlayer = null;
      _isAddingNewPlayer = false;
      _newPlayerNameController.clear();
      _newPlayerNumberController.clear();
      _editingPoints = 0;
      _editingAssists = 0;
      _editingMinutes = 0;
    });

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              final teamPlayers = ref.watch(
                playersByTeamProvider(widget.teamId),
              );

              return AlertDialog(
                title: const Text('Add Player Statistics'),
                content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Player selection section
                        if (!_isAddingNewPlayer && teamPlayers.isNotEmpty) ...[
                          DropdownButtonFormField<Player>(
                            decoration: const InputDecoration(
                              labelText: 'Select Player',
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Select a player'),
                            value: _selectedPlayer,
                            items:
                                teamPlayers.map((player) {
                                  return DropdownMenuItem<Player>(
                                    value: player,
                                    child: Text(
                                      '#${player.number} ${player.name}',
                                    ),
                                  );
                                }).toList(),
                            onChanged: (player) {
                              setDialogState(() {
                                _selectedPlayer = player;
                              });
                            },
                            validator:
                                _isAddingNewPlayer
                                    ? null
                                    : (value) {
                                      if (value == null) {
                                        return 'Please select a player';
                                      }
                                      return null;
                                    },
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                _isAddingNewPlayer = true;
                                _selectedPlayer = null;
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Player Instead'),
                          ),
                        ],

                        // New player form
                        if (_isAddingNewPlayer || teamPlayers.isEmpty) ...[
                          if (teamPlayers.isNotEmpty) ...[
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  _isAddingNewPlayer = false;
                                });
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back to Player Selection'),
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _newPlayerNameController,
                            decoration: const InputDecoration(
                              labelText: 'Player Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_isAddingNewPlayer &&
                                  (value == null || value.isEmpty)) {
                                return 'Please enter player name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newPlayerNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Jersey Number',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (_isAddingNewPlayer) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter jersey number';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                              }
                              return null;
                            },
                          ),
                        ],

                        // Game statistics section
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Game Statistics',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Player info if selected
                        if (_selectedPlayer != null) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '#${_selectedPlayer!.number}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedPlayer!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _selectedPlayer!.position.displayName,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Points
                        Row(
                          children: [
                            const Text('Points: '),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed:
                                  _editingPoints > 0
                                      ? () =>
                                          setDialogState(() => _editingPoints--)
                                      : null,
                            ),
                            Text('$_editingPoints'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed:
                                  () => setDialogState(() => _editingPoints++),
                            ),
                          ],
                        ),

                        // Assists
                        Row(
                          children: [
                            const Text('Assists: '),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed:
                                  _editingAssists > 0
                                      ? () => setDialogState(
                                        () => _editingAssists--,
                                      )
                                      : null,
                            ),
                            Text('$_editingAssists'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed:
                                  () => setDialogState(() => _editingAssists++),
                            ),
                          ],
                        ),

                        // Minutes
                        Row(
                          children: [
                            const Text('Minutes: '),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed:
                                  _editingMinutes > 0
                                      ? () => setDialogState(
                                        () => _editingMinutes--,
                                      )
                                      : null,
                            ),
                            Text('$_editingMinutes'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed:
                                  () => setDialogState(() => _editingMinutes++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_isAddingNewPlayer) {
                          await _addNewPlayerAndStats();
                        } else if (_selectedPlayer != null) {
                          await _addStatsForExistingPlayer(_selectedPlayer!);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('ADD'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showEditStatsDialog(BuildContext context, PlayerStats playerStats) {
    // Set the editing values to the current player stats
    _editingPoints = playerStats.points;
    _editingAssists = playerStats.assists;
    _editingMinutes = playerStats.minutes;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Edit Stats: ${playerStats.playerName}'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Points
                      Row(
                        children: [
                          const Text('Points: '),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed:
                                _editingPoints > 0
                                    ? () => setState(() => _editingPoints--)
                                    : null,
                          ),
                          Text('$_editingPoints'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => _editingPoints++),
                          ),
                        ],
                      ),

                      // Assists
                      Row(
                        children: [
                          const Text('Assists: '),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed:
                                _editingAssists > 0
                                    ? () => setState(() => _editingAssists--)
                                    : null,
                          ),
                          Text('$_editingAssists'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => _editingAssists++),
                          ),
                        ],
                      ),

                      // Minutes
                      Row(
                        children: [
                          const Text('Minutes: '),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed:
                                _editingMinutes > 0
                                    ? () => setState(() => _editingMinutes--)
                                    : null,
                          ),
                          Text('$_editingMinutes'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => _editingMinutes++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () {
                      _updatePlayerStats(playerStats);
                      Navigator.pop(context);
                    },
                    child: const Text('SAVE'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _addNewPlayerAndStats() async {
    final playerRepository = ref.read(playerRepositoryProvider);
    final statsRepository = ref.read(playerStatsRepositoryProvider);

    final playerName = _newPlayerNameController.text;
    final playerNumber = int.parse(_newPlayerNumberController.text);

    // Create and add the new player to the team
    final newPlayer = Player(
      name: playerName,
      number: playerNumber,
      position: PlayerPosition.smallForward, // Default position
      teamId: widget.teamId,
    );

    await playerRepository.addPlayer(newPlayer);

    // Add stats for the new player
    final newStats = PlayerStats(
      matchId: widget.matchId,
      playerId: newPlayer.id,
      playerName: newPlayer.name,
      playerNumber: newPlayer.number,
      points: _editingPoints,
      assists: _editingAssists,
      minutes: _editingMinutes,
      teamId: widget.teamId,
    );

    await statsRepository.addPlayerStats(newStats);

    // Invalidate the cached data to force a refresh
    ref.invalidate(playerStatsByMatchProvider(widget.matchId));

    setState(() {});
  }

  Future<void> _addStatsForExistingPlayer(Player player) async {
    final repository = ref.read(playerStatsRepositoryProvider);

    final newStats = PlayerStats(
      matchId: widget.matchId,
      playerId: player.id,
      playerName: player.name,
      playerNumber: player.number,
      points: _editingPoints,
      assists: _editingAssists,
      minutes: _editingMinutes,
      teamId: widget.teamId,
    );

    await repository.addPlayerStats(newStats);

    // Invalidate the cached data to force a refresh
    ref.invalidate(playerStatsByMatchProvider(widget.matchId));

    setState(() {});
  }

  void _updatePlayerStats(PlayerStats playerStats) {
    final repository = ref.read(playerStatsRepositoryProvider);

    final updatedStats = playerStats.copyWith(
      points: _editingPoints,
      assists: _editingAssists,
      minutes: _editingMinutes,
    );

    repository.updatePlayerStats(updatedStats);
    setState(() {});
  }

  void _deletePlayerStats(PlayerStats playerStats) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Player Stats'),
            content: Text(
              'Are you sure you want to delete stats for ${playerStats.playerName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  final repository = ref.read(playerStatsRepositoryProvider);
                  repository.deletePlayerStats(playerStats.id);
                  Navigator.pop(context);
                  setState(() {});
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }
}
