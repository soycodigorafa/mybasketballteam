import 'package:uuid/uuid.dart';

/// Basketball player positions
enum PlayerPosition {
    pointGuard, // Base
    shootingGuard, // Escolta
    smallForward, // Alero
    powerForward, // Ala-Pivot
    center; // Pivot

  String get displayName {
    switch (this) {
      case PlayerPosition.pointGuard:
        return 'Point Guard';
      case PlayerPosition.shootingGuard:
        return 'Shooting Guard';
      case PlayerPosition.smallForward:
        return 'Small Forward';
      case PlayerPosition.powerForward:
        return 'Power Forward';
      case PlayerPosition.center:
        return 'Center';
    }
  }

  static PlayerPosition fromString(String value) {
    return PlayerPosition.values.firstWhere(
      (position) =>
          position.toString().split('.').last == value ||
          position.displayName == value,
      orElse: () => PlayerPosition.smallForward,
    );
  }
}

/// Represents a basketball player in the team
class Player {
    final String id;

    final String name;

    final int number;

    final PlayerPosition position;

    final String teamId;

    final int? age;

    final double? height; // in cm

    final double? weight; // in kg

    final String? photoUrl;

  Player({
    String? id,
    required this.name,
    required this.number,
    required this.position,
    required this.teamId,
    this.age,
    this.height,
    this.weight,
    this.photoUrl,
  }) : id = id ?? const Uuid().v4();

  Player copyWith({
    String? name,
    int? number,
    PlayerPosition? position,
    String? teamId,
    int? age,
    double? height,
    double? weight,
    String? photoUrl,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      number: number ?? this.number,
      position: position ?? this.position,
      teamId: teamId ?? this.teamId,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'position': position.toString().split('.').last,
      'teamId': teamId,
      'age': age,
      'height': height,
      'weight': weight,
      'photoUrl': photoUrl,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as int,
      position: PlayerPosition.fromString(json['position'] as String),
      teamId: json['teamId'] as String,
      age: json['age'] as int?,
      height: json['height'] as double?,
      weight: json['weight'] as double?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
