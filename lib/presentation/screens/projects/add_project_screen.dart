import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../providers/app_provider.dart';

class AddProjectScreen extends StatefulWidget {
  final String? preselectedGoalId;
  const AddProjectScreen({super.key, this.preselectedGoalId});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _goalId;
  DateTime? _deadline;
  int _colorIndex = 0;
  int _priority = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _goalId = widget.preselectedGoalId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('مشروع جديد'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label('📁 اسم المشروع'),
            TextFormField(
              controller: _titleCtrl,
              validator: (v) => v == null || v.trim().isEmpty ? 'الاسم مطلوب' : null,
              decoration: const InputDecoration(hintText: 'أدخل اسم المشروع...', prefixIcon: Icon(Icons.folder_rounded)),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 16),
            _label('📋 الوصف'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'وصف المشروع...', prefixIcon: Icon(Icons.description_rounded), alignLabelWithHint: true),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 16),
            _label('🎯 الهدف الرئيسي'),
            DropdownButtonFormField<String>(
              value: _goalId,
              validator: (v) => v == null ? 'اختر هدفاً' : null,
              hint: const Text('اختر الهدف', style: TextStyle(fontFamily: 'Cairo')),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.flag_rounded)),
              items: provider.goals.map((g) {
                final c = AppUtils.goalColor(g.colorIndex);
                return DropdownMenuItem(
                  value: g.id,
                  child: Row(
                    children: [
                      Icon(Icons.flag_rounded, size: 16, color: c),
                      const SizedBox(width: 8),
                      Text(g.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _goalId = v),
            ),
            const SizedBox(height: 16),
            _label('🎨 اللون'),
            const SizedBox(height: 8),
            ColorPickerRow(selectedIndex: _colorIndex, onChanged: (i) => setState(() => _colorIndex = i)),
            const SizedBox(height: 16),
            _label('🚩 الأولوية: P$_priority - ${AppUtils.getPriorityLabel(_priority)}'),
            Slider(
              value: _priority.toDouble(),
              min: 1, max: 10, divisions: 9,
              label: 'P$_priority',
              activeColor: AppUtils.getPriorityColor(_priority),
              onChanged: (v) => setState(() => _priority = v.round()),
            ),
            const SizedBox(height: 8),
            _label('📅 الموعد النهائي'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                    child: child!,
                  ),
                );
                if (date != null) setState(() => _deadline = date);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _deadline != null ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.border)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_rounded, color: _deadline != null ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _deadline != null ? AppUtils.formatFullDate(_deadline) : 'اختر تاريخاً',
                      style: TextStyle(fontSize: 14, color: _deadline != null ? AppColors.primary : AppColors.textSecondary, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            GradientButton(
              label: 'إنشاء المشروع',
              icon: Icons.folder_rounded,
              isLoading: _isLoading,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    await provider.addProject(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      goalId: _goalId!,
      deadline: _deadline,
      colorIndex: _colorIndex,
      priority: _priority,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ تم إنشاء المشروع بنجاح!', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.statusCompleted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
