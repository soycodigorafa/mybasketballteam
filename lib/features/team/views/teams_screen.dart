import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Models
import '../models/team.dart';

// Providers (formerly view_models)
import '../providers/teams_providers.dart';

// Views
import 'add_team_screen.dart';

/// Screen that displays a list of teams
class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the teamsProvider from TeamsViewModel
    final teams = ref.watch(teamsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Basketball Teams')),
      body:
          teams.isEmpty
              ? const Center(child: Text('No teams yet. Add your first team!'))
              : ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return TeamCard(team: team);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTeamScreen(),
              fullscreenDialog: true,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Card widget for displaying team information
class TeamCard extends StatelessWidget {
  final Team team;

  const TeamCard({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to the team detail screen
          context.push('/team/${team.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Team logo or placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    team.logoUrl != null
                        ? ClipOval(
                          child: Image.network(
                            team.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.sports_basketball,
                                  color: theme.colorScheme.primary,
                                  size: 32,
                                ),
                          ),
                        )
                        : Icon(
                          Icons.sports_basketball,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
              ),
              const SizedBox(width: 16),
              // Team details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (team.coachName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Coach: ${team.coachName}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    if (team.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        team.description!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  // Navigate to the team detail screen
                  context.go('/team/${team.id}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
