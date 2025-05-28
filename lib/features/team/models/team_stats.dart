

/// Represents team statistics
/// Represents team statistics
class TeamStats {
    final int wins;
  
    final int losses;
  
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
