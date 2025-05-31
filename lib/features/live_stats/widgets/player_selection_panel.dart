import 'package:flutter/material.dart';
import '../../player/models/player.dart';

class PlayerSelectionPanel extends StatelessWidget {
  final List<Player> players;
  final bool isSelectingHomeTeam;
  final Function(Player) onPlayerSelected;
  final VoidCallback onOpponentSelected;
  final VoidCallback onToggleTeam;
  final VoidCallback onCancel;

  const PlayerSelectionPanel({
    super.key,
    required this.players,
    required this.isSelectingHomeTeam,
    required this.onPlayerSelected,
    required this.onOpponentSelected,
    required this.onToggleTeam,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Player',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    Text(
                      isSelectingHomeTeam ? 'Home' : 'Away',
                      style: TextStyle(
                        color: isSelectingHomeTeam ? Colors.blue : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: onToggleTeam,
                      tooltip: 'Switch Teams',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onCancel,
                      tooltip: 'Cancel',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isSelectingHomeTeam)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final player in players)
                    PlayerChip(player: player, onSelected: onPlayerSelected),
                ],
              )
            else
              ElevatedButton(
                onPressed: onOpponentSelected,
                child: const Text('Enter Opponent Player'),
              ),
          ],
        ),
      ),
    );
  }
}

class PlayerChip extends StatelessWidget {
  final Player player;
  final Function(Player) onSelected;

  const PlayerChip({super.key, required this.player, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: CircleAvatar(
        child: Text(
          player.number.toString(),
          style: const TextStyle(fontSize: 12),
        ),
      ),
      label: Text(player.name),
      onPressed: () => onSelected(player),
    );
  }
}
