import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../providers/app_provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _deadline;
  int _colorIndex = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('هدف جديد'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Preview card
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppUtils.goalColor(_colorIndex),
                    AppUtils.goalColor(_colorIndex).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _titleCtrl.text.isEmpty ? 'اسم الهدف' : _titleCtrl.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _label('🎯 اسم الهدف'),
            TextFormField(
              controller: _titleCtrl,
              onChanged: (_) => setState(() {}),
              validator: (v) => v == null || v.trim().isEmpty ? 'الاسم مطلوب' : null,
              decoration: const InputDecoration(
                hintText: 'مثال: إتقان Flutter في 6 أشهر',
                prefixIcon: Icon(Icons.flag_rounded),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 16),

            _label('📋 الوصف (اختياري)'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'وصف تفصيلي لهذا الهدف...',
                prefixIcon: Icon(Icons.description_rounded),
                alignLabelWithHint: true,
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 16),

            _label('🎨 اختر لوناً'),
            const SizedBox(height: 10),
            ColorPickerRow(
              selectedIndex: _colorIndex,
              onChanged: (i) => setState(() => _colorIndex = i),
            ),
            const SizedBox(height: 16),

            _label('📅 الموعد النهائي (اختياري)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppUtils.goalColor(_colorIndex),
                      ),
                    ),
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
                  border: Border.all(
                    color: _deadline != null
                        ? AppUtils.goalColor(_colorIndex)
                        : (isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      color: _deadline != null
                          ? AppUtils.goalColor(_colorIndex)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _deadline != null
                          ? AppUtils.formatFullDate(_deadline)
                          : 'اختر تاريخاً',
                      style: TextStyle(
                        fontSize: 14,
                        color: _deadline != null
                            ? AppUtils.goalColor(_colorIndex)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        fontFamily: 'Cairo',
                        fontWeight: _deadline != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (_deadline != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            GradientButton(
              label: 'إنشاء الهدف',
              icon: Icons.flag_rounded,
              colors: [
                AppUtils.goalColor(_colorIndex),
                AppUtils.goalColor(_colorIndex).withOpacity(0.7),
              ],
              isLoading: _isLoading,
              onTap: _submit,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    await provider.addGoal(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      deadline: _deadline,
      colorIndex: _colorIndex,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎯 تم إنشاء الهدف بنجاح!',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.statusCompleted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
