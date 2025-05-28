import 'package:uuid/uuid.dart';
import 'league.dart';
import 'team_stats.dart';

/// Represents a basketball team
/// Represents a basketball team
class Team {
  final String id;

  final String name;

  final String? logoUrl;

  final String? description;

  final String? coachName;

  final League? currentLeague;

  final List<League> leagues;

  final TeamStats stats;

  Team({
    String? id,
    required this.name,
    this.logoUrl,
    this.description,
    this.coachName,
    this.currentLeague,
    this.leagues = const [],
    TeamStats? stats,
  }) : id = id ?? const Uuid().v4(),
       stats = stats ?? TeamStats();

  Team copyWith({
    String? name,
    String? logoUrl,
    String? description,
    String? coachName,
    League? currentLeague,
    List<League>? leagues,
    TeamStats? stats,
  }) {
    return Team(
      id: id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      coachName: coachName ?? this.coachName,
      currentLeague: currentLeague ?? this.currentLeague,
      leagues: leagues ?? this.leagues,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'coachName': coachName,
      'currentLeague': currentLeague?.toJson(),
      'leagues': leagues.map((league) => league.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      coachName: json['coachName'] as String?,
      currentLeague:
          json['currentLeague'] != null
              ? League.fromJson(json['currentLeague'] as Map<String, dynamic>)
              : null,
      leagues:
          (json['leagues'] as List<dynamic>?)
              ?.map((e) => League.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stats:
          json['stats'] != null
              ? TeamStats.fromJson(json['stats'] as Map<String, dynamic>)
              : TeamStats(),
    );
  }
}
