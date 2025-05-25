import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../team/models/league.dart';
import '../models/match.dart';
import '../view_models/matches_view_model.dart';

/// Screen that displays detailed league information and matches
class LeagueDetailScreen extends ConsumerWidget {
  final String leagueId;
  final String teamId;

  const LeagueDetailScreen({
    super.key,
    required this.leagueId,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the league information
    final league = ref.watch(leagueByIdProvider(leagueId));
    final matches = ref.watch(sortedMatchesByLeagueProvider(leagueId));

    return Scaffold(
      appBar: AppBar(
        title: Text(league?.name ?? 'League Details'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh matches data
          ref.invalidate(sortedMatchesByLeagueProvider(leagueId));
          return Future.value();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // League info header
                _buildLeagueHeader(context, league),
                
                const SizedBox(height: 24),
                
                // Matches section
                _buildMatchesSection(context, ref, matches),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddMatch(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLeagueHeader(BuildContext context, League? league) {
    final theme = Theme.of(context);
    
    if (league == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('League not found')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (league.logoUrl != null)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(league.logoUrl!),
                  )
                else
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.sports_basketball, size: 30),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        league.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Season 2024-2025',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesSection(BuildContext context, WidgetRef ref, List<Match> matches) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Matches', style: theme.textTheme.titleLarge),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Match'),
                  onPressed: () => _navigateToAddMatch(context),
                ),
              ],
            ),
            const Divider(),
            if (matches.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text('No matches found for this league'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return ListTile(
                    title: Text('${match.homeTeamName} vs ${match.awayTeamName}'),
                    subtitle: Text(
                      'Date: ${_formatDate(match.date)} - Score: ${match.homeTeamScore} - ${match.awayTeamScore}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _navigateToMatchDetail(context, match.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToAddMatch(BuildContext context) {
    context.pushNamed(
      'addMatch',
      pathParameters: {
        'leagueId': leagueId,
        'teamId': teamId,
      },
    );
  }

  void _navigateToMatchDetail(BuildContext context, String matchId) {
    context.pushNamed(
      'matchDetail',
      pathParameters: {
        'matchId': matchId,
        'leagueId': leagueId,
        'teamId': teamId,
      },
    );
  }
}
