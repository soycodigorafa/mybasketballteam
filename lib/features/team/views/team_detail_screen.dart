import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mybasketteam/features/live_stats/views/live_stats_screen.dart';

// Use centralized model exports
import 'package:mybasketteam/core/models/app_models.dart';

// Use centralized provider exports
import 'package:mybasketteam/core/providers/app_providers.dart';

// Views and components
import 'package:mybasketteam/features/match/views/components/new_game_dialog.dart';
import 'package:mybasketteam/features/team/views/components/team_info_section.dart';
import 'package:mybasketteam/features/team/views/components/team_stats_section.dart';
import 'package:mybasketteam/features/team/views/components/team_players_section.dart';
import 'package:mybasketteam/features/team/views/components/league_selection_dialog.dart';
import 'package:mybasketteam/features/team/views/edit_team_screen.dart';

/// Screen that displays detailed team information and allows editing
class TeamDetailScreen extends ConsumerWidget {
  final String teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use AsyncValue to handle loading states
    final AsyncValue<Team?> teamAsyncValue = AsyncValue.data(
      ref.watch(teamByIdProvider(teamId)),
    );
    final allPlayers = ref.watch(playersProvider);
    final teamPlayers =
        allPlayers.where((player) => player.teamId == teamId).toList();

    return teamAsyncValue.when(
      data: (team) {
        if (team == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Team Details')),
            body: const Center(child: Text('Team not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(team.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.sports_basketball),
                tooltip: 'Live Stats',
                onPressed: () => _startLiveStats(context, ref, team),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToEditTeam(context, team),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Refresh team data if needed
              ref.invalidate(teamByIdProvider(teamId));
              ref.invalidate(playersProvider);
              return Future.value();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team info section (name, logo, description, coach)
                    TeamInfoSection(team: team),

                    const SizedBox(height: 24),

                    // League information
                    _buildLeagueSection(context, ref, team),

                    const SizedBox(height: 24),

                    // Team statistics
                    TeamStatsSection(
                      stats: team.stats,
                      onEdit: () => _editTeamStats(context, ref, team),
                    ),

                    const SizedBox(height: 24),

                    // Team players section
                    TeamPlayersSection(teamId: teamId, players: teamPlayers),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error loading team: $error')),
          ),
    );
  }

  Widget _buildLeagueSection(BuildContext context, WidgetRef ref, Team team) {
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
                Text('League Information', style: theme.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _selectLeague(context, ref, team),
                ),
              ],
            ),
            const Divider(),
            if (team.currentLeague != null)
              InkWell(
                onTap:
                    () => _navigateToLeagueDetail(
                      context,
                      team.id,
                      team.currentLeague!.id,
                    ),
                child: ListTile(
                  leading:
                      team.currentLeague!.logoUrl != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              team.currentLeague!.logoUrl!,
                            ),
                          )
                          : const CircleAvatar(
                            child: Icon(Icons.sports_basketball),
                          ),
                  title: Text(team.currentLeague!.name),
                  subtitle: const Text('Current League'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              )
            else
              const ListTile(
                leading: CircleAvatar(child: Icon(Icons.sports_basketball)),
                title: Text('No league selected'),
                subtitle: Text('Tap edit to select a league'),
              ),

            if (team.leagues.isNotEmpty && team.leagues.length > 1) ...[
              const SizedBox(height: 8),
              Text('Previous Leagues', style: theme.textTheme.titleMedium),
              ...team.leagues
                  .where(
                    (league) =>
                        team.currentLeague == null ||
                        league.id != team.currentLeague!.id,
                  )
                  .map(
                    (league) => InkWell(
                      onTap:
                          () => _navigateToLeagueDetail(
                            context,
                            team.id,
                            league.id,
                          ),
                      child: ListTile(
                        leading:
                            league.logoUrl != null
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    league.logoUrl!,
                                  ),
                                )
                                : const CircleAvatar(
                                  child: Icon(Icons.sports_basketball),
                                ),
                        title: Text(league.name),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToEditTeam(BuildContext context, Team team) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTeamScreen(team: team),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      // Refresh data if team was updated
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team updated successfully')),
        );
      }
    }
  }

  void _selectLeague(BuildContext context, WidgetRef ref, Team team) async {
    final teamsViewModel = ref.read(teamsNotifierProvider.notifier);
    final League? selectedLeague = await showDialog<League>(
      context: context,
      builder: (BuildContext context) {
        return LeagueSelectionDialog(
          currentLeague: team.currentLeague,
          leagues: team.leagues,
        );
      },
    );

    if (selectedLeague != null) {
      // Update team with the selected league
      List<League> updatedLeagues = List.from(team.leagues);

      // Add the league if it's not already in the list
      if (!updatedLeagues.any((league) => league.id == selectedLeague.id)) {
        updatedLeagues.add(selectedLeague);
      }

      final updatedTeam = team.copyWith(
        currentLeague: selectedLeague,
        leagues: updatedLeagues,
      );

      await teamsViewModel.updateTeam(updatedTeam);
    }
  }

  void _navigateToLeagueDetail(
    BuildContext context,
    String teamId,
    String leagueId,
  ) {
    context.pushNamed(
      'leagueDetail',
      pathParameters: {'teamId': teamId, 'leagueId': leagueId},
    );
  }

  void _editTeamStats(BuildContext context, WidgetRef ref, Team team) async {
    // Initial values for the form
    final formKey = GlobalKey<FormState>();
    int wins = team.stats.wins;
    int losses = team.stats.losses;
    double avgPoints = team.stats.avgPointsPerGame;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Team Stats'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Wins'),
                  keyboardType: TextInputType.number,
                  initialValue: wins.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    wins = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Losses'),
                  keyboardType: TextInputType.number,
                  initialValue: losses.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    losses = int.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Avg Points Per Game',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  initialValue: avgPoints.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    avgPoints = double.parse(value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.pop(context, true);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final teamsViewModel = ref.read(teamsNotifierProvider.notifier);
      final updatedStats = TeamStats(
        wins: wins,
        losses: losses,
        avgPointsPerGame: avgPoints,
      );
      final updatedTeam = team.copyWith(stats: updatedStats);
      await teamsViewModel.updateTeam(updatedTeam);
    }
  }

  /// Shows dialog to start a live game and navigates to the LiveStatsScreen
  void _startLiveStats(BuildContext context, WidgetRef ref, Team team) async {
    final match = await showDialog(
      context: context,
      builder: (context) => NewGameDialog(team: team),
    );

    if (match != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  LiveStatsScreen(teamId: team.id, teamName: team.name),
        ),
      );
    }
  }
}
