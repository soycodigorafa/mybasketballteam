import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'league.g.dart';

/// Represents a basketball league
@HiveType(typeId: 3)
class League {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? logoUrl;

  League({
    String? id,
    required this.name,
    this.logoUrl,
  }) : id = id ?? const Uuid().v4();

  League copyWith({
    String? name,
    String? logoUrl,
  }) {
    return League(
      id: id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
    };
  }

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}
