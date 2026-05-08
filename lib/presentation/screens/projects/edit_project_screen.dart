import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/project_model.dart';
import '../../providers/app_provider.dart';

class EditProjectScreen extends StatefulWidget {
  final ProjectModel project;
  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  late String _goalId;
  late String _status;
  late int _priority;
  late int _colorIndex;
  late double _progress;
  late DateTime? _deadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleCtrl = TextEditingController(text: p.title);
    _descCtrl = TextEditingController(text: p.description);
    _goalId = p.goalId;
    _status = p.status;
    _priority = p.priority;
    _colorIndex = p.colorIndex;
    _progress = p.progress;
    _deadline = p.deadline;
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

    widget.project
      ..title = _titleCtrl.text.trim()
      ..description = _descCtrl.text.trim()
      ..goalId = _goalId
      ..status = _status
      ..priority = _priority
      ..colorIndex = _colorIndex
      ..progress = _progress
      ..deadline = _deadline;

    await provider.updateProject(widget.project);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final goals = provider.goals;

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
        title: Text('تعديل المشروع',
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
            // Basic Info
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'المعلومات الأساسية',
              icon: Icons.folder_open_rounded,
              children: [
                _buildTextField(
                  controller: _titleCtrl,
                  label: 'اسم المشروع *',
                  hint: 'أدخل اسم المشروع',
                  isDark: isDark,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'الاسم مطلوب' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _descCtrl,
                  label: 'الوصف',
                  hint: 'وصف تفصيلي للمشروع',
                  isDark: isDark,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Goal & Status
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الهدف والحالة',
              icon: Icons.flag_rounded,
              children: [
                if (goals.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: goals.any((g) => g.id == _goalId) ? _goalId : goals.first.id,
                    items: goals
                        .map((g) => DropdownMenuItem(
                            value: g.id, child: Text(g.title)))
                        .toList(),
                    onChanged: (v) => setState(() => _goalId = v!),
                    decoration: _dropdownDecor('الهدف الرئيسي', isDark),
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                  ),
                  const SizedBox(height: 12),
                ],
                _buildDropdown(
                  label: 'الحالة',
                  value: _status,
                  items: AppConstants.taskStatuses,
                  onChanged: (v) => setState(() => _status = v!),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Priority
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الأولوية',
              icon: Icons.priority_high_rounded,
              children: [
                Row(
                  children: [
                    Text('الأولوية: ',
                        style: TextStyle(color: textSec, fontSize: 14)),
                    Text('$_priority / 10',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                Slider(
                  value: _priority.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _priority.toString(),
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _priority = v.round()),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress
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

            // Color
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'اللون',
              icon: Icons.palette_outlined,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    AppConstants.goalColors.length,
                    (i) => GestureDetector(
                      onTap: () => setState(() => _colorIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(AppConstants.goalColors[i]),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _colorIndex == i
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: _colorIndex == i
                              ? [
                                  BoxShadow(
                                    color: Color(AppConstants.goalColors[i])
                                        .withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : [],
                        ),
                        child: _colorIndex == i
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Deadline
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
                            onPressed: () =>
                                setState(() => _deadline = null),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: isDark
            ? AppColors.darkBackground.withOpacity(0.5)
            : AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    final safe = items.contains(value) ? value : items.first;
    return DropdownButtonFormField<String>(
      value: safe,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: _dropdownDecor(label, isDark),
      isExpanded: true,
      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
    );
  }

  InputDecoration _dropdownDecor(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
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
