import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final String? preselectedProjectId;
  const AddTaskScreen({super.key, this.preselectedProjectId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  String _taskType = AppConstants.defaultTaskTypes.first;
  String _difficulty = AppConstants.difficultyLevels[1];
  String? _projectId;
  DateTime? _deadline;
  int _estimatedMinutes = 60;
  int _priority = 5;
  bool _isUrgent = false;
  bool _addDefaultPhases = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _projectId = widget.preselectedProjectId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('مهمة جديدة'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            _buildSection(
              '📝 اسم المهمة',
              TextFormField(
                controller: _titleCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'الاسم مطلوب' : null,
                decoration: const InputDecoration(
                  hintText: 'أدخل اسم المهمة...',
                  prefixIcon: Icon(Icons.task_alt),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            _buildSection(
              '📋 الوصف',
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'وصف تفصيلي للمهمة...',
                  prefixIcon: Icon(Icons.description_rounded),
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(height: 16),

            // Project
            _buildSection(
              '📁 المشروع',
              DropdownButtonFormField<String>(
                value: _projectId,
                validator: (v) => v == null ? 'اختر مشروعاً' : null,
                hint: const Text('اختر المشروع', style: TextStyle(fontFamily: 'Cairo')),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.folder_rounded)),
                items: provider.projects.map((p) {
                  final color = AppUtils.goalColor(p.colorIndex);
                  return DropdownMenuItem(
                    value: p.id,
                    child: Row(
                      children: [
                        Icon(Icons.folder_rounded, size: 16, color: color),
                        const SizedBox(width: 8),
                        Text(p.title,
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _projectId = v),
              ),
            ),
            const SizedBox(height: 16),

            // Task Type
            _buildSection(
              '🏷️ نوع المهمة',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.defaultTaskTypes.map((type) {
                  final selected = _taskType == type;
                  final color = AppUtils.getTaskTypeColor(type);
                  return GestureDetector(
                    onTap: () => setState(() => _taskType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? color : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? color : (isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppUtils.getTaskTypeIcon(type),
                              size: 14, color: selected ? Colors.white : color),
                          const SizedBox(width: 6),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Difficulty
            _buildSection(
              '⚡ مستوى الصعوبة',
              Row(
                children: AppConstants.difficultyLevels.map((d) {
                  final selected = _difficulty == d;
                  final color = AppUtils.getDifficultyColor(d);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _difficulty = d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? color : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? color : (isDark ? AppColors.darkBorder : AppColors.border)),
                          ),
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Priority & Urgency
            _buildSection(
              '🚩 الأولوية والاستعجال',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'الأولوية: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'P$_priority - ${AppUtils.getPriorityLabel(_priority)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppUtils.getPriorityColor(_priority),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _priority.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: 'P$_priority',
                    activeColor: AppUtils.getPriorityColor(_priority),
                    onChanged: (v) => setState(() => _priority = v.round()),
                  ),
                  SwitchListTile(
                    value: _isUrgent,
                    onChanged: (v) => setState(() => _isUrgent = v),
                    title: const Text('مهمة عاجلة ⚡',
                        style: TextStyle(fontSize: 14, fontFamily: 'Cairo')),
                    subtitle: const Text('ستظهر في قسم المهام العاجلة',
                        style: TextStyle(fontSize: 12, fontFamily: 'Cairo')),
                    activeColor: AppColors.secondary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Time estimate
            _buildSection(
              '⏱️ الوقت المقدر',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppUtils.formatDuration(_estimatedMinutes),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Slider(
                    value: _estimatedMinutes.toDouble(),
                    min: 15,
                    max: 480,
                    divisions: 31,
                    label: AppUtils.formatDuration(_estimatedMinutes),
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _estimatedMinutes = v.round()),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [30, 60, 90, 120, 180, 240, 360].map((m) {
                      final sel = _estimatedMinutes == m;
                      return GestureDetector(
                        onTap: () => setState(() => _estimatedMinutes = m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: sel ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.border),
                            ),
                          ),
                          child: Text(
                            AppUtils.formatDuration(m),
                            style: TextStyle(
                              fontSize: 11,
                              color: sel ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Deadline
            _buildSection(
              '📅 الموعد النهائي',
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(primary: AppColors.primary),
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
                      color: _deadline != null ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        color: _deadline != null ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _deadline != null ? AppUtils.formatFullDate(_deadline) : 'اختر تاريخاً',
                        style: TextStyle(
                          fontSize: 14,
                          color: _deadline != null ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
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
            ),
            const SizedBox(height: 16),

            // Tags
            _buildSection(
              '🏷️ التاجات (اختياري)',
              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  hintText: 'Flutter, برمجة, تعلم (افصل بفاصلة)',
                  prefixIcon: Icon(Icons.label_rounded),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(height: 16),

            // Default Phases
            _buildSection(
              '📊 مراحل التنفيذ',
              SwitchListTile(
                value: _addDefaultPhases,
                onChanged: (v) => setState(() => _addDefaultPhases = v),
                title: const Text('إضافة المراحل الافتراضية',
                    style: TextStyle(fontSize: 14, fontFamily: 'Cairo')),
                subtitle: Text(
                  'بحث → تخطيط → تجهيز → تنفيذ → اختبار → إنهاء',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 30),

            // Submit
            GradientButton(
              label: 'إنشاء المهمة',
              icon: Icons.add_task,
              isLoading: _isLoading,
              onTap: _submit,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    final tags = _tagsCtrl.text.trim().isEmpty
        ? <String>[]
        : _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    await provider.addTask(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      projectId: _projectId!,
      taskType: _taskType,
      category: _categoryCtrl.text.trim(),
      deadline: _deadline,
      estimatedMinutes: _estimatedMinutes,
      difficulty: _difficulty,
      priority: _priority,
      isUrgent: _isUrgent,
      tags: tags,
      addDefaultPhases: _addDefaultPhases,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ تم إنشاء المهمة بنجاح!', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.statusCompleted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
