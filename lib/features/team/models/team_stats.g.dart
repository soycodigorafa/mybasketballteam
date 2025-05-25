// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeamStatsAdapter extends TypeAdapter<TeamStats> {
  @override
  final int typeId = 4;

  @override
  TeamStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TeamStats(
      wins: fields[0] as int,
      losses: fields[1] as int,
      avgPointsPerGame: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TeamStats obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.wins)
      ..writeByte(1)
      ..write(obj.losses)
      ..writeByte(2)
      ..write(obj.avgPointsPerGame);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
