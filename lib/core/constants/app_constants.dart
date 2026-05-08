class AppConstants {
  static const String appName = 'Life Planner';
  static const String appVersion = '1.1.0';

  // Hive Box Names
  static const String goalsBox = 'goals_box';
  static const String projectsBox = 'projects_box';
  static const String tasksBox = 'tasks_box';
  static const String phasesBox = 'phases_box';
  static const String obstaclesBox = 'obstacles_box';
  static const String settingsBox = 'settings_box';

  // Default Task Types (يمكن تعديلها)
  static const List<String> defaultTaskTypes = [
    'تعلم',
    'برمجة',
    'جامعة',
    'عمل',
    'شخصي',
    'شبكة',
    'تصميم',
    'تطوير ذات',
    'أخرى',
  ];

  // Shared Preferences Keys
  static const String customTypesKey = 'custom_task_types';

  // Task Statuses
  static const String statusNotStarted = 'لم تبدأ';
  static const String statusInProgress = 'قيد التنفيذ';
  static const String statusPaused = 'متوقفة';
  static const String statusCompleted = 'مكتملة';

  static const List<String> taskStatuses = [
    statusNotStarted,
    statusInProgress,
    statusPaused,
    statusCompleted,
  ];

  // Difficulty Levels
  static const List<String> difficultyLevels = [
    'سهل',
    'متوسط',
    'صعب',
    'متقدم',
  ];

  // Relation Types
  static const String relDepends = 'تعتمد على';
  static const String relRelated = 'مرتبطة';
  static const String relOptional = 'اختيارية';
  static const String relMustFinishFirst = 'يجب إنهاؤها أولاً';

  static const List<String> relationTypes = [
    relDepends,
    relRelated,
    relOptional,
    relMustFinishFirst,
  ];

  // Default Phase Names
  static const List<String> defaultPhases = [
    'بحث',
    'تخطيط',
    'تجهيز',
    'تنفيذ',
    'اختبار',
    'إنهاء',
  ];

  // Impact Levels
  static const List<String> impactLevels = [
    'منخفض',
    'متوسط',
    'عالي',
    'حرج',
  ];

  // Goal Colors
  static const List<int> goalColors = [
    0xFF6366F1, // Indigo
    0xFF8B5CF6, // Purple
    0xFF06B6D4, // Cyan
    0xFF10B981, // Emerald
    0xFFF59E0B, // Amber
    0xFFEF4444, // Red
    0xFFF97316, // Orange
    0xFF84CC16, // Lime
    0xFF14B8A6, // Teal
    0xFFEC4899, // Pink
  ];
}
