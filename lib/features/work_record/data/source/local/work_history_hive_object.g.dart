// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_history_hive_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkHistoryHiveObjectAdapter extends TypeAdapter<WorkHistoryHiveObject> {
  @override
  final int typeId = 0;

  @override
  WorkHistoryHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkHistoryHiveObject(
      workDate: fields[0] as DateTime,
      workName: fields[1] as String,
      sets: fields[2] as int,
      count: fields[3] as int,
      weight: fields[4] as int,
      exerciseTime: fields[5] as int,
      similarity: fields[6] as double,
      stability: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WorkHistoryHiveObject obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.workDate)
      ..writeByte(1)
      ..write(obj.workName)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.exerciseTime)
      ..writeByte(6)
      ..write(obj.similarity)
      ..writeByte(7)
      ..write(obj.stability);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkHistoryHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
