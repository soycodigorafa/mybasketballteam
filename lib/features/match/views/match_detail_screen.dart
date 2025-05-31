import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import models using our export file to avoid naming conflicts
import '../models/models.dart';

// Repositories - centralized in core
import '../../../core/services/repositories/repositories.dart';

// Providers (formerly view_models)
import '../providers/matches_providers.dart';

/// Screen that displays detailed match information
class MatchDetailScreen extends ConsumerWidget {
  final String matchId;
  final String leagueId;
  final String teamId;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
    required this.leagueId,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the matchesProvider to find the match by ID
    final allMatches = ref.watch(matchesProvider);
    late final GameMatch match;

    try {
      match = allMatches.firstWhere((m) => m.id == matchId);
    } catch (e) {
      // Match not found
      return Scaffold(
        appBar: AppBar(title: const Text('Match Details')),
        body: const Center(child: Text('Match not found')),
      );
    }

    // We'll assume league data is available through some provider
    // For now, just use a null value since we're focusing on player stats
    final league = null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editMatch(context, ref, match),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteMatch(context, ref, match),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(
            'postMatchStats',
            pathParameters: {
              'teamId': teamId,
              'leagueId': leagueId,
              'matchId': matchId,
            },
          );
        },
        icon: const Icon(Icons.sports_basketball),
        label: const Text('Add Stats'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // League name
                      if (league != null)
                        Text(
                          league.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                      const SizedBox(height: 16),

                      // Teams and score
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  match.homeTeamName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  match.homeTeamScore.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'VS',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  match.awayTeamName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  match.awayTeamScore.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Result text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: _getResultColor(match, teamId),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          _getResultText(match, teamId),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Match details card
              Card(
                child: Column(
                  children: [
                    // Date
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date'),
                      subtitle: Text(_formatDate(match.date)),
                    ),

                    // Location
                    if (match.location != null && match.location!.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Location'),
                        subtitle: Text(match.location!),
                      ),

                    // Notes
                    if (match.notes != null && match.notes!.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.notes),
                        title: const Text('Notes'),
                        subtitle: Text(match.notes!),
                      ),

                    // Player Stats Section
                    const SizedBox(height: 16),
                    PlayerStatsSection(matchId: matchId, ref: ref),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getResultText(GameMatch match, String teamId) {
    bool isHomeTeam = match.homeTeamId == teamId;
    bool isAwayTeam = match.awayTeamId == teamId;

    if (!isHomeTeam && !isAwayTeam) {
      // For matches where the user's team is not involved
      if (match.homeTeamScore > match.awayTeamScore) {
        return 'Home team won';
      } else if (match.homeTeamScore < match.awayTeamScore) {
        return 'Away team won';
      } else {
        return 'Draw';
      }
    }

    // For matches involving the user's team
    if (isHomeTeam) {
      if (match.homeTeamScore > match.awayTeamScore) {
        return 'Victory!';
      } else if (match.homeTeamScore < match.awayTeamScore) {
        return 'Defeat';
      } else {
        return 'Draw';
      }
    } else {
      if (match.awayTeamScore > match.homeTeamScore) {
        return 'Victory!';
      } else if (match.awayTeamScore < match.homeTeamScore) {
        return 'Defeat';
      } else {
        return 'Draw';
      }
    }
  }

  Color _getResultColor(GameMatch match, String teamId) {
    bool isHomeTeam = match.homeTeamId == teamId;
    bool isAwayTeam = match.awayTeamId == teamId;

    if (!isHomeTeam && !isAwayTeam) {
      return Colors.grey; // Neutral color for non-team matches
    }

    if (isHomeTeam) {
      if (match.homeTeamScore > match.awayTeamScore) {
        return Colors.green; // Win
      } else if (match.homeTeamScore < match.awayTeamScore) {
        return Colors.red; // Loss
      } else {
        return Colors.amber; // Draw
      }
    } else {
      if (match.awayTeamScore > match.homeTeamScore) {
        return Colors.green; // Win
      } else if (match.awayTeamScore < match.homeTeamScore) {
        return Colors.red; // Loss
      } else {
        return Colors.amber; // Draw
      }
    }
  }

  void _editMatch(BuildContext context, WidgetRef ref, GameMatch match) async {
    // Navigate to edit match screen
    // This would be implemented in a similar way to the AddMatchScreen
    // For now we'll show a simple dialog for demonstration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit match functionality coming soon')),
    );
  }

  void _confirmDeleteMatch(
    BuildContext context,
    WidgetRef ref,
    GameMatch match,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Match'),
          content: const Text(
            'Are you sure you want to delete this match? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                _deleteMatch(context, ref, match);
                Navigator.of(context).pop();
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMatch(
    BuildContext context,
    WidgetRef ref,
    GameMatch match,
  ) async {
    await ref.read(matchesViewModelProvider.notifier).deleteMatch(match.id);

    if (context.mounted) {
      // Navigate back to the league screen
      context.pop();
    }
  }
}

/// Widget that displays player statistics for a match
class PlayerStatsSection extends StatelessWidget {
  final String matchId;
  final WidgetRef ref;

  const PlayerStatsSection({
    super.key,
    required this.matchId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize sample data if none exists
    _initSamplePlayerStats(ref, matchId);

    // Get player stats for this match
    final playerStats = ref.watch(playerStatsByMatchProvider(matchId));

    // Get match details to determine team IDs
    final allMatches = ref.watch(matchesProvider);
    final match = allMatches.firstWhere((m) => m.id == matchId);

    if (playerStats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No player statistics available for this match'),
          ),
        ),
      );
    }

    // Split stats by team
    final homeTeamStats =
        playerStats.where((stats) => stats.teamId == match.homeTeamId).toList();
    final awayTeamStats =
        playerStats.where((stats) => stats.teamId == match.awayTeamId).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab bar
          Container(
            color: Colors.black,
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: match.homeTeamName.toUpperCase()),
                Tab(text: match.awayTeamName.toUpperCase()),
                const Tab(text: 'HISTORIAL'),
              ],
            ),
          ),

          // Tab content
          SizedBox(
            height: 500, // Fixed height for the tab content
            child: TabBarView(
              children: [
                // Home team stats
                TeamStatsView(
                  title: 'Home Team',
                  playerStats: homeTeamStats,
                  matchId: matchId,
                  ref: ref,
                ),
                // Away team stats
                TeamStatsView(
                  title: 'Away Team',
                  playerStats: awayTeamStats,
                  matchId: matchId,
                  ref: ref,
                ),
                // Game history timeline
                GameHistoryTimeline(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Initializes sample player stats for the match if none exist
  void _initSamplePlayerStats(WidgetRef ref, String matchId) {
    // Check if we already have player stats for this match
    final existingStats = ref.read(playerStatsByMatchProvider(matchId));
    if (existingStats.isNotEmpty) return;

    // Get match details to determine team IDs
    final allMatches = ref.read(matchesProvider);
    final match = allMatches.firstWhere((m) => m.id == matchId);

    // Get a reference to the repository
    final repository = ref.read(playerStatsRepositoryProvider);

    // Add sample stats for the home team players
    repository.addPlayerStats(
      PlayerStats(
        matchId: matchId,
        playerId: 'player1',
        playerName: 'John Smith',
        playerNumber: 23,
        points: 18,
        minutes: 32,
        assists: 5,
        teamId: match.homeTeamId,
      ),
    );

    repository.addPlayerStats(
      PlayerStats(
        matchId: matchId,
        playerId: 'player2',
        playerName: 'Michael Johnson',
        playerNumber: 10,
        points: 12,
        minutes: 28,
        assists: 7,
        teamId: match.homeTeamId,
      ),
    );

    // Add sample stats for the away team players
    repository.addPlayerStats(
      PlayerStats(
        matchId: matchId,
        playerId: 'player3',
        playerName: 'Carlos Rodriguez',
        playerNumber: 7,
        points: 15,
        minutes: 30,
        assists: 4,
        teamId: match.awayTeamId,
      ),
    );

    repository.addPlayerStats(
      PlayerStats(
        matchId: matchId,
        playerId: 'player4',
        playerName: 'David Williams',
        playerNumber: 21,
        points: 10,
        minutes: 25,
        assists: 3,
        teamId: match.awayTeamId,
      ),
    );
  }
}

/// Widget that displays team stats in a styled view similar to the image
class TeamStatsView extends StatelessWidget {
  final List<PlayerStats> playerStats;
  final String title;
  final String matchId;
  final WidgetRef ref;

  const TeamStatsView({
    super.key,
    required this.playerStats,
    required this.title,
    required this.matchId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildHeaderCell('Jugador')),
                _buildHeaderCell('Min'),
                _buildHeaderCell('Reb'),
                _buildHeaderCell('Ast'),
                _buildHeaderCell('Pts'),
              ],
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: playerStats.length,
                itemBuilder: (context, index) {
                  final stats = playerStats[index];
                  return InkWell(
                    onTap: () => _showEditStatsDialog(context, stats),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${stats.playerNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                stats.playerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${stats.minutes}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '0',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ), // Rebounds - would come from stats
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${stats.assists}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${stats.points}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Shows a dialog to edit player stats
  void _showEditStatsDialog(BuildContext context, PlayerStats playerStats) {
    final pointsController = TextEditingController(
      text: playerStats.points.toString(),
    );
    final assistsController = TextEditingController(
      text: playerStats.assists.toString(),
    );
    final minutesController = TextEditingController(
      text: playerStats.minutes.toString(),
    );
    final timeController = TextEditingController(text: playerStats.time ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Stats for ${playerStats.playerName}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pointsController,
                    decoration: const InputDecoration(labelText: 'Points'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: assistsController,
                    decoration: const InputDecoration(labelText: 'Assists'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: minutesController,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time (optional)',
                      hintText: 'e.g. 2nd Quarter - 4:30',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Update player stats
                  _updatePlayerStats(
                    playerStats,
                    int.tryParse(pointsController.text) ?? playerStats.points,
                    int.tryParse(assistsController.text) ?? playerStats.assists,
                    int.tryParse(minutesController.text) ?? playerStats.minutes,
                    timeController.text.isEmpty ? null : timeController.text,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  /// Updates player stats in the repository
  void _updatePlayerStats(
    PlayerStats playerStats,
    int points,
    int assists,
    int minutes,
    String? time,
  ) {
    final repository = ref.read(playerStatsRepositoryProvider);
    final updatedStats = playerStats.copyWith(
      points: points,
      assists: assists,
      minutes: minutes,
      time: time,
    );
    repository.updatePlayerStats(updatedStats);

    // Force UI to refresh
    ref.invalidate(playerStatsByMatchProvider(matchId));
  }
}

/// Widget that displays a vertical timeline of game events
class GameHistoryTimeline extends StatelessWidget {
  const GameHistoryTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample game events for demonstration
    final events = [
      _GameEvent(
        time: '1st Quarter - 10:00',
        description: 'Game Start',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '1st Quarter - 8:45',
        description: 'Three-point by John Smith',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '1st Quarter - 7:30',
        description: 'Two-point by Carlos Rodriguez',
        isHomeTeam: false,
      ),
      _GameEvent(
        time: '1st Quarter - 6:15',
        description: 'Free throw by Michael Johnson',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '1st Quarter - 4:30',
        description: 'Assist by John Smith',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '1st Quarter - 2:00',
        description: 'Rebound by David Williams',
        isHomeTeam: false,
      ),
      _GameEvent(
        time: '2nd Quarter - 9:30',
        description: 'Three-point by Carlos Rodriguez',
        isHomeTeam: false,
      ),
      _GameEvent(
        time: '2nd Quarter - 7:15',
        description: 'Assist by Michael Johnson',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '2nd Quarter - 4:45',
        description: 'Two-point by John Smith',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '2nd Quarter - 1:30',
        description: 'Free throw by David Williams',
        isHomeTeam: false,
      ),
      _GameEvent(
        time: '3rd Quarter - 9:00',
        description: 'Block by Michael Johnson',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '3rd Quarter - 6:30',
        description: 'Steal by Carlos Rodriguez',
        isHomeTeam: false,
      ),
      _GameEvent(
        time: '3rd Quarter - 4:15',
        description: 'Dunk by John Smith',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '3rd Quarter - 1:45',
        description: 'Three-point by David Williams',
        isHomeTeam: false,
      ),
      _GameEvent(
        time: '4th Quarter - 8:30',
        description: 'Assist by John Smith',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '4th Quarter - 5:00',
        description: 'Rebound by Michael Johnson',
        isHomeTeam: true,
      ),
      _GameEvent(
        time: '4th Quarter - 2:30',
        description: 'Two-point by Carlos Rodriguez',
        isHomeTeam: false,
      ),
      _GameEvent(
        time: '4th Quarter - 0:00',
        description: 'Game End',
        isHomeTeam: true,
      ),
    ];

    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time indicator
                SizedBox(
                  width: 120,
                  child: Text(
                    event.time,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),

                // Timeline line with dot
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: event.isHomeTeam ? Colors.blue : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index < events.length - 1)
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey.shade800,
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // Event description
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      event.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            event.description.contains('Game')
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Helper class for game events in the timeline
class _GameEvent {
  final String time;
  final String description;
  final bool isHomeTeam;

  _GameEvent({
    required this.time,
    required this.description,
    required this.isHomeTeam,
  });
}
