import 'package:uuid/uuid.dart';

/// Represents a single action during a basketball game
class GameAction {
  final String id;
  final String matchId;
  final ActionType type;
  final String? playerId;
  final String? playerName;
  final int? playerNumber;
  final String teamId;
  final bool isHomeTeam;
  final int quarter;
  final DateTime timestamp;
  
  GameAction({
    String? id,
    required this.matchId,
    required this.type,
    this.playerId,
    this.playerName,
    this.playerNumber,
    required this.teamId,
    required this.isHomeTeam,
    required this.quarter,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();
  
  GameAction copyWith({
    String? matchId,
    ActionType? type,
    String? playerId,
    String? playerName,
    int? playerNumber,
    String? teamId,
    bool? isHomeTeam,
    int? quarter,
    DateTime? timestamp,
  }) {
    return GameAction(
      id: id,
      matchId: matchId ?? this.matchId,
      type: type ?? this.type,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      playerNumber: playerNumber ?? this.playerNumber,
      teamId: teamId ?? this.teamId,
      isHomeTeam: isHomeTeam ?? this.isHomeTeam,
      quarter: quarter ?? this.quarter,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'type': type.index,
      'playerId': playerId,
      'playerName': playerName,
      'playerNumber': playerNumber,
      'teamId': teamId,
      'isHomeTeam': isHomeTeam,
      'quarter': quarter,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory GameAction.fromJson(Map<String, dynamic> json) {
    return GameAction(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      type: ActionType.values[json['type'] as int],
      playerId: json['playerId'] as String?,
      playerName: json['playerName'] as String?,
      playerNumber: json['playerNumber'] as int?,
      teamId: json['teamId'] as String,
      isHomeTeam: json['isHomeTeam'] as bool,
      quarter: json['quarter'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Types of actions that can occur in a basketball game
enum ActionType {
  point,        // Regular 2-point shot
  threePoint,   // 3-point shot
  freeThrow,    // Free throw (1-point)
  foul,         // Foul committed
  turnover,     // Turnover
  rebound,      // Rebound
  steal,        // Steal
  block,        // Block
  assist,       // Assist
  endQuarter,   // End of quarter marker
}

/// Helper to get point value from action type
int getPointsForAction(ActionType type) {
  switch (type) {
    case ActionType.point:
      return 2;
    case ActionType.threePoint:
      return 3;
    case ActionType.freeThrow:
      return 1;
    default:
      return 0;
  }
}
