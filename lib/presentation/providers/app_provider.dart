import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/goal_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/task_model.dart';
import '../../data/models/phase_model.dart';
import '../../data/models/obstacle_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../core/constants/app_constants.dart';

class AppProvider extends ChangeNotifier {
  final AppRepository _repo = AppRepository();
  final _uuid = const Uuid();

  // State
  List<GoalModel> _goals = [];
  List<ProjectModel> _projects = [];
  List<TaskModel> _tasks = [];
  List<PhaseModel> _phases = [];
  List<ObstacleModel> _obstacles = [];
  bool _isDarkMode = false;
  String _searchQuery = '';
  String _filterStatus = '';
  String _filterType = '';
  int _sortMode = 0;

  // Custom Task Types
  List<String> _customTaskTypes = [];

  // Getters
  List<GoalModel> get goals => _goals;
  List<ProjectModel> get projects => _projects;
  List<TaskModel> get tasks => _tasks;
  List<PhaseModel> get phases => _phases;
  List<ObstacleModel> get obstacles => _obstacles;
  bool get isDarkMode => _isDarkMode;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  String get filterType => _filterType;
  int get sortMode => _sortMode;

  List<String> get allTaskTypes {
    final merged = List<String>.from(AppConstants.defaultTaskTypes);
    for (final t in _customTaskTypes) {
      if (!merged.contains(t)) merged.add(t);
    }
    return merged;
  }

  List<String> get customTaskTypes => List.unmodifiable(_customTaskTypes);

  GoalModel? getGoal(String id) => _goals.where((g) => g.id == id).firstOrNull;
  ProjectModel? getProject(String id) =>
      _projects.where((p) => p.id == id).firstOrNull;
  TaskModel? getTask(String id) => _tasks.where((t) => t.id == id).firstOrNull;
  PhaseModel? getPhase(String id) =>
      _phases.where((p) => p.id == id).firstOrNull;

