import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../providers/app_provider.dart';
import 'task_types_screen.dart';
import 'backup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('الإعدادات',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    )),
            const SizedBox(height: 20),

            // Appearance
            _sectionTitle('المظهر', isDark),
            AppCard(
              child: Column(
                children: [
                  _settingTile(
                    icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    title: 'الوضع الليلي',
                    subtitle: isDark ? 'وضع داكن مفعّل' : 'وضع فاتح مفعّل',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) => provider.toggleTheme(),
                      activeColor: AppColors.primary,
                    ),
                    iconColor: isDark ? AppColors.secondaryLight : AppColors.accentIndigo,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customization
            _sectionTitle('التخصيص', isDark),
            AppCard(
              child: Column(
                children: [
                  _settingTile(
                    icon: Icons.category_rounded,
                    title: 'إدارة أنواع المهام',
                    subtitle: 'إضافة وتعديل وحذف أنواع مخصصة',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TaskTypesScreen()),
                    ),
                    iconColor: AppColors.accentPurple,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Backup & Restore
            _sectionTitle('النسخ الاحتياطي', isDark),
            AppCard(
              child: Column(
                children: [
                  _settingTile(
                    icon: Icons.backup_rounded,
                    title: 'النسخ الاحتياطي والاستعادة',
                    subtitle: 'تصدير واستيراد جميع بياناتك',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BackupScreen()),
                    ),
                    iconColor: AppColors.accentBlue,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Data
            _sectionTitle('البيانات', isDark),
            AppCard(
              child: Column(
                children: [
                  _settingTile(
                    icon: Icons.refresh_rounded,
                    title: 'تحميل بيانات تجريبية',
                    subtitle: 'إضافة أهداف ومشاريع ومهام تجريبية',
                    onTap: () => _confirmSeedData(context, provider),
                    iconColor: AppColors.accentGreen,
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _settingTile(
                    icon: Icons.delete_sweep_rounded,
                    title: 'حذف جميع البيانات',
                    subtitle: 'حذف كامل للأهداف والمشاريع والمهام',
                    onTap: () => _confirmClearData(context, provider),
                    iconColor: AppColors.priorityCritical,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats summary
            _sectionTitle('ملخص البيانات', isDark),
            AppCard(
              child: Column(
                children: [
                  _statsRow('الأهداف', '${provider.goals.length}', Icons.flag_rounded, AppColors.accentPurple, isDark),
                  const Divider(height: 1),
                  _statsRow('المشاريع', '${provider.projects.length}', Icons.folder_rounded, AppColors.accentBlue, isDark),
                  const Divider(height: 1),
                  _statsRow('المهام', '${provider.tasks.length}', Icons.task_alt, AppColors.primary, isDark),
                  const Divider(height: 1),
                  _statsRow('المراحل', '${provider.phases.length}', Icons.linear_scale_rounded, AppColors.secondary, isDark),
                  const Divider(height: 1),
                  _statsRow('العوائق', '${provider.obstacles.length}', Icons.warning_amber_rounded, AppColors.priorityHigh, isDark),
                  const Divider(height: 1),
                  _statsRow('الأنواع المخصصة', '${provider.customTaskTypes.length}', Icons.category_rounded, AppColors.accentPurple, isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About
            _sectionTitle('حول التطبيق', isDark),
            AppCard(
              child: Column(
                children: [
                  _settingTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Life Planner',
                    subtitle: 'الإصدار 1.1.0 — مخطط الحياة الاحترافي',
                    iconColor: AppColors.primary,
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _settingTile(
                    icon: Icons.star_rounded,
                    title: 'المميزات',
                    subtitle: 'أهداف • مشاريع • مهام • مراحل • تحليلات • نسخ احتياطي',
                    iconColor: AppColors.secondaryLight,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary)),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textHint)
              : null),
    );
  }

  Widget _statsRow(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _confirmSeedData(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تحميل بيانات تجريبية'),
        content: const Text(
            'سيتم إضافة بيانات تجريبية إلى التطبيق. هل تريد المتابعة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await provider.seedSampleData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم تحميل البيانات التجريبية!'),
                    backgroundColor: AppColors.statusCompleted,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: const Text('تحميل'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف جميع البيانات',
            style: TextStyle(color: Colors.red)),
        content: const Text(
            'سيتم حذف جميع الأهداف والمشاريع والمهام والمراحل. هذا الإجراء لا يمكن التراجع عنه!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final goals = List.from(provider.goals);
              for (final g in goals) {
                await provider.deleteGoal(g.id);
              }
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم حذف جميع البيانات'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }
}
