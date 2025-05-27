import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/game_action.dart';
import '../models/match.dart';
import '../view_models/live_game_view_model.dart';
import '../../player/models/player.dart';
import '../../player/view_models/players_view_model.dart';

class LiveStatsScreen extends ConsumerStatefulWidget {
  final String teamId;
  final String teamName;
  final String? matchId;

  const LiveStatsScreen({
    super.key,
    required this.teamId,
    required this.teamName,
    this.matchId,
  });

  @override
  ConsumerState<LiveStatsScreen> createState() => _LiveStatsScreenState();
}

class _LiveStatsScreenState extends ConsumerState<LiveStatsScreen> {
  late Match currentMatch;
  bool isSelectingPlayer = false;
  ActionType? selectedActionType;
  bool isSelectingHomeTeam = true;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMatch();
    });
  }

  Future<void> _setupMatch() async {
    // Set the current quarter to 1 by default
    ref.read(currentQuarterProvider.notifier).state = 1;
    
    // If we have a match ID, load the existing match
    if (widget.matchId != null) {
      // TODO: Load the existing match data
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMatch = ref.watch(currentLiveMatchProvider);
    final currentQuarter = ref.watch(currentQuarterProvider);
    final actions = ref.watch(currentMatchActionsProvider);
    final (homeScore, awayScore) = ref.watch(currentScoreProvider);
    final players = ref.watch(playersProvider)
        .where((player) => player.teamId == widget.teamId)
        .toList();

    // Sort actions by timestamp (newest first)
    final sortedActions = [...actions];
    sortedActions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (currentMatch == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Game Stats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Score display
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        currentMatch.homeTeamName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Text(
                      'vs',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currentMatch.awayTeamName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        homeScore.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    const Text(
                      '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        awayScore.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Quarter: $currentQuarter',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Game actions log
          Expanded(
            child: sortedActions.isEmpty
                ? const Center(child: Text('No actions recorded yet'))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: sortedActions.length,
                    itemBuilder: (context, index) {
                      final action = sortedActions[index];
                      return _buildActionItem(action);
                    },
                  ),
          ),

          // Conditional display based on current selection state
          if (isSelectingPlayer)
            _buildPlayerSelectionPanel(players)
          else
            _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionItem(GameAction action) {
    final teamName = action.isHomeTeam
        ? ref.read(currentLiveMatchProvider)?.homeTeamName ?? 'Home'
        : ref.read(currentLiveMatchProvider)?.awayTeamName ?? 'Away';
    
    final timeString = '${action.timestamp.hour}:${action.timestamp.minute.toString().padLeft(2, '0')}';
    
    String actionText;
    IconData? actionIcon;
    
    switch (action.type) {
      case ActionType.point:
        actionText = '${action.playerName ?? 'Player'} (${action.playerNumber ?? '?'}) scored 2 points';
        actionIcon = Icons.sports_basketball;
        break;
      case ActionType.threePoint:
        actionText = '${action.playerName ?? 'Player'} (${action.playerNumber ?? '?'}) scored 3 points';
        actionIcon = Icons.filter_3;
        break;
      case ActionType.foul:
        actionText = '${action.playerName ?? 'Player'} (${action.playerNumber ?? '?'}) committed a foul';
        actionIcon = Icons.flag;
        break;
      case ActionType.turnover:
        actionText = '${action.playerName ?? 'Player'} (${action.playerNumber ?? '?'}) turnover';
        actionIcon = Icons.sync_problem;
        break;
      case ActionType.rebound:
        actionText = '${action.playerName ?? 'Player'} (${action.playerNumber ?? '?'}) rebound';
        actionIcon = Icons.vertical_align_bottom;
        break;
      case ActionType.steal:
        actionText = '${action.playerName ?? 'Player'} (${action.playerNumber ?? '?'}) steal';
        actionIcon = Icons.pan_tool;
        break;
      case ActionType.block:
        actionText = '${action.playerName ?? 'Player'} (${action.playerNumber ?? '?'}) block';
        actionIcon = Icons.block;
        break;
      case ActionType.assist:
        actionText = '${action.playerName ?? 'Player'} (${action.playerNumber ?? '?'}) assist';
        actionIcon = Icons.handshake;
        break;
      case ActionType.endQuarter:
        actionText = 'End of Quarter ${action.quarter}';
        actionIcon = Icons.timer;
        break;
    }
    
    return ListTile(
      leading: Icon(actionIcon),
      title: Text(actionText),
      subtitle: Text('$teamName • Q${action.quarter} • $timeString'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _deleteAction(action.id),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                ActionType.point,
                Icons.sports_basketball,
                '2 Points',
              ),
              _actionButton(
                ActionType.threePoint,
                Icons.filter_3,
                '3 Points',
              ),
              _actionButton(
                ActionType.foul,
                Icons.flag,
                'Foul',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                ActionType.rebound,
                Icons.vertical_align_bottom,
                'Rebound',
              ),
              _actionButton(
                ActionType.steal,
                Icons.pan_tool,
                'Steal',
              ),
              _actionButton(
                ActionType.assist,
                Icons.handshake,
                'Assist',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.timer),
                label: const Text('End Quarter'),
                onPressed: _endQuarter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.switch_account),
                label: Text(
                  ref.read(currentLiveMatchProvider)?.homeTeamId == widget.teamId
                      ? 'Enemy Team'
                      : 'Home Team',
                ),
                onPressed: _toggleTeam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelectingHomeTeam
                      ? Colors.blue
                      : Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(ActionType type, IconData icon, String label) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () => _selectAction(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildPlayerSelectionPanel(List<Player> players) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Select Player for ${_getActionTypeString(selectedActionType!)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return InkWell(
                  onTap: () => _selectPlayer(player),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '#${player.number}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          player.name.split(' ').first,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
                onPressed: _cancelAction,
              ),
              if (!isSelectingHomeTeam)
                TextButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Opponent Player'),
                  onPressed: _selectOpponentPlayer,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectAction(ActionType type) {
    setState(() {
      selectedActionType = type;
      isSelectingPlayer = true;
    });
  }

  void _selectPlayer(Player player) {
    if (selectedActionType != null) {
      final currentMatch = ref.read(currentLiveMatchProvider);
      final currentQuarter = ref.read(currentQuarterProvider);
      
      if (currentMatch != null) {
        final action = GameAction(
          matchId: currentMatch.id,
          type: selectedActionType!,
          playerId: player.id,
          playerName: player.name,
          playerNumber: player.number,
          teamId: player.teamId,
          isHomeTeam: isSelectingHomeTeam,
          quarter: currentQuarter,
          timestamp: DateTime.now(),
        );
        
        ref.read(gameActionsProvider.notifier).addAction(action);
        
        setState(() {
          selectedActionType = null;
          isSelectingPlayer = false;
        });
        
        _scrollToBottom();
      }
    }
  }

  void _selectOpponentPlayer() {
    // A simplified opponent player selection for demonstration
    showDialog(
      context: context,
      builder: (context) {
        String playerNumber = '';
        
        return AlertDialog(
          title: const Text('Opponent Player'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Player Number'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              playerNumber = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                
                if (playerNumber.isNotEmpty) {
                  final currentMatch = ref.read(currentLiveMatchProvider);
                  final currentQuarter = ref.read(currentQuarterProvider);
                  
                  if (currentMatch != null && selectedActionType != null) {
                    final action = GameAction(
                      matchId: currentMatch.id,
                      type: selectedActionType!,
                      playerName: 'Opponent',
                      playerNumber: int.tryParse(playerNumber) ?? 0,
                      teamId: currentMatch.awayTeamId,
                      isHomeTeam: isSelectingHomeTeam,
                      quarter: currentQuarter,
                      timestamp: DateTime.now(),
                    );
                    
                    ref.read(gameActionsProvider.notifier).addAction(action);
                    
                    setState(() {
                      selectedActionType = null;
                      isSelectingPlayer = false;
                    });
                    
                    _scrollToBottom();
                  }
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _cancelAction() {
    setState(() {
      selectedActionType = null;
      isSelectingPlayer = false;
    });
  }

  void _toggleTeam() {
    setState(() {
      isSelectingHomeTeam = !isSelectingHomeTeam;
    });
  }

  void _endQuarter() {
    final currentMatch = ref.read(currentLiveMatchProvider);
    final currentQuarter = ref.read(currentQuarterProvider);
    
    if (currentMatch != null) {
      // Add end quarter action
      final action = GameAction(
        matchId: currentMatch.id,
        type: ActionType.endQuarter,
        teamId: widget.teamId,
        isHomeTeam: true, // Doesn't matter for end quarter
        quarter: currentQuarter,
        timestamp: DateTime.now(),
      );
      
      ref.read(gameActionsProvider.notifier).addAction(action);
      
      // Increment quarter
      ref.read(currentQuarterProvider.notifier).state = currentQuarter + 1;
      
      _scrollToBottom();
    }
  }

  void _deleteAction(String actionId) {
    ref.read(gameActionsProvider.notifier).removeAction(actionId);
  }

  Future<void> _saveGame() async {
    final currentMatch = ref.read(currentLiveMatchProvider);
    final (homeScore, awayScore) = ref.read(currentScoreProvider);
    
    if (currentMatch != null) {
      final liveGameManager = ref.read(liveGameManagerProvider);
      
      await liveGameManager.saveMatchFromLiveStats(
        matchId: currentMatch.id,
        homeTeamId: currentMatch.homeTeamId,
        homeTeamName: currentMatch.homeTeamName,
        awayTeamId: currentMatch.awayTeamId,
        awayTeamName: currentMatch.awayTeamName,
        leagueId: currentMatch.leagueId,
        homeScore: homeScore,
        awayScore: awayScore,
        location: currentMatch.location,
        notes: currentMatch.notes,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game saved successfully')),
        );
        
        // Go back to the previous screen
        if (context.canPop()) {
          context.pop();
        }
      }
    }
  }

  String _getActionTypeString(ActionType type) {
    switch (type) {
      case ActionType.point:
        return '2 Points';
      case ActionType.threePoint:
        return '3 Points';
      case ActionType.foul:
        return 'Foul';
      case ActionType.turnover:
        return 'Turnover';
      case ActionType.rebound:
        return 'Rebound';
      case ActionType.steal:
        return 'Steal';
      case ActionType.block:
        return 'Block';
      case ActionType.assist:
        return 'Assist';
      case ActionType.endQuarter:
        return 'End Quarter';
    }
  }
}
