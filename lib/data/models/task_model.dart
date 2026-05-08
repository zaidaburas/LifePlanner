import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String projectId;

  @HiveField(4)
  String taskType;

  @HiveField(5)
  String category;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? deadline;

  @HiveField(8)
  int estimatedMinutes;

  @HiveField(9)
  int actualMinutes;

  @HiveField(10)
  String difficulty;

  @HiveField(11)
  double progress;

  @HiveField(12)
  String status;

  @HiveField(13)
  int priority;

  @HiveField(14)
  bool isUrgent;

  @HiveField(15)
  List<String> phaseIds;

  @HiveField(16)
  List<String> requirementIds;

  @HiveField(17)
  List<String> relatedTaskIds;

  @HiveField(18)
  List<String> relationTypes;

  @HiveField(19)
  List<String> notes;

  @HiveField(20)
  List<String> tags;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.taskType,
    required this.category,
    required this.createdAt,
    this.deadline,
    this.estimatedMinutes = 60,
    this.actualMinutes = 0,
    required this.difficulty,
    this.progress = 0.0,
    required this.status,
    this.priority = 5,
    this.isUrgent = false,
    List<String>? phaseIds,
    List<String>? requirementIds,
    List<String>? relatedTaskIds,
    List<String>? relationTypes,
    List<String>? notes,
    List<String>? tags,
  })  : phaseIds = phaseIds ?? [],
        requirementIds = requirementIds ?? [],
        relatedTaskIds = relatedTaskIds ?? [],
        relationTypes = relationTypes ?? [],
        notes = notes ?? [],
        tags = tags ?? [];
}
