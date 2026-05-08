import 'package:hive/hive.dart';

part 'project_model.g.dart';

@HiveType(typeId: 1)
class ProjectModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String goalId;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? deadline;

  @HiveField(6)
  String status;

  @HiveField(7)
  int colorIndex;

  @HiveField(8)
  double progress;

  @HiveField(9)
  List<String> taskIds;

  @HiveField(10)
  int priority;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.goalId,
    required this.createdAt,
    this.deadline,
    required this.status,
    required this.colorIndex,
    this.progress = 0.0,
    List<String>? taskIds,
    this.priority = 5,
  }) : taskIds = taskIds ?? [];
}
