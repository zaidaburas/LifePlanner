import 'package:flutter/material.dart';

class TaskType {
  final String name;
  final IconData icon;
  final Color color;

  const TaskType(this.name, this.icon, [this.color = Colors.blue]);

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon.codePoint,
        'color': color.value,
      };

  factory TaskType.fromJson(Map<String, dynamic> json) => TaskType(
        json['name'],
        IconData(json['icon'], fontFamily: 'MaterialIcons'),
        Color(json['color']),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskType &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

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

  // Default Task Type Icons
  static const List<IconData> defaultTaskTypeIcons = [
    Icons.school,
    Icons.code,
    Icons.account_balance,
    Icons.work,
    Icons.person,
    Icons.group,
    Icons.palette,
    Icons.self_improvement,
    Icons.more_horiz,
  ];

  // Available Icons for Custom Types
  static const List<Widget> availableIcons = [
    Icon(Icons.home,color: Colors.blue,),
    Icon(Icons.work,color: Colors.orange,),
    Icon(Icons.school,color: Colors.green,),
    Icon(Icons.code,color: Colors.purple,),
    Icon(Icons.palette,color: Colors.pink,),
    Icon(Icons.music_note,color: Colors.red,),
    Icon(Icons.sports_soccer,color: Colors.yellow,),
    Icon(Icons.restaurant,color: Colors.brown,),
    Icon(Icons.shopping_cart,color: Colors.cyan,),
    Icon(Icons.flight,color: Colors.indigo,),
    Icon(Icons.directions_car,color: Colors.teal,),
    Icon(Icons.local_hospital,color: Colors.red,),
    Icon(Icons.pets,color: Colors.green,),
    Icon(Icons.book,color: Colors.blue,),
    Icon(Icons.camera,color: Colors.purple,),
    Icon(Icons.phone,color: Colors.orange,),
    Icon(Icons.email,color: Colors.blue,),
    Icon(Icons.chat,color: Colors.green,),
    Icon(Icons.favorite,color: Colors.red,),
    Icon(Icons.star,color: Colors.yellow,),
    Icon(Icons.thumb_up,color: Colors.blue,),
    Icon(Icons.lightbulb,color: Colors.yellow,),
    Icon(Icons.warning,color: Colors.orange,),
    Icon(Icons.error,color: Colors.red,),
    Icon(Icons.check_circle,color: Colors.green,),
    Icon(Icons.cancel,color: Colors.red,),
    Icon(Icons.access_time,color: Colors.blue,),
    Icon(Icons.date_range,color: Colors.purple,),
    Icon(Icons.location_on,color: Colors.red,),
    Icon(Icons.attach_money,color: Colors.green,),
    Icon(Icons.security,color: Colors.orange,),
    Icon(Icons.settings,color: Colors.grey,),
    Icon(Icons.help,color: Colors.blue,),
    Icon(Icons.info,color: Colors.blue,),
    Icon(Icons.label,color: Colors.purple,),
    Icon(Icons.category,color: Colors.pink,),
    Icon(Icons.extension,color: Colors.brown,),
    Icon(Icons.build,color: Colors.indigo,),
        // تصحيح الأيقونات التي كانت بدون ألوان
    Icon(Icons.create, color: Colors.blueGrey,),
    Icon(Icons.edit, color: Colors.teal,),
    Icon(Icons.delete, color: Colors.redAccent,),
    Icon(Icons.share, color: Colors.lightBlue,),
    Icon(Icons.download, color: Colors.green,),
    Icon(Icons.upload, color: Colors.orange,),
    Icon(Icons.refresh, color: Colors.blue,),
    Icon(Icons.sync, color: Colors.indigo,),
    Icon(Icons.lock, color: Colors.grey,),
    Icon(Icons.visibility, color: Colors.cyan,),
    Icon(Icons.visibility_off, color: Colors.blueGrey,),
    Icon(Icons.search, color: Colors.black87,),
    Icon(Icons.filter_list, color: Colors.purple,),
    Icon(Icons.sort, color: Colors.brown,),
    Icon(Icons.more_vert, color: Colors.grey,),
    
    // تكملة السلسلة بأيقونات شائعة ومهمة
    Icon(Icons.more_horiz, color: Colors.grey,),
    Icon(Icons.menu, color: Colors.black87,),
    Icon(Icons.arrow_back, color: Colors.black87,),
    Icon(Icons.arrow_forward, color: Colors.black87,),
    Icon(Icons.arrow_upward, color: Colors.blue,),
    Icon(Icons.arrow_downward, color: Colors.red,),
    Icon(Icons.add, color: Colors.green,),
    Icon(Icons.remove, color: Colors.red,),
    Icon(Icons.add_circle, color: Colors.green,),
    Icon(Icons.remove_circle, color: Colors.red,),
    Icon(Icons.play_arrow, color: Colors.green,),
    Icon(Icons.pause, color: Colors.orange,),
    Icon(Icons.stop, color: Colors.red,),
    Icon(Icons.volume_up, color: Colors.blue,),
    Icon(Icons.volume_off, color: Colors.grey,),
    Icon(Icons.wifi, color: Colors.blue,),
    Icon(Icons.wifi_off, color: Colors.grey,),
    Icon(Icons.battery_full, color: Colors.green,),
    Icon(Icons.battery_alert, color: Colors.red,),
    Icon(Icons.bluetooth, color: Colors.blue,),

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
