// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obstacle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObstacleModelAdapter extends TypeAdapter<ObstacleModel> {
  @override
  final int typeId = 4;

  @override
  ObstacleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ObstacleModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      linkedId: fields[3] as String,
      linkedType: fields[4] as String,
      occurredAt: fields[5] as DateTime,
      impactLevel: fields[6] as String,
      impactDescription: fields[7] as String,
      solution: fields[8] as String,
      isResolved: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ObstacleModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.linkedId)
      ..writeByte(4)
      ..write(obj.linkedType)
      ..writeByte(5)
      ..write(obj.occurredAt)
      ..writeByte(6)
      ..write(obj.impactLevel)
      ..writeByte(7)
      ..write(obj.impactDescription)
      ..writeByte(8)
      ..write(obj.solution)
      ..writeByte(9)
      ..write(obj.isResolved);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObstacleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