  // ─── Init ───
  Future<void> init() async {
    await _loadPrefs();
    loadAll();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      final stored = prefs.getStringList(AppConstants.customTypesKey) ?? [];
      _customTaskTypes = stored;
    } catch (_) {}
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setStringList(AppConstants.customTypesKey, _customTaskTypes);
    } catch (_) {}
  }

  void loadAll() {
    _goals = _repo.getAllGoals();
    _projects = _repo.getAllProjects();
    _tasks = _repo.getAllTasks();
    _phases = _repo.getAllPhases();
    _obstacles = _repo.getAllObstacles();
    notifyListeners();
  }

  // ─── Theme ───
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _savePrefs();
    notifyListeners();
  }

  // ─── Search & Filter ───
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterStatus(String s) {
    _filterStatus = s;
    notifyListeners();
  }

  void setFilterType(String t) {
    _filterType = t;
    notifyListeners();
  }

  void setSortMode(int mode) {
    _sortMode = mode;
    notifyListeners();
  }

  List<TaskModel> get filteredTasks {
    var result = List<TaskModel>.from(_tasks);
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_filterStatus.isNotEmpty) {
      result = result.where((t) => t.status == _filterStatus).toList();
    }
    if (_filterType.isNotEmpty) {
      result = result.where((t) => t.taskType == _filterType).toList();
    }
    switch (_sortMode) {
      case 0:
        result.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 1:
        result.sort((a, b) {
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
      case 2:
        result.sort((a, b) => b.progress.compareTo(a.progress));
        break;
    }
    return result;
  }

  List<TaskModel> get urgentTasks =>
      _tasks.where((t) => t.isUrgent && t.status != 'مكتملة').toList();

  List<TaskModel> get overdueTasks {
    final now = DateTime.now();
    return _tasks
        .where((t) =>
            t.deadline != null &&
            t.deadline!.isBefore(now) &&
            t.status != 'مكتملة')
        .toList();
  }

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _tasks
        .where((t) =>
            t.deadline != null &&
            !t.deadline!.isBefore(today) &&
            t.deadline!.isBefore(tomorrow) &&
            t.status != 'مكتملة')
        .toList();
  }

  Map<String, dynamic> get dashboardStats => _repo.getDashboardStats();

  // ─── Custom Task Types ───
  Future<void> addCustomTaskType(String type) async {
    if (type.trim().isEmpty) return;
    if (!_customTaskTypes.contains(type.trim())) {
      _customTaskTypes.add(type.trim());
      await _savePrefs();
      notifyListeners();
    }
  }

  Future<void> editCustomTaskType(String oldType, String newType) async {
    if (newType.trim().isEmpty) return;
    final idx = _customTaskTypes.indexOf(oldType);
    if (idx >= 0) {
      // Update tasks that use this type
      for (final t in _tasks) {
        if (t.taskType == oldType) {
          t.taskType = newType.trim();
          await _repo.saveTask(t);
        }
      }
      _customTaskTypes[idx] = newType.trim();
      await _savePrefs();
      loadAll();
    }
  }

  Future<void> deleteCustomTaskType(String type) async {
    _customTaskTypes.remove(type);
    await _savePrefs();
    notifyListeners();
  }

  // ─── GOALS CRUD ───
  Future<void> addGoal({
    required String title,
    required String description,
    DateTime? deadline,
    required int colorIndex,
    String? iconName,
  }) async {
    final goal = GoalModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      deadline: deadline,
      status: AppConstants.statusNotStarted,
      colorIndex: colorIndex,
      iconName: iconName,
    );
    await _repo.saveGoal(goal);
    loadAll();
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _repo.saveGoal(goal);
    loadAll();
  }

  Future<void> deleteGoal(String id) async {
    await _repo.deleteGoal(id);
    loadAll();
  }

  // ─── PROJECTS CRUD ───
  Future<void> addProject({
    required String title,
    required String description,
    required String goalId,
    DateTime? deadline,
    required int colorIndex,
    int priority = 5,
  }) async {
    final project = ProjectModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      goalId: goalId,
      createdAt: DateTime.now(),
      deadline: deadline,
      status: AppConstants.statusNotStarted,
      colorIndex: colorIndex,
      priority: priority,
    );
    await _repo.saveProject(project);
    final goal = _repo.getGoal(goalId);
    if (goal != null) {
      goal.projectIds.add(project.id);
      await _repo.saveGoal(goal);
    }
    loadAll();
  }

  Future<void> updateProject(ProjectModel project) async {
    await _repo.saveProject(project);
    await _repo.recalcGoalProgress(project.goalId);
    loadAll();
  }

  Future<void> deleteProject(String id) async {
    await _repo.deleteProject(id);
    loadAll();
  }

  // ─── TASKS CRUD ───
  Future<void> addTask({
    required String title,
    required String description,
    required String projectId,
    required String taskType,
    String category = '',
    DateTime? deadline,
    int estimatedMinutes = 60,
    String difficulty = 'متوسط',
    int priority = 5,
    bool isUrgent = false,
    List<String>? tags,
    bool addDefaultPhases = true,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      projectId: projectId,
      taskType: taskType,
      category: category,
      createdAt: DateTime.now(),
      deadline: deadline,
      estimatedMinutes: estimatedMinutes,
      difficulty: difficulty,
      status: AppConstants.statusNotStarted,
      priority: priority,
      isUrgent: isUrgent,
      tags: tags,
    );
    await _repo.saveTask(task);

    final project = _repo.getProject(projectId);
    if (project != null) {
      project.taskIds.add(task.id);
      await _repo.saveProject(project);
    }

    if (addDefaultPhases) {
      for (int i = 0; i < AppConstants.defaultPhases.length; i++) {
        final phase = PhaseModel(
          id: _uuid.v4(),
          title: AppConstants.defaultPhases[i],
          taskId: task.id,
          status: AppConstants.statusNotStarted,
          orderIndex: i,
        );
        await _repo.savePhase(phase);
        task.phaseIds.add(phase.id);
      }
      await _repo.saveTask(task);
    }
    loadAll();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repo.saveTask(task);
    await _repo.recalcProjectProgress(task.projectId);
    loadAll();
  }

  Future<void> deleteTask(String id) async {
    await _repo.deleteTask(id);
    loadAll();
  }

  // ─── PHASES CRUD ───
  Future<void> addPhase({
    required String title,
    required String taskId,
    int orderIndex = 0,
    String notes = '',
    List<String>? checklist,
  }) async {
    final phase = PhaseModel(
      id: _uuid.v4(),
      title: title,
      taskId: taskId,
      status: AppConstants.statusNotStarted,
      orderIndex: orderIndex,
      notes: notes,
      checklist: checklist ?? [],
      checklistDone:
          checklist != null ? List.filled(checklist.length, false) : [],
    );
    await _repo.savePhase(phase);
    final task = _repo.getTask(taskId);
    if (task != null) {
      task.phaseIds.add(phase.id);
      await _repo.saveTask(task);
    }
    loadAll();
  }

  Future<void> updatePhase(PhaseModel phase) async {
    await _repo.savePhase(phase);
    await _repo.recalcTaskProgress(phase.taskId);
    loadAll();
  }

  Future<void> deletePhase(String id) async {
    final phase = _repo.getPhase(id);
    if (phase != null) {
      final task = _repo.getTask(phase.taskId);
      if (task != null) {
        task.phaseIds.remove(id);
        await _repo.saveTask(task);
      }
    }
    await _repo.deletePhase(id);
    loadAll();
  }

  // ─── OBSTACLES CRUD ───
  Future<void> addObstacle({
    required String title,
    required String description,
    required String linkedId,
    required String linkedType,
    required String impactLevel,
    String impactDescription = '',
  }) async {
    final obstacle = ObstacleModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      linkedId: linkedId,
      linkedType: linkedType,
      occurredAt: DateTime.now(),
      impactLevel: impactLevel,
      impactDescription: impactDescription,
    );
    await _repo.saveObstacle(obstacle);
    loadAll();
  }

  Future<void> updateObstacle(ObstacleModel obstacle) async {
    await _repo.saveObstacle(obstacle);
    loadAll();
  }

  Future<void> deleteObstacle(String id) async {
    await _repo.deleteObstacle(id);
    loadAll();
  }

  // ─── Helpers ───
  List<ProjectModel> getProjectsForGoal(String goalId) =>
      _projects.where((p) => p.goalId == goalId).toList();

  List<TaskModel> getTasksForProject(String projectId) =>
      _tasks.where((t) => t.projectId == projectId).toList();

  List<PhaseModel> getPhasesForTask(String taskId) => _phases
      .where((p) => p.taskId == taskId)
      .toList()
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  List<ObstacleModel> getObstaclesForLinked(String linkedId) =>
      _obstacles.where((o) => o.linkedId == linkedId).toList();

  // ─── Analytics ───
  Map<String, dynamic> get dashboardStats2 => _repo.getDashboardStats();

  Map<String, int> get tasksByType {
    final map = <String, int>{};
    for (final t in _tasks) {
      map[t.taskType] = (map[t.taskType] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get timeByType {
    final map = <String, int>{};
    for (final t in _tasks) {
      map[t.taskType] = (map[t.taskType] ?? 0) + t.actualMinutes;
    }
    return map;
  }

  Map<String, int> get obstaclesByImpact {
    final map = <String, int>{};
    for (final o in _obstacles) {
      map[o.impactLevel] = (map[o.impactLevel] ?? 0) + 1;
    }
    return map;
  }

  List<Map<String, dynamic>> get weeklyProgress {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final completed = _tasks
          .where((t) =>
              t.status == 'مكتملة' &&
              t.createdAt.isAfter(dayStart) &&
              t.createdAt.isBefore(dayEnd))
          .length;
      result.add({'day': dayStart, 'completed': completed});
    }
    return result;
  }

  // ─── BACKUP & RESTORE ───
  Future<String> exportBackup() async {
    final data = {
      'version': AppConstants.appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'goals': _goals
          .map((g) => {
                'id': g.id,
                'title': g.title,
                'description': g.description,
                'createdAt': g.createdAt.toIso8601String(),
                'deadline': g.deadline?.toIso8601String(),
                'status': g.status,
                'colorIndex': g.colorIndex,
                'progress': g.progress,
                'projectIds': g.projectIds,
                'iconName': g.iconName,
              })
          .toList(),
      'projects': _projects
          .map((p) => {
                'id': p.id,
                'title': p.title,
                'description': p.description,
                'goalId': p.goalId,
                'createdAt': p.createdAt.toIso8601String(),
                'deadline': p.deadline?.toIso8601String(),
                'status': p.status,
                'colorIndex': p.colorIndex,
                'progress': p.progress,
                'priority': p.priority,
                'taskIds': p.taskIds,
              })
          .toList(),
      'tasks': _tasks
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'description': t.description,
                'projectId': t.projectId,
                'taskType': t.taskType,
                'category': t.category,
                'createdAt': t.createdAt.toIso8601String(),
                'deadline': t.deadline?.toIso8601String(),
                'estimatedMinutes': t.estimatedMinutes,
                'actualMinutes': t.actualMinutes,
                'difficulty': t.difficulty,
                'progress': t.progress,
                'status': t.status,
                'priority': t.priority,
                'isUrgent': t.isUrgent,
                'phaseIds': t.phaseIds,
                'requirementIds': t.requirementIds,
                'relatedTaskIds': t.relatedTaskIds,
                'relationTypes': t.relationTypes,
                'notes': t.notes,
                'tags': t.tags,
              })
          .toList(),
      'phases': _phases
          .map((p) => {
                'id': p.id,
                'title': p.title,
                'taskId': p.taskId,
                'progress': p.progress,
                'status': p.status,
                'notes': p.notes,
                'checklist': p.checklist,
                'checklistDone': p.checklistDone,
                'timeSpentMinutes': p.timeSpentMinutes,
                'orderIndex': p.orderIndex,
              })
          .toList(),
      'obstacles': _obstacles
          .map((o) => {
                'id': o.id,
                'title': o.title,
                'description': o.description,
                'linkedId': o.linkedId,
                'linkedType': o.linkedType,
                'occurredAt': o.occurredAt.toIso8601String(),
                'impactLevel': o.impactLevel,
                'impactDescription': o.impactDescription,
              })
          .toList(),
      'customTaskTypes': _customTaskTypes,
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    if (kIsWeb) {
      return jsonStr;
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File('${dir.path}/life_planner_backup_$timestamp.json');
    await file.writeAsString(jsonStr);
    return file.path;
  }

  Future<void> importBackup(String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Clear all data
    for (final g in List<GoalModel>.from(_goals)) {
      await _repo.deleteGoal(g.id);
    }

    // Import goals
    final goalsList = data['goals'] as List? ?? [];
    for (final gMap in goalsList) {
      final goal = GoalModel(
        id: gMap['id'],
        title: gMap['title'],
        description: gMap['description'] ?? '',
        createdAt: DateTime.parse(gMap['createdAt']),
        deadline:
            gMap['deadline'] != null ? DateTime.parse(gMap['deadline']) : null,
        status: gMap['status'] ?? AppConstants.statusNotStarted,
        colorIndex: gMap['colorIndex'] ?? 0,
        progress: (gMap['progress'] ?? 0.0).toDouble(),
        projectIds: List<String>.from(gMap['projectIds'] ?? []),
        iconName: gMap['iconName'],
      );
      await _repo.saveGoal(goal);
    }

    // Import projects
    final projectsList = data['projects'] as List? ?? [];
    for (final pMap in projectsList) {
      final project = ProjectModel(
        id: pMap['id'],
        title: pMap['title'],
        description: pMap['description'] ?? '',
        goalId: pMap['goalId'],
        createdAt: DateTime.parse(pMap['createdAt']),
        deadline:
            pMap['deadline'] != null ? DateTime.parse(pMap['deadline']) : null,
        status: pMap['status'] ?? AppConstants.statusNotStarted,
        colorIndex: pMap['colorIndex'] ?? 0,
        progress: (pMap['progress'] ?? 0.0).toDouble(),
        priority: pMap['priority'] ?? 5,
        taskIds: List<String>.from(pMap['taskIds'] ?? []),
      );
      await _repo.saveProject(project);
    }

    // Import tasks
    final tasksList = data['tasks'] as List? ?? [];
    for (final tMap in tasksList) {
      final task = TaskModel(
        id: tMap['id'],
        title: tMap['title'],
        description: tMap['description'] ?? '',
        projectId: tMap['projectId'],
        taskType: tMap['taskType'] ?? 'أخرى',
        category: tMap['category'] ?? '',
        createdAt: DateTime.parse(tMap['createdAt']),
        deadline:
            tMap['deadline'] != null ? DateTime.parse(tMap['deadline']) : null,
        estimatedMinutes: tMap['estimatedMinutes'] ?? 60,
        actualMinutes: tMap['actualMinutes'] ?? 0,
        difficulty: tMap['difficulty'] ?? 'متوسط',
        progress: (tMap['progress'] ?? 0.0).toDouble(),
        status: tMap['status'] ?? AppConstants.statusNotStarted,
        priority: tMap['priority'] ?? 5,
        isUrgent: tMap['isUrgent'] ?? false,
        phaseIds: List<String>.from(tMap['phaseIds'] ?? []),
        requirementIds: List<String>.from(tMap['requirementIds'] ?? []),
        relatedTaskIds: List<String>.from(tMap['relatedTaskIds'] ?? []),
        relationTypes: List<String>.from(tMap['relationTypes'] ?? []),
        notes: List<String>.from(tMap['notes'] ?? []),
        tags: List<String>.from(tMap['tags'] ?? []),
      );
      await _repo.saveTask(task);
    }

    // Import phases
    final phasesList = data['phases'] as List? ?? [];
    for (final pMap in phasesList) {
      final phase = PhaseModel(
        id: pMap['id'],
        title: pMap['title'],
        taskId: pMap['taskId'],
        progress: (pMap['progress'] ?? 0.0).toDouble(),
        status: pMap['status'] ?? AppConstants.statusNotStarted,
        notes: pMap['notes'] ?? '',
        checklist: List<String>.from(pMap['checklist'] ?? []),
        checklistDone: List<bool>.from(pMap['checklistDone'] ?? []),
        timeSpentMinutes: pMap['timeSpentMinutes'] ?? 0,
        orderIndex: pMap['orderIndex'] ?? 0,
      );
      await _repo.savePhase(phase);
    }

    // Import obstacles
    final obstaclesList = data['obstacles'] as List? ?? [];
    for (final oMap in obstaclesList) {
      final obstacle = ObstacleModel(
        id: oMap['id'],
        title: oMap['title'],
        description: oMap['description'] ?? '',
        linkedId: oMap['linkedId'],
        linkedType: oMap['linkedType'],
        occurredAt: DateTime.parse(oMap['occurredAt']),
        impactLevel: oMap['impactLevel'] ?? 'متوسط',
        impactDescription: oMap['impactDescription'] ?? '',
      );
      await _repo.saveObstacle(obstacle);
    }

    // Import custom types
    final customTypes = data['customTaskTypes'] as List? ?? [];
    _customTaskTypes = List<String>.from(customTypes);
    await _savePrefs();

    loadAll();
  }

  // ─── Seed Sample Data ───
  Future<void> seedSampleData() async {
    if (_goals.isNotEmpty) return;

    await addGoal(
      title: 'تطوير المهارات التقنية',
      description: 'إتقان Flutter وبناء تطبيقات احترافية',
      deadline: DateTime.now().add(const Duration(days: 180)),
      colorIndex: 0,
      iconName: 'code',
    );

    final goal1 = _goals.first;
    await addProject(
      title: 'تعلم Flutter المتقدم',
      description: 'دراسة Clean Architecture وإدارة الحالة',
      goalId: goal1.id,
      deadline: DateTime.now().add(const Duration(days: 60)),
      colorIndex: 0,
      priority: 9,
    );

    final proj1 = _projects.first;
    await addTask(
      title: 'دراسة Provider & Riverpod',
      description: 'فهم إدارة الحالة في Flutter بشكل كامل',
      projectId: proj1.id,
      taskType: 'تعلم',
      category: 'برمجة',
      deadline: DateTime.now().add(const Duration(days: 14)),
      estimatedMinutes: 300,
      difficulty: 'متوسط',
      priority: 8,
      isUrgent: true,
      tags: ['Flutter', 'State Management'],
    );

    await addGoal(
      title: 'الصحة واللياقة البدنية',
      description: 'الحفاظ على نمط حياة صحي ومتوازن',
      deadline: DateTime.now().add(const Duration(days: 365)),
      colorIndex: 2,
      iconName: 'fitness',
    );

    if (_tasks.isNotEmpty) {
      await addObstacle(
        title: 'انقطاع الإنترنت',
        description: 'انقطع الاتصال خلال جلسة التعلم',
        linkedId: _tasks.first.id,
        linkedType: 'task',
        impactLevel: 'متوسط',
        impactDescription: 'تأخر الإنجاز بيوم كامل',
      );
    }
  }
}
