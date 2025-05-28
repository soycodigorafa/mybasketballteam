import 'package:flutter/material.dart';
import '../../match/models/game_action.dart';

class ActionsList extends StatelessWidget {
  final List<GameAction> actions;
  final ScrollController scrollController;
  final Function(String) onDeleteAction;
  final String Function(ActionType) getActionTypeString;

  const ActionsList({
    super.key,
    required this.actions,
    required this.scrollController,
    required this.onDeleteAction,
    required this.getActionTypeString,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: actions.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final action = actions[index];
        return ActionItem(
          action: action,
          onDelete: () => onDeleteAction(action.id),
          getActionTypeString: getActionTypeString,
        );
      },
    );
  }
}

class ActionItem extends StatelessWidget {
  final GameAction action;
  final VoidCallback onDelete;
  final String Function(ActionType) getActionTypeString;

  const ActionItem({
    super.key,
    required this.action,
    required this.onDelete,
    required this.getActionTypeString,
  });

  @override
  Widget build(BuildContext context) {
    final actionText = _buildActionText();
    final timeText = _formatTimestamp(action.timestamp);
    final teamIndicator = action.isHomeTeam ? 'Home' : 'Away';
    final quarterText = 'Q${action.quarter}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(actionText),
        subtitle: Text('$timeText • $teamIndicator • $quarterText'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    switch (action.type) {
      case ActionType.point:
        return const CircleAvatar(child: Text('2P'));
      case ActionType.threePoint:
        return const CircleAvatar(child: Text('3P'));
      case ActionType.foul:
        return const CircleAvatar(child: Icon(Icons.sports_handball));
      case ActionType.turnover:
        return const CircleAvatar(child: Icon(Icons.change_circle));
      case ActionType.rebound:
        return const CircleAvatar(child: Icon(Icons.replay));
      case ActionType.steal:
        return const CircleAvatar(child: Icon(Icons.swipe));
      case ActionType.block:
        return const CircleAvatar(child: Icon(Icons.block));
      case ActionType.assist:
        return const CircleAvatar(child: Icon(Icons.handshake));
      case ActionType.endQuarter:
        return const CircleAvatar(child: Icon(Icons.timer));
    }
  }

  String _buildActionText() {
    final actionType = getActionTypeString(action.type);

    if (action.type == ActionType.endQuarter) {
      return 'End of Quarter ${action.quarter}';
    }

    if (action.playerName?.isEmpty ?? true) {
      return actionType;
    }

    return '$actionType - ${action.playerName} #${action.playerNumber}';
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
