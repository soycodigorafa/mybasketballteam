import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'team.g.dart';

/// Represents a basketball team
@HiveType(typeId: 2)
class Team {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? logoUrl;
  
  @HiveField(3)
  final String? description;
  
  @HiveField(4)
  final String? coachName;

  Team({
    String? id,
    required this.name,
    this.logoUrl,
    this.description,
    this.coachName,
  }) : id = id ?? const Uuid().v4();

  Team copyWith({
    String? name,
    String? logoUrl,
    String? description,
    String? coachName,
  }) {
    return Team(
      id: id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      coachName: coachName ?? this.coachName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'coachName': coachName,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      coachName: json['coachName'] as String?,
    );
  }
}
