// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_goal_hive_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkGoalHiveObjectAdapter extends TypeAdapter<WorkGoalHiveObject> {
  @override
  final int typeId = 1;

  @override
  WorkGoalHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkGoalHiveObject(
      setedDate: fields[0] as DateTime,
      workName: fields[1] as String,
      goalCount: fields[2] as int,
      goalWeight: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkGoalHiveObject obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.setedDate)
      ..writeByte(1)
      ..write(obj.workName)
      ..writeByte(2)
      ..write(obj.goalCount)
      ..writeByte(3)
      ..write(obj.goalWeight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkGoalHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
