import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 0)
class GoalModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? deadline;

  @HiveField(5)
  String status; // لم تبدأ، قيد التنفيذ، مكتملة

  @HiveField(6)
  int colorIndex;

  @HiveField(7)
  double progress;

  @HiveField(8)
  List<String> projectIds;

  @HiveField(9)
  String? iconName;

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.deadline,
    required this.status,
    required this.colorIndex,
    this.progress = 0.0,
    List<String>? projectIds,
    this.iconName,
  }) : projectIds = projectIds ?? [];
}
