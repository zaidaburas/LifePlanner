import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';

class TaskTypesScreen extends StatefulWidget {
  const TaskTypesScreen({super.key});

  @override
  State<TaskTypesScreen> createState() => _TaskTypesScreenState();
}

class _TaskTypesScreenState extends State<TaskTypesScreen> {
  final _addCtrl = TextEditingController();
  final _editCtrl = TextEditingController();
  IconData _selectedIcon = Icons.label;

  @override
  void dispose() {
    _addCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'إدارة أنواع المهام',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Add new type
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('إضافة نوع جديد',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textPrimary)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addCtrl,
                        decoration: InputDecoration(
                          hintText: 'مثال: جامعة، رياضة، طبخ...',
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkBackground
                              : AppColors.background,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onSubmitted: (_) => _addType(context, provider),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => _showIconPicker(context),
                      icon: Icon(_selectedIcon, color: AppColors.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(12),
                      ),
                      tooltip: 'اختيار الأيقونة',
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _addType(context, provider),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('إضافة',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Built-in types
          Text('الأنواع الافتراضية',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: AppConstants.defaultTaskTypes
                  .asMap()
                  .entries
                  .map((entry) => _buildDefaultTypeTile(
                      entry.value,
                      AppConstants.defaultTaskTypeIcons[entry.key],
                      entry.key == AppConstants.defaultTaskTypes.length - 1,
                      isDark,
                      textPrimary))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Custom types
          if (provider.customTaskTypes.isNotEmpty) ...[
            Row(
              children: [
                Text('الأنواع المخصصة',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary)),
                const Spacer(),
                Text('${provider.customTaskTypes.length} نوع',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: provider.customTaskTypes
                  .asMap()
                  .entries
                  .map((entry) => _buildCustomTypeTile(
                      entry.value,
                      entry.key == provider.customTaskTypes.length - 1,
                      isDark,
                      textPrimary,
                      context,
                      provider))
                  .toList(),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(Icons.category_outlined,
                      size: 40, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
                  const SizedBox(height: 8),
                  Text('لا توجد أنواع مخصصة بعد',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textHint,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('أضف نوعاً جديداً من الحقل أعلاه',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textHint,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDefaultTypeTile(
      String type, IconData icon, bool isLast, bool isDark, Color textPrimary) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.border,
                    width: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 18, color: AppColors.primary),
        ),
        title: Text(type,
            style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.statusCompleted.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('افتراضي',
              style: TextStyle(
                  color: AppColors.statusCompleted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildCustomTypeTile(
      TaskType type,
      bool isLast,
      bool isDark,
      Color textPrimary,
      BuildContext context,
      AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.border,
                    width: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(type.icon,
              size: 18, color: AppColors.secondary),
        ),
        title: Text(type.name,
            style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.primary),
              onPressed: () => _showEditDialog(context, type, provider),
              tooltip: 'تعديل',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 18, color: AppColors.accentRed),
              onPressed: () =>
                  _showDeleteDialog(context, type, provider),
              tooltip: 'حذف',
            ),
          ],
        ),
      ),
    );
  }

  void _addType(BuildContext context, AppProvider provider) async {
    final v = _addCtrl.text.trim();
    if (v.isEmpty) return;
    final newType = TaskType(v, _selectedIcon);
    if (provider.customTaskTypes.any((t) => t.name == v)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('النوع "$v" موجود بالفعل'),
          backgroundColor: AppColors.priorityMedium,
        ),
      );
      return;
    }
    await provider.addCustomTaskType(newType);
    _addCtrl.clear();
    _selectedIcon = Icons.label; // Reset to default
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة النوع "$v" بنجاح'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    }
  }

  void _showIconPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر أيقونة'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: AppConstants.availableIcons.length,
            itemBuilder: (context, index) {
              final icon = AppConstants.availableIcons[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedIcon = icon);
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, TaskType type, AppProvider provider) {
    _editCtrl.text = type.name;
    IconData selectedIcon = type.icon;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('تعديل النوع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'اسم النوع',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('الأيقونة:'),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showIconPickerForEdit(ctx, (icon) {
                      setState(() => selectedIcon = icon);
                    }),
                    icon: Icon(selectedIcon, color: AppColors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = _editCtrl.text.trim();
                if (newName.isEmpty) return;
                final newType = TaskType(newName, selectedIcon);
                await provider.editCustomTaskType(type, newType);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تعديل النوع إلى "$newName"'),
                      backgroundColor: AppColors.statusCompleted,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('حفظ',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPickerForEdit(BuildContext context, Function(IconData) onIconSelected) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر أيقونة'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: AppConstants.availableIcons.length,
            itemBuilder: (context, index) {
              final icon = AppConstants.availableIcons[index];
              return InkWell(
                onTap: () {
                  onIconSelected(icon);
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, TaskType type, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف النوع'),
        content: Text(
            'هل تريد حذف النوع "${type.name}"؟\n\nالمهام التي تستخدم هذا النوع ستحتفظ بالنوع القديم.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteCustomTaskType(type);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف النوع "${type.name}"'),
                    backgroundColor: AppColors.accentRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed),
            child: const Text('حذف',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
