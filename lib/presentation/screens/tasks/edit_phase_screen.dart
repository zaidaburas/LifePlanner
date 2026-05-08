import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/phase_model.dart';
import '../../providers/app_provider.dart';

class EditPhaseScreen extends StatefulWidget {
  final PhaseModel phase;
  const EditPhaseScreen({super.key, required this.phase});

  @override
  State<EditPhaseScreen> createState() => _EditPhaseScreenState();
}

class _EditPhaseScreenState extends State<EditPhaseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _checkItemCtrl;
  late final TextEditingController _timeCtrl;

  late String _status;
  late double _progress;
  late List<String> _checklist;
  late List<bool> _checklistDone;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.phase;
    _titleCtrl = TextEditingController(text: p.title);
    _notesCtrl = TextEditingController(text: p.notes);
    _checkItemCtrl = TextEditingController();
    _timeCtrl =
        TextEditingController(text: p.timeSpentMinutes.toString());
    _status = p.status;
    _progress = p.progress;
    _checklist = List<String>.from(p.checklist);
    _checklistDone = List<bool>.from(p.checklistDone);

    // Ensure lists are the same length
    while (_checklistDone.length < _checklist.length) {
      _checklistDone.add(false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _checkItemCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();

    widget.phase
      ..title = _titleCtrl.text.trim()
      ..notes = _notesCtrl.text.trim()
      ..status = _status
      ..progress = _progress
      ..checklist = _checklist
      ..checklistDone = _checklistDone
      ..timeSpentMinutes = int.tryParse(_timeCtrl.text) ?? 0;

    await provider.updatePhase(widget.phase);
    if (mounted) Navigator.pop(context, true);
  }

  void _addChecklistItem() {
    final v = _checkItemCtrl.text.trim();
    if (v.isNotEmpty) {
      setState(() {
        _checklist.add(v);
        _checklistDone.add(false);
        _checkItemCtrl.clear();
      });
    }
  }

  void _removeChecklistItem(int idx) {
    setState(() {
      _checklist.removeAt(idx);
      _checklistDone.removeAt(idx);
    });
  }

  void _toggleChecklistItem(int idx, bool val) {
    setState(() {
      _checklistDone[idx] = val;
      // Auto-update progress based on checklist
      if (_checklist.isNotEmpty) {
        final done = _checklistDone.where((v) => v).length;
        _progress = done / _checklist.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final doneCount = _checklistDone.where((v) => v).length;
    final totalCount = _checklist.length;

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
        title: Text('تعديل المرحلة',
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
            // Title & Status
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'معلومات المرحلة',
              icon: Icons.layers_rounded,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'العنوان مطلوب' : null,
                  decoration: _inputDecor('عنوان المرحلة *', isDark),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: AppConstants.taskStatuses.contains(_status)
                      ? _status
                      : AppConstants.taskStatuses.first,
                  items: AppConstants.taskStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                  decoration: _inputDecor('الحالة', isDark),
                  isExpanded: true,
                  dropdownColor:
                      isDark ? AppColors.darkSurface : Colors.white,
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
                    if (totalCount > 0) ...[
                      const SizedBox(width: 12),
                      Text('($doneCount/$totalCount من القائمة)',
                          style: TextStyle(color: textSec, fontSize: 12)),
                    ],
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

            // Time Spent
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الوقت المستغرق',
              icon: Icons.timer_outlined,
              children: [
                TextFormField(
                  controller: _timeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecor('الوقت (بالدقائق)', isDark),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Checklist
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'قائمة المهام الفرعية',
              icon: Icons.checklist_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _checkItemCtrl,
                        decoration:
                            _inputDecor('عنصر جديد في القائمة', isDark),
                        onFieldSubmitted: (_) => _addChecklistItem(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addChecklistItem,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14)),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                if (_checklist.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  if (totalCount > 0)
                    LinearProgressIndicator(
                      value: totalCount > 0 ? doneCount / totalCount : 0,
                      backgroundColor:
                          isDark ? AppColors.darkBackground : AppColors.border,
                      color: AppColors.statusCompleted,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    _checklist.length,
                    (i) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: _checklistDone[i]
                            ? AppColors.statusCompleted.withOpacity(0.08)
                            : (isDark
                                ? AppColors.darkBackground
                                : AppColors.background),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _checklistDone[i]
                              ? AppColors.statusCompleted.withOpacity(0.3)
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                        ),
                      ),
                      child: CheckboxListTile(
                        value: _checklistDone[i],
                        onChanged: (v) => _toggleChecklistItem(i, v!),
                        title: Text(
                          _checklist[i],
                          style: TextStyle(
                            fontSize: 13,
                            decoration: _checklistDone[i]
                                ? TextDecoration.lineThrough
                                : null,
                            color: _checklistDone[i]
                                ? textSec
                                : textPrimary,
                          ),
                        ),
                        secondary: IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 16, color: AppColors.accentRed),
                          onPressed: () => _removeChecklistItem(i),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        activeColor: AppColors.statusCompleted,
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Notes
            _sectionCard(
              isDark: isDark,
              cardBg: cardBg,
              title: 'الملاحظات',
              icon: Icons.notes_rounded,
              children: [
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: _inputDecor('ملاحظات المرحلة...', isDark),
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

  InputDecoration _inputDecor(String label, bool isDark) {
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
}
