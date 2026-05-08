import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/phase_model.dart';
import '../models/obstacle_model.dart';
import '../../core/constants/app_constants.dart';

class AppRepository {
  // ─── GOALS ───────────────────────────────────────────────────────────────
  Box<GoalModel> get _goalsBox => Hive.box<GoalModel>(AppConstants.goalsBox);
  Box<ProjectModel> get _projectsBox => Hive.box<ProjectModel>(AppConstants.projectsBox);
  Box<TaskModel> get _tasksBox => Hive.box<TaskModel>(AppConstants.tasksBox);
  Box<PhaseModel> get _phasesBox => Hive.box<PhaseModel>(AppConstants.phasesBox);
  Box<ObstacleModel> get _obstaclesBox => Hive.box<ObstacleModel>(AppConstants.obstaclesBox);

  // ─── Goals ───
  List<GoalModel> getAllGoals() => _goalsBox.values.toList();
  GoalModel? getGoal(String id) => _goalsBox.get(id);
  Future<void> saveGoal(GoalModel goal) => _goalsBox.put(goal.id, goal);
  Future<void> deleteGoal(String id) async {
    final goal = _goalsBox.get(id);
    if (goal != null) {
      for (final pid in goal.projectIds) {
        await deleteProject(pid);
      }
    }
    await _goalsBox.delete(id);
  }

  // ─── Projects ───
  List<ProjectModel> getAllProjects() => _projectsBox.values.toList();
  List<ProjectModel> getProjectsByGoal(String goalId) =>
      _projectsBox.values.where((p) => p.goalId == goalId).toList();
  ProjectModel? getProject(String id) => _projectsBox.get(id);
  Future<void> saveProject(ProjectModel project) => _projectsBox.put(project.id, project);
  Future<void> deleteProject(String id) async {
    final project = _projectsBox.get(id);
    if (project != null) {
      for (final tid in project.taskIds) {
        await deleteTask(tid);
      }
    }
    await _projectsBox.delete(id);
  }

  // ─── Tasks ───
  List<TaskModel> getAllTasks() => _tasksBox.values.toList();
  List<TaskModel> getTasksByProject(String projectId) =>
      _tasksBox.values.where((t) => t.projectId == projectId).toList();
  TaskModel? getTask(String id) => _tasksBox.get(id);
  Future<void> saveTask(TaskModel task) => _tasksBox.put(task.id, task);
  Future<void> deleteTask(String id) async {
    final task = _tasksBox.get(id);
    if (task != null) {
      for (final phId in task.phaseIds) {
        await _phasesBox.delete(phId);
      }
    }
    await _tasksBox.delete(id);
  }

  // ─── Phases ───
  List<PhaseModel> getAllPhases() => _phasesBox.values.toList();
  List<PhaseModel> getPhasesByTask(String taskId) =>
      _phasesBox.values.where((p) => p.taskId == taskId).toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  PhaseModel? getPhase(String id) => _phasesBox.get(id);
  Future<void> savePhase(PhaseModel phase) => _phasesBox.put(phase.id, phase);
  Future<void> deletePhase(String id) => _phasesBox.delete(id);

  // ─── Obstacles ───
  List<ObstacleModel> getAllObstacles() => _obstaclesBox.values.toList();
  List<ObstacleModel> getObstaclesByLinkedId(String linkedId) =>
      _obstaclesBox.values.where((o) => o.linkedId == linkedId).toList();
  Future<void> saveObstacle(ObstacleModel obstacle) =>
      _obstaclesBox.put(obstacle.id, obstacle);
  Future<void> deleteObstacle(String id) => _obstaclesBox.delete(id);

  // ─── Recalculate Progress ───
  Future<void> recalcTaskProgress(String taskId) async {
    final task = getTask(taskId);
    if (task == null) return;
    final phases = getPhasesByTask(taskId);
    if (phases.isEmpty) return;
    final avg = phases.fold(0.0, (s, p) => s + p.progress) / phases.length;
    task.progress = avg;
    await saveTask(task);
    await recalcProjectProgress(task.projectId);
  }

  Future<void> recalcProjectProgress(String projectId) async {
    final project = getProject(projectId);
    if (project == null) return;
    final tasks = getTasksByProject(projectId);
    if (tasks.isEmpty) return;
    final avg = tasks.fold(0.0, (s, t) => s + t.progress) / tasks.length;
    project.progress = avg;
    await saveProject(project);
    await recalcGoalProgress(project.goalId);
  }

  Future<void> recalcGoalProgress(String goalId) async {
    final goal = getGoal(goalId);
    if (goal == null) return;
    final projects = getProjectsByGoal(goalId);
    if (projects.isEmpty) return;
    final avg = projects.fold(0.0, (s, p) => s + p.progress) / projects.length;
    goal.progress = avg;
    await saveGoal(goal);
  }

  // ─── Stats ───
  Map<String, dynamic> getDashboardStats() {
    final tasks = getAllTasks();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status == 'مكتملة').length;
    final inProgressTasks = tasks.where((t) => t.status == 'قيد التنفيذ').length;
    final overdueTasks = tasks.where((t) =>
        t.deadline != null &&
        t.deadline!.isBefore(today) &&
        t.status != 'مكتملة').length;
    final urgentTasks = tasks.where((t) =>
        t.isUrgent && t.status != 'مكتملة').length;
    final totalMinutes = tasks.fold(0, (s, t) => s + t.actualMinutes);
    final completionRate = totalTasks > 0
        ? (completedTasks / totalTasks * 100).round()
        : 0;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'inProgressTasks': inProgressTasks,
      'overdueTasks': overdueTasks,
      'urgentTasks': urgentTasks,
      'totalMinutes': totalMinutes,
      'completionRate': completionRate,
      'totalProjects': getAllProjects().length,
      'totalGoals': getAllGoals().length,
    };
  }
}
