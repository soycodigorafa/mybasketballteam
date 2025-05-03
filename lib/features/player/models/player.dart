import 'package:uuid/uuid.dart';

/// Represents a basketball player in the team
class Player {
  final String id;
  final String name;
  final int number;
  final String position;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final String? photoUrl;

  Player({
    String? id,
    required this.name,
    required this.number,
    required this.position,
    required this.age,
    required this.height,
    required this.weight,
    this.photoUrl,
  }) : id = id ?? const Uuid().v4();

  Player copyWith({
    String? name,
    int? number,
    String? position,
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
      'position': position,
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
      position: json['position'] as String,
      age: json['age'] as int,
      height: json['height'] as double,
      weight: json['weight'] as double,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
