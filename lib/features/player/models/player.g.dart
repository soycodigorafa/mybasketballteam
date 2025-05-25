// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      id: fields[0] as String?,
      name: fields[1] as String,
      number: fields[2] as int,
      position: fields[3] as PlayerPosition,
      teamId: fields[4] as String,
      age: fields[5] as int?,
      height: fields[6] as double?,
      weight: fields[7] as double?,
      photoUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.number)
      ..writeByte(3)
      ..write(obj.position)
      ..writeByte(4)
      ..write(obj.teamId)
      ..writeByte(5)
      ..write(obj.age)
      ..writeByte(6)
      ..write(obj.height)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.photoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerPositionAdapter extends TypeAdapter<PlayerPosition> {
  @override
  final int typeId = 1;

  @override
  PlayerPosition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return PlayerPosition.pointGuard;
      case 2:
        return PlayerPosition.shootingGuard;
      case 3:
        return PlayerPosition.smallForward;
      case 4:
        return PlayerPosition.powerForward;
      case 5:
        return PlayerPosition.center;
      default:
        return PlayerPosition.pointGuard;
    }
  }

  @override
  void write(BinaryWriter writer, PlayerPosition obj) {
    switch (obj) {
      case PlayerPosition.pointGuard:
        writer.writeByte(1);
        break;
      case PlayerPosition.shootingGuard:
        writer.writeByte(2);
        break;
      case PlayerPosition.smallForward:
        writer.writeByte(3);
        break;
      case PlayerPosition.powerForward:
        writer.writeByte(4);
        break;
      case PlayerPosition.center:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
