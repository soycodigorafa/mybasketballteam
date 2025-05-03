import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'player.g.dart';

/// Basketball player positions
@HiveType(typeId: 1)
enum PlayerPosition {
  @HiveField(0)
  pointGuard,   // Base
  @HiveField(1)
  shootingGuard, // Escolta
  @HiveField(2)
  smallForward,  // Alero
  @HiveField(3)
  powerForward,  // Ala-Pivot
  @HiveField(4)
  center;        // Pivot
  
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
      (position) => position.toString().split('.').last == value || 
                    position.displayName == value,
      orElse: () => PlayerPosition.smallForward,
    );
  }
}

/// Represents a basketball player in the team
@HiveType(typeId: 0)
class Player {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int number;
  
  @HiveField(3)
  final PlayerPosition position;
  
  @HiveField(4)
  final String teamId;
  
  @HiveField(5)
  final int? age;
  
  @HiveField(6)
  final double? height; // in cm
  
  @HiveField(7)
  final double? weight; // in kg
  
  @HiveField(8)
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
