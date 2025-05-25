import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/match.dart';
import '../models/match_repository.dart';
import '../view_models/matches_view_model.dart';

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
    late final Match match;

    try {
      match = allMatches.firstWhere((m) => m.id == matchId);
    } catch (e) {
      // Match not found
      return Scaffold(
        appBar: AppBar(title: const Text('Match Details')),
        body: const Center(child: Text('Match not found')),
      );
    }

    final league = ref.watch(leagueByIdProvider(leagueId));

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

  String _getResultText(Match match, String teamId) {
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

  Color _getResultColor(Match match, String teamId) {
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

  void _editMatch(BuildContext context, WidgetRef ref, Match match) async {
    // Navigate to edit match screen
    // This would be implemented in a similar way to the AddMatchScreen
    // For now we'll show a simple dialog for demonstration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit match functionality coming soon')),
    );
  }

  void _confirmDeleteMatch(BuildContext context, WidgetRef ref, Match match) {
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

  void _deleteMatch(BuildContext context, WidgetRef ref, Match match) async {
    await ref.read(matchesViewModelProvider.notifier).deleteMatch(match.id);

    if (context.mounted) {
      // Navigate back to the league screen
      context.pop();
    }
  }
}
