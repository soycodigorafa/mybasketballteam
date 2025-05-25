import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'match.g.dart';

/// Represents a basketball match between two teams
@HiveType(typeId: 4)
class Match {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String leagueId;
  
  @HiveField(2)
  final String homeTeamId;
  
  @HiveField(3)
  final String homeTeamName;
  
  @HiveField(4)
  final int homeTeamScore;
  
  @HiveField(5)
  final String awayTeamId;
  
  @HiveField(6)
  final String awayTeamName;
  
  @HiveField(7)
  final int awayTeamScore;
  
  @HiveField(8)
  final DateTime date;
  
  @HiveField(9)
  final String? location;
  
  @HiveField(10)
  final String? notes;

  Match({
    String? id,
    required this.leagueId,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.homeTeamScore,
    required this.awayTeamId,
    required this.awayTeamName,
    required this.awayTeamScore,
    required this.date,
    this.location,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Match copyWith({
    String? leagueId,
    String? homeTeamId,
    String? homeTeamName,
    int? homeTeamScore,
    String? awayTeamId,
    String? awayTeamName,
    int? awayTeamScore,
    DateTime? date,
    String? location,
    String? notes,
  }) {
    return Match(
      id: id,
      leagueId: leagueId ?? this.leagueId,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      homeTeamScore: homeTeamScore ?? this.homeTeamScore,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      awayTeamScore: awayTeamScore ?? this.awayTeamScore,
      date: date ?? this.date,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leagueId': leagueId,
      'homeTeamId': homeTeamId,
      'homeTeamName': homeTeamName,
      'homeTeamScore': homeTeamScore,
      'awayTeamId': awayTeamId,
      'awayTeamName': awayTeamName,
      'awayTeamScore': awayTeamScore,
      'date': date.toIso8601String(),
      'location': location,
      'notes': notes,
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      leagueId: json['leagueId'] as String,
      homeTeamId: json['homeTeamId'] as String,
      homeTeamName: json['homeTeamName'] as String,
      homeTeamScore: json['homeTeamScore'] as int,
      awayTeamId: json['awayTeamId'] as String,
      awayTeamName: json['awayTeamName'] as String,
      awayTeamScore: json['awayTeamScore'] as int,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
