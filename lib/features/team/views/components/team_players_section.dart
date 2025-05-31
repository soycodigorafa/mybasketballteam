import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mybasketteam/core/models/app_models.dart';
import 'package:mybasketteam/features/player/providers/players_providers.dart';
import 'package:mybasketteam/features/player/views/add_player_screen.dart';

/// Component to display and manage team players
class TeamPlayersSection extends ConsumerWidget {
  final String teamId;
  final List<Player> players;

  const TeamPlayersSection({
    super.key,
    required this.teamId,
    required this.players,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Text('Team Players', style: theme.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addPlayer(context),
                ),
              ],
            ),
            const Divider(),

            if (players.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: Text('No players in the team yet')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return _buildPlayerCard(context, ref, player);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, WidgetRef ref, Player player) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Player number in a circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#${player.number}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Player details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player.position.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  if (player.age != null ||
                      player.height != null ||
                      player.weight != null)
                    const SizedBox(height: 4),
                  if (player.age != null ||
                      player.height != null ||
                      player.weight != null)
                    Row(
                      children: [
                        if (player.age != null)
                          _buildPlayerStat('${player.age} yrs'),
                        if (player.height != null)
                          _buildPlayerStat('${player.height} cm'),
                        if (player.weight != null)
                          _buildPlayerStat('${player.weight} kg'),
                      ],
                    ),
                ],
              ),
            ),

            // Actions
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editPlayer(context, player),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeletePlayer(context, ref, player),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStat(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  void _addPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPlayerScreen(teamId: teamId),
        fullscreenDialog: true,
      ),
    );
  }

  void _editPlayer(BuildContext context, Player player) {
    // TODO: Implement edit player screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit player functionality coming soon')),
    );
  }

  void _confirmDeletePlayer(
    BuildContext context,
    WidgetRef ref,
    Player player,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Player'),
          content: Text('Are you sure you want to delete ${player.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                _deletePlayer(ref, player);
                Navigator.pop(context);
              },
              child: const Text('DELETE'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void _deletePlayer(WidgetRef ref, Player player) {
    final playersViewModel = ref.read(playersProvider.notifier);
    playersViewModel.deletePlayer(player.id);
  }
}
