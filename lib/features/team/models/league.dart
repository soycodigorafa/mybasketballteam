import 'package:uuid/uuid.dart';

/// Represents a basketball league
/// Represents a basketball league
class League {
    final String id;
  
    final String name;
  
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
