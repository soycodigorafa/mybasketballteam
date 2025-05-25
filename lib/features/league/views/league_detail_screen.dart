import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../team/models/league.dart';
import '../../match/models/match.dart';
import '../../match/view_models/matches_view_model.dart';

/// Screen that displays detailed league information and matches
class LeagueDetailScreen extends ConsumerStatefulWidget {
  final String leagueId;
  final String teamId;

  const LeagueDetailScreen({
    super.key,
    required this.leagueId,
    required this.teamId,
  });

  @override
  ConsumerState<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends ConsumerState<LeagueDetailScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change
    _refreshData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app resumes
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  void _refreshData() {
    // Invalidate the match providers to force a refresh
    ref.invalidate(sortedMatchesByLeagueProvider(widget.leagueId));
  }

  @override
  Widget build(BuildContext context) {
    // Get the league information
    final league = ref.watch(leagueByIdProvider(widget.leagueId));
    final matches = ref.watch(sortedMatchesByLeagueProvider(widget.leagueId));

    return Scaffold(
      appBar: AppBar(title: Text(league?.name ?? 'League Details')),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh matches data
          ref.invalidate(sortedMatchesByLeagueProvider(widget.leagueId));
          return Future.value();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // League info header
                LeagueHeader(league: league),

                const SizedBox(height: 24),

                // Matches section
                MatchesSection(
                  matches: matches,
                  onAddMatch: () => _navigateToAddMatch(context),
                  onMatchTap:
                      (matchId) => _navigateToMatchDetail(context, matchId),
                  formatDate: _formatDate,
                ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToAddMatch(BuildContext context) {
    context.pushNamed(
      'addMatch',
      pathParameters: {'leagueId': widget.leagueId, 'teamId': widget.teamId},
    );
  }

  void _navigateToMatchDetail(BuildContext context, String matchId) {
    context.pushNamed(
      'matchDetail',
      pathParameters: {
        'matchId': matchId,
        'leagueId': widget.leagueId,
        'teamId': widget.teamId,
      },
    );
  }
}

/// Widget that displays the league header information
class LeagueHeader extends StatelessWidget {
  final League? league;

  const LeagueHeader({super.key, required this.league});

  @override
  Widget build(BuildContext context) {
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
                if (league?.logoUrl != null)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(league!.logoUrl!),
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
                      Text(league!.name, style: theme.textTheme.headlineSmall),
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
}

/// Widget that displays the matches section
class MatchesSection extends StatelessWidget {
  final List<Match> matches;
  final VoidCallback onAddMatch;
  final Function(String) onMatchTap;
  final String Function(DateTime) formatDate;

  const MatchesSection({
    super.key,
    required this.matches,
    required this.onAddMatch,
    required this.onMatchTap,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
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
                  onPressed: onAddMatch,
                ),
              ],
            ),
            const Divider(),
            if (matches.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('No matches found for this league')),
              )
            else
              SizedBox(
                height: matches.length * 72.0, // Estimated height per list item
                child: ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return MatchListItem(
                      match: match,
                      formatDate: formatDate,
                      onTap: () => onMatchTap(match.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget that displays a single match item in the list
class MatchListItem extends StatelessWidget {
  final Match match;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const MatchListItem({
    super.key,
    required this.match,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${match.homeTeamName} vs ${match.awayTeamName}'),
      subtitle: Text(
        'Date: ${formatDate(match.date)} - Score: ${match.homeTeamScore} - ${match.awayTeamScore}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
