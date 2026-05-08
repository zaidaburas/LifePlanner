import 'package:hive/hive.dart';

part 'obstacle_model.g.dart';

@HiveType(typeId: 4)
class ObstacleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String linkedId; // taskId or projectId

  @HiveField(4)
  String linkedType; // 'task' or 'project'

  @HiveField(5)
  DateTime occurredAt;

  @HiveField(6)
  String impactLevel; // منخفض، متوسط، عالي، حرج

  @HiveField(7)
  String impactDescription;

  @HiveField(8)
  String solution;

  @HiveField(9)
  bool isResolved;

  ObstacleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.linkedId,
    required this.linkedType,
    required this.occurredAt,
    required this.impactLevel,
    this.impactDescription = '',
    this.solution = '',
    this.isResolved = false,
  });
}
