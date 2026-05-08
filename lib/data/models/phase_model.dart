import 'package:hive/hive.dart';

part 'phase_model.g.dart';

@HiveType(typeId: 3)
class PhaseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String taskId;

  @HiveField(3)
  double progress;

  @HiveField(4)
  String status;

  @HiveField(5)
  String notes;

  @HiveField(6)
  List<String> checklist;

  @HiveField(7)
  List<bool> checklistDone;

  @HiveField(8)
  int timeSpentMinutes;

  @HiveField(9)
  int orderIndex;

  PhaseModel({
    required this.id,
    required this.title,
    required this.taskId,
    this.progress = 0.0,
    required this.status,
    this.notes = '',
    List<String>? checklist,
    List<bool>? checklistDone,
    this.timeSpentMinutes = 0,
    this.orderIndex = 0,
  })  : checklist = checklist ?? [],
        checklistDone = checklistDone ?? [];
}
