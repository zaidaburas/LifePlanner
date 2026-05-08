import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/task_model.dart';
import '../../providers/app_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _estimatedHCtrl;
  late final TextEditingController _estimatedMCtrl;
  late final TextEditingController _actualHCtrl;
  late final TextEditingController _actualMCtrl;
  late final TextEditingController _noteCtrl;

  late String _taskType;
  late String _difficulty;
  late String _status;
  late int _priority;
  late bool _isUrgent;
  late double _progress;
  late DateTime? _deadline;
  late List<String> _tags;
  late List<String> _notes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t.title);
    _descCtrl = TextEditingController(text: t.description);
    _categoryCtrl = TextEditingController(text: t.category);
    _tagsCtrl = TextEditingController();
    _estimatedHCtrl =
        TextEditingController(text: (t.estimatedMinutes ~/ 60).toString());
    _estimatedMCtrl =
        TextEditingController(text: (t.estimatedMinutes % 60).toString());
    _actualHCtrl =
        TextEditingController(text: (t.actualMinutes ~/ 60).toString());
    _actualMCtrl =
        TextEditingController(text: (t.actualMinutes % 60).toString());
    _noteCtrl = TextEditingController();
    _taskType = t.taskType;
    _difficulty = t.difficulty;
    _status = t.status;
    _priority = t.priority;
    _isUrgent = t.isUrgent;
    _progress = t.progress;
    _deadline = t.deadline;
    _tags = List<String>.from(t.tags);
    _notes = List<String>.from(t.notes);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    _tagsCtrl.dispose();
    _estimatedHCtrl.dispose();
    _estimatedMCtrl.dispose();
    _actualHCtrl.dispose();
    _actualMCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    final estH = int.tryParse(_estimatedHCtrl.text) ?? 0;
    final estM = int.tryParse(_estimatedMCtrl.text) ?? 0;
    final actH = int.tryParse(_actualHCtrl.text) ?? 0;
    final actM = int.tryParse(_actualMCtrl.text) ?? 0;

    widget.task
      ..title = _titleCtrl.text.trim()
      ..description = _descCtrl.text.trim()
      ..category = _categoryCtrl.text.trim()
      ..taskType = _taskType
      ..difficulty = _difficulty
      ..status = _status
      ..priority = _priority
      ..isUrgent = _isUrgent
      ..progress = _progress
      ..deadline = _deadline
      ..estimatedMinutes = estH * 60 + estM
      ..actualMinutes = actH * 60 + actM
      ..tags = _tags
      ..notes = _notes;

    await provider.updateTask(widget.task);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

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
        title: Text('تعديل المهمة',
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
            // ─── Basic Info ───
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'المعلومات الأساسية',
              icon: Icons.info_outline_rounded,
              children: [
                _buildTextField(
                  controller: _titleCtrl,
                  label: 'عنوان المهمة *',
                  hint: 'أدخل عنوان المهمة',
                  isDark: isDark,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'العنوان مطلوب' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _descCtrl,
                  label: 'الوصف',
                  hint: 'وصف تفصيلي للمهمة',
                  isDark: isDark,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _categoryCtrl,
                  label: 'الفئة / التصنيف',
                  hint: 'مثال: برمجة، تصميم...',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── Type & Status ───
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'النوع والحالة',
              icon: Icons.category_rounded,
              children: [
                _buildDropdown(
                  label: 'نوع المهمة',
                  value: _taskType,
                  items: provider.allTaskTypes,
                  onChanged: (v) => setState(() => _taskType = v!),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'الحالة',
                  value: _status,
                  items: AppConstants.taskStatuses,
                  onChanged: (v) => setState(() => _status = v!),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'مستوى الصعوبة',
                  value: _difficulty,
                  items: AppConstants.difficultyLevels,
                  onChanged: (v) => setState(() => _difficulty = v!),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── Priority & Urgency ───
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الأولوية والإلحاح',
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
                  activeColor: _getPriorityColor(_priority),
                  onChanged: (v) => setState(() => _priority = v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('عاجلة',
                        style: TextStyle(color: textSec, fontSize: 14)),
                    Switch(
                      value: _isUrgent,
                      onChanged: (v) => setState(() => _isUrgent = v),
                      activeColor: AppColors.accentRed,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── Progress ───
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

            // ─── Time ───
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الوقت',
              icon: Icons.timer_outlined,
              children: [
                Text('الوقت المقدر',
                    style: TextStyle(
                        color: textSec,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _buildNumberField(
                            _estimatedHCtrl, 'ساعات', isDark)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                        child: _buildNumberField(
                            _estimatedMCtrl, 'دقائق', isDark)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('الوقت الفعلي',
                    style: TextStyle(
                        color: textSec,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child:
                            _buildNumberField(_actualHCtrl, 'ساعات', isDark)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                        child:
                            _buildNumberField(_actualMCtrl, 'دقائق', isDark)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── Deadline ───
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
            const SizedBox(height: 12),

            // ─── Tags ───
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الوسوم (Tags)',
              icon: Icons.label_outline_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _tagsCtrl,
                        label: 'وسم جديد',
                        hint: 'مثال: Flutter',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final v = _tagsCtrl.text.trim();
                        if (v.isNotEmpty && !_tags.contains(v)) {
                          setState(() {
                            _tags.add(v);
                            _tagsCtrl.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text('إضافة',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _tags
                        .map((tag) => Chip(
                              label: Text(tag,
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.15),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () =>
                                  setState(() => _tags.remove(tag)),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // ─── Notes ───
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الملاحظات',
              icon: Icons.notes_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _noteCtrl,
                        label: 'ملاحظة جديدة',
                        hint: 'أضف ملاحظة...',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final v = _noteCtrl.text.trim();
                        if (v.isNotEmpty) {
                          setState(() {
                            _notes.add(v);
                            _noteCtrl.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text('إضافة',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                if (_notes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...List.generate(
                      _notes.length,
                      (i) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle,
                                    size: 6, color: AppColors.secondary),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(_notes[i],
                                        style: TextStyle(
                                            color: textPrimary,
                                            fontSize: 13))),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      size: 16, color: AppColors.accentRed),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () =>
                                      setState(() => _notes.removeAt(i)),
                                ),
                              ],
                            ),
                          )),
                ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
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

  Widget _buildNumberField(
      TextEditingController ctrl, String label, bool isDark) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark
            ? AppColors.darkBackground.withOpacity(0.5)
            : AppColors.background,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
    final safeValue = items.contains(value) ? value : items.first;
    return DropdownButtonFormField<String>(
      value: safeValue,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark
            ? AppColors.darkBackground.withOpacity(0.5)
            : AppColors.background,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      isExpanded: true,
      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
    );
  }

  Color _getPriorityColor(int p) {
    if (p >= 8) return AppColors.accentRed;
    if (p >= 6) return AppColors.priorityMedium;
    if (p >= 4) return AppColors.primary;
    return AppColors.statusCompleted;
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
