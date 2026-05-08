// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 2;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      projectId: fields[3] as String,
      taskType: fields[4] as String,
      category: fields[5] as String,
      createdAt: fields[6] as DateTime,
      deadline: fields[7] as DateTime?,
      estimatedMinutes: fields[8] as int,
      actualMinutes: fields[9] as int,
      difficulty: fields[10] as String,
      progress: fields[11] as double,
      status: fields[12] as String,
      priority: fields[13] as int,
      isUrgent: fields[14] as bool,
      phaseIds: (fields[15] as List?)?.cast<String>(),
      requirementIds: (fields[16] as List?)?.cast<String>(),
      relatedTaskIds: (fields[17] as List?)?.cast<String>(),
      relationTypes: (fields[18] as List?)?.cast<String>(),
      notes: (fields[19] as List?)?.cast<String>(),
      tags: (fields[20] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.projectId)
      ..writeByte(4)
      ..write(obj.taskType)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.deadline)
      ..writeByte(8)
      ..write(obj.estimatedMinutes)
      ..writeByte(9)
      ..write(obj.actualMinutes)
      ..writeByte(10)
      ..write(obj.difficulty)
      ..writeByte(11)
      ..write(obj.progress)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.priority)
      ..writeByte(14)
      ..write(obj.isUrgent)
      ..writeByte(15)
      ..write(obj.phaseIds)
      ..writeByte(16)
      ..write(obj.requirementIds)
      ..writeByte(17)
      ..write(obj.relatedTaskIds)
      ..writeByte(18)
      ..write(obj.relationTypes)
      ..writeByte(19)
      ..write(obj.notes)
      ..writeByte(20)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
