import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/goal_model.dart';
import '../../providers/app_provider.dart';

class EditGoalScreen extends StatefulWidget {
  final GoalModel goal;
  const EditGoalScreen({super.key, required this.goal});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  late String _status;
  late int _colorIndex;
  late double _progress;
  late DateTime? _deadline;
  bool _isLoading = false;

  static const List<Map<String, dynamic>> _iconOptions = [
    {'name': 'code', 'icon': Icons.code_rounded},
    {'name': 'fitness', 'icon': Icons.fitness_center_rounded},
    {'name': 'school', 'icon': Icons.school_rounded},
    {'name': 'work', 'icon': Icons.work_rounded},
    {'name': 'home', 'icon': Icons.home_rounded},
    {'name': 'health', 'icon': Icons.favorite_rounded},
    {'name': 'money', 'icon': Icons.attach_money_rounded},
    {'name': 'travel', 'icon': Icons.flight_rounded},
    {'name': 'art', 'icon': Icons.brush_rounded},
    {'name': 'music', 'icon': Icons.music_note_rounded},
    {'name': 'sports', 'icon': Icons.sports_rounded},
    {'name': 'reading', 'icon': Icons.menu_book_rounded},
  ];
  late String? _iconName;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _titleCtrl = TextEditingController(text: g.title);
    _descCtrl = TextEditingController(text: g.description);
    _status = g.status;
    _colorIndex = g.colorIndex.clamp(0, AppConstants.goalColors.length - 1);
    _progress = g.progress;
    _deadline = g.deadline;
    _iconName = g.iconName;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();

    widget.goal
      ..title = _titleCtrl.text.trim()
      ..description = _descCtrl.text.trim()
      ..status = _status
      ..colorIndex = _colorIndex
      ..progress = _progress
      ..deadline = _deadline
      ..iconName = _iconName;

    await provider.updateGoal(widget.goal);
    
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('تعديل الهدف',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textPrimary)),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text('حفظ',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'المعلومات الأساسية',
              icon: Icons.flag_rounded,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'العنوان مطلوب' : null,
                  decoration: _inputDecor('عنوان الهدف *', 'أدخل عنوان الهدف', isDark),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: _inputDecor('الوصف', 'وصف تفصيلي للهدف', isDark),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الحالة',
              icon: Icons.info_outline_rounded,
              children: [
                DropdownButtonFormField<String>(
                  value: AppConstants.taskStatuses.contains(_status)
                      ? _status
                      : AppConstants.taskStatuses.first,
                  items: AppConstants.taskStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                  decoration: _inputDecor('الحالة', '', isDark),
                  isExpanded: true,
                  dropdownColor:
                      isDark ? AppColors.darkSurface : Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),

            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'التقدم',
              icon: Icons.trending_up_rounded,
              children: [
                Row(
                  children: [
                    Text('نسبة الإنجاز: ',
                        style: TextStyle(color: textSec, fontSize: 14)),
                    Text('${(_progress * 100).round()}%',
                        style: TextStyle(
                            color: AppColors.statusCompleted,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                Slider(
                  value: _progress,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  label: '${(_progress * 100).round()}%',
                  activeColor: AppColors.statusCompleted,
                  onChanged: (v) => setState(() => _progress = v),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'اللون والأيقونة',
              icon: Icons.palette_outlined,
              children: [
                Text('اللون',
                    style: TextStyle(
                        color: textSec,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                ColorPickerRow(
                  selectedIndex: _colorIndex,
                  onChanged: (i) => setState(() => _colorIndex = i),
                ),
                const SizedBox(height: 16),
                Text('الأيقونة',
                    style: TextStyle(
                        color: textSec,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _iconOptions
                      .map((opt) => GestureDetector(
                            onTap: () =>
                                setState(() => _iconName = opt['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _iconName == opt['name']
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkBackground
                                        : AppColors.background),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _iconName == opt['name']
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.border),
                                ),
                              ),
                              child: Icon(
                                opt['icon'] as IconData,
                                size: 22,
                                color: _iconName == opt['name']
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الموعد النهائي',
              icon: Icons.event_rounded,
              children: [
                InkWell(
                  onTap: () => _pickDeadline(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _deadline != null
                                ? '${_deadline!.year}/${_deadline!.month.toString().padLeft(2, '0')}/${_deadline!.day.toString().padLeft(2, '0')}'
                                : 'بدون موعد نهائي',
                            style: TextStyle(
                                color: _deadline != null
                                    ? textPrimary
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textHint),
                                fontSize: 14),
                          ),
                        ),
                        if (_deadline != null)
                          IconButton(
                            icon: Icon(Icons.close,
                                size: 18, color: AppColors.accentRed),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _deadline = null),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required bool isDark,
    required Color cardBg,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecor(String label, String hint, bool isDark) {
    return InputDecoration(
      labelText: label,
      hintText: hint.isNotEmpty ? hint : null,
      filled: true,
      fillColor: isDark
          ? AppColors.darkBackground.withOpacity(0.5)
          : AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _deadline = picked);
  }
}
