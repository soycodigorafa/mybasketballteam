import 'package:hive/hive.dart';

part 'team_stats.g.dart';

/// Represents team statistics
@HiveType(typeId: 4)
class TeamStats {
  @HiveField(0)
  final int wins;
  
  @HiveField(1)
  final int losses;
  
  @HiveField(2)
  final double avgPointsPerGame;

  TeamStats({
    this.wins = 0,
    this.losses = 0,
    this.avgPointsPerGame = 0.0,
  });

  TeamStats copyWith({
    int? wins,
    int? losses,
    double? avgPointsPerGame,
  }) {
    return TeamStats(
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      avgPointsPerGame: avgPointsPerGame ?? this.avgPointsPerGame,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wins': wins,
      'losses': losses,
      'avgPointsPerGame': avgPointsPerGame,
    };
  }

  factory TeamStats.fromJson(Map<String, dynamic> json) {
    return TeamStats(
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      avgPointsPerGame: (json['avgPointsPerGame'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
