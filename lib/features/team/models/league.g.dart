// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeagueAdapter extends TypeAdapter<League> {
  @override
  final int typeId = 3;

  @override
  League read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return League(
      id: fields[0] as String?,
      name: fields[1] as String,
      logoUrl: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, League obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.logoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeagueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
