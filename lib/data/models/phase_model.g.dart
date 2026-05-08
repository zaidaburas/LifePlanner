// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phase_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhaseModelAdapter extends TypeAdapter<PhaseModel> {
  @override
  final int typeId = 3;

  @override
  PhaseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhaseModel(
      id: fields[0] as String,
      title: fields[1] as String,
      taskId: fields[2] as String,
      progress: fields[3] as double,
      status: fields[4] as String,
      notes: fields[5] as String,
      checklist: (fields[6] as List?)?.cast<String>(),
      checklistDone: (fields[7] as List?)?.cast<bool>(),
      timeSpentMinutes: fields[8] as int,
      orderIndex: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PhaseModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.taskId)
      ..writeByte(3)
      ..write(obj.progress)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.checklist)
      ..writeByte(7)
      ..write(obj.checklistDone)
      ..writeByte(8)
      ..write(obj.timeSpentMinutes)
      ..writeByte(9)
      ..write(obj.orderIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
