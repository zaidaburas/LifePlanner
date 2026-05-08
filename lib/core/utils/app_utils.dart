import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppUtils {
  static String formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}د';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}س' : '${h}س ${m}د';
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    final now = DateTime.now();
    final diff = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'غداً';
    if (diff == -1) return 'أمس';
    if (diff < 0) return 'متأخر ${-diff} يوم';
    if (diff < 7) return 'بعد $diff أيام';
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatFullDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'لم تبدأ':
        return AppColors.statusNotStarted;
      case 'قيد التنفيذ':
        return AppColors.statusInProgress;
      case 'متوقفة':
        return AppColors.statusPaused;
      case 'مكتملة':
        return AppColors.statusCompleted;
      default:
        return AppColors.statusNotStarted;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'لم تبدأ':
        return Icons.radio_button_unchecked;
      case 'قيد التنفيذ':
        return Icons.timelapse;
      case 'متوقفة':
        return Icons.pause_circle_outline;
      case 'مكتملة':
        return Icons.check_circle;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  static Color getPriorityColor(int priority) {
    if (priority >= 9) return AppColors.priorityCritical;
    if (priority >= 7) return AppColors.priorityHigh;
    if (priority >= 4) return AppColors.priorityMedium;
    return AppColors.priorityLow;
  }

  static String getPriorityLabel(int priority) {
    if (priority >= 9) return 'حرج';
    if (priority >= 7) return 'عالي';
    if (priority >= 4) return 'متوسط';
    return 'منخفض';
  }

  static Color getImpactColor(String level) {
    switch (level) {
      case 'منخفض':
        return AppColors.priorityLow;
      case 'متوسط':
        return AppColors.priorityMedium;
      case 'عالي':
        return AppColors.priorityHigh;
      case 'حرج':
        return AppColors.priorityCritical;
      default:
        return AppColors.priorityMedium;
    }
  }

  static Color getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'سهل':
        return AppColors.priorityLow;
      case 'متوسط':
        return AppColors.priorityMedium;
      case 'صعب':
        return AppColors.priorityHigh;
      case 'متقدم':
        return AppColors.priorityCritical;
      default:
        return AppColors.priorityMedium;
    }
  }

  static Color getTaskTypeColor(String type) {
    return AppColors.taskTypeColors[type] ?? AppColors.textSecondary;
  }

  static IconData getTaskTypeIcon(String type) {
    switch (type) {
      case 'تعلم':
        return Icons.school;
      case 'برمجة':
        return Icons.code;
      case 'جامعة':
        return Icons.account_balance;
      case 'عمل':
        return Icons.work;
      case 'شخصي':
        return Icons.person;
      case 'شبكة':
        return Icons.hub;
      case 'تصميم':
        return Icons.design_services;
      case 'تطوير ذات':
        return Icons.self_improvement;
      default:
        return Icons.task_alt;
    }
  }

  static List<Color> goalColors = [
    const Color(0xFF00897B),
    const Color(0xFF1565C0),
    const Color(0xFF6A1B9A),
    const Color(0xFFE65100),
    const Color(0xFFAD1457),
    const Color(0xFF2E7D32),
    const Color(0xFF283593),
    const Color(0xFF4527A0),
    const Color(0xFF558B2F),
    const Color(0xFF00838F),
  ];

  static Color goalColor(int index) {
    return goalColors[index % goalColors.length];
  }
}
