import 'package:uuid/uuid.dart';

class PlayerStats {
  final String id;
  final String matchId;
  final String playerId;
  final String playerName;
  final int playerNumber;
  final int points;
  final int minutes;
  final int assists;
  final String teamId;
  final String? time;

  PlayerStats({
    String? id,
    required this.matchId,
    required this.playerId,
    required this.playerName,
    required this.playerNumber,
    required this.points,
    required this.minutes,
    required this.assists,
    required this.teamId,
    this.time,
  }) : id = id ?? const Uuid().v4();

  PlayerStats copyWith({
    String? matchId,
    String? playerId,
    String? playerName,
    int? playerNumber,
    int? points,
    int? minutes,
    int? assists,
    String? teamId,
    String? time,
  }) {
    return PlayerStats(
      id: id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      playerNumber: playerNumber ?? this.playerNumber,
      points: points ?? this.points,
      minutes: minutes ?? this.minutes,
      assists: assists ?? this.assists,
      teamId: teamId ?? this.teamId,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'playerId': playerId,
      'playerName': playerName,
      'playerNumber': playerNumber,
      'points': points,
      'minutes': minutes,
      'assists': assists,
      'teamId': teamId,
      'time': time,
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      playerNumber: json['playerNumber'] as int,
      points: json['points'] as int,
      minutes: json['minutes'] as int,
      assists: json['assists'] as int,
      teamId: json['teamId'] as String,
      time: json['time'] as String?,
    );
  }
}
