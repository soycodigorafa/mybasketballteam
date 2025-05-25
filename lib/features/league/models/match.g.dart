// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchAdapter extends TypeAdapter<Match> {
  @override
  final int typeId = 4;

  @override
  Match read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Match(
      id: fields[0] as String,
      leagueId: fields[1] as String,
      homeTeamId: fields[2] as String,
      homeTeamName: fields[3] as String,
      homeTeamScore: fields[4] as int,
      awayTeamId: fields[5] as String,
      awayTeamName: fields[6] as String,
      awayTeamScore: fields[7] as int,
      date: fields[8] as DateTime,
      location: fields[9] as String?,
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Match obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.leagueId)
      ..writeByte(2)
      ..write(obj.homeTeamId)
      ..writeByte(3)
      ..write(obj.homeTeamName)
      ..writeByte(4)
      ..write(obj.homeTeamScore)
      ..writeByte(5)
      ..write(obj.awayTeamId)
      ..writeByte(6)
      ..write(obj.awayTeamName)
      ..writeByte(7)
      ..write(obj.awayTeamScore)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.location)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
