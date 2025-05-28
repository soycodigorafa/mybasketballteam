import 'package:flutter/material.dart';
import '../../match/models/game_action.dart';

class ActionButtons extends StatelessWidget {
  final Function(ActionType) onActionSelected;

  const ActionButtons({
    super.key,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                type: ActionType.point,
                icon: Icons.sports_basketball,
                label: '2 Pts',
                onSelected: onActionSelected,
              ),
              ActionButton(
                type: ActionType.threePoint,
                icon: Icons.sports_basketball,
                label: '3 Pts',
                onSelected: onActionSelected,
              ),
              ActionButton(
                type: ActionType.assist,
                icon: Icons.handshake,
                label: 'Assist',
                onSelected: onActionSelected,
              ),
              ActionButton(
                type: ActionType.rebound,
                icon: Icons.replay,
                label: 'Rebound',
                onSelected: onActionSelected,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                type: ActionType.steal,
                icon: Icons.swipe,
                label: 'Steal',
                onSelected: onActionSelected,
              ),
              ActionButton(
                type: ActionType.block,
                icon: Icons.block,
                label: 'Block',
                onSelected: onActionSelected,
              ),
              ActionButton(
                type: ActionType.turnover,
                icon: Icons.change_circle,
                label: 'Turnover',
                onSelected: onActionSelected,
              ),
              ActionButton(
                type: ActionType.foul,
                icon: Icons.sports_handball,
                label: 'Foul',
                onSelected: onActionSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final ActionType type;
  final IconData icon;
  final String label;
  final Function(ActionType) onSelected;

  const ActionButton({
    super.key,
    required this.type,
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => onSelected(type),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
