import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/phase_model.dart';
import '../../../data/models/obstacle_model.dart';
import '../../providers/app_provider.dart';
import 'edit_task_screen.dart';
import 'edit_phase_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final task = provider.getTask(widget.taskId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('المهمة')),
        body: const Center(child: Text('المهمة غير موجودة')),
      );
    }

    final typeColor = AppUtils.getTaskTypeColor(task.taskType, provider: provider);
    final phases = provider.getPhasesForTask(task.id);
    final obstacles = provider.getObstaclesForLinked(task.id);
    final project = provider.projects.where((p) => p.id == task.projectId).firstOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: typeColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () => _showEditDialog(context, provider, task),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'delete') _confirmDelete(context, provider, task.id);
                  if (v == 'obstacle') _showAddObstacleDialog(context, provider, task.id);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'obstacle', child: Text('إضافة عائق')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف المهمة', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [typeColor, typeColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppUtils.getTaskTypeIcon(task.taskType,provider),
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(task.taskType,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11, fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (task.isUrgent) const UrgentBadge(compact: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    if (project != null)
                      Text(
                        project.title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontFamily: 'Cairo',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Quick stats
            _buildQuickStats(context, task, isDark),
            // Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: AppProgressBar(
                progress: task.progress,
                color: typeColor,
                height: 10,
                showLabel: true,
              ),
            ),
            const SizedBox(height: 8),
            // Status selector
            _buildStatusSelector(context, provider, task, isDark),
            const SizedBox(height: 8),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                indicator: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'المراحل (${phases.length})'),
                  const Tab(text: 'التفاصيل'),
                  Tab(text: 'العوائق (${obstacles.length})'),
                  const Tab(text: 'العلاقات'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PhasesTab(task: task, phases: phases),
                  _DetailsTab(task: task),
                  _ObstaclesTab(task: task, obstacles: obstacles),
                  _RelationsTab(task: task),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, task, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _quickStat(Icons.access_time, AppUtils.formatDuration(task.estimatedMinutes),
              'مقدر', AppColors.accentBlue, isDark),
          _quickStat(Icons.timer_outlined, AppUtils.formatDuration(task.actualMinutes),
              'فعلي', AppColors.accentGreen, isDark),
          _quickStat(Icons.trending_up, AppUtils.getPriorityLabel(task.priority),
              'أولوية', AppUtils.getPriorityColor(task.priority), isDark),
          _quickStat(Icons.speed_rounded, task.difficulty,
              'صعوبة', AppUtils.getDifficultyColor(task.difficulty), isDark),
        ],
      ),
    );
  }

  Widget _quickStat(IconData icon, String value, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector(BuildContext context, AppProvider provider, task, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: AppConstants.taskStatuses.map((s) {
          final isSelected = task.status == s;
          final color = AppUtils.getStatusColor(s);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () async {
                task.status = s;
                if (s == 'مكتملة') task.progress = 1.0;
                await provider.updateTask(task);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.border)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppUtils.getStatusIcon(s), size: 13,
                        color: isSelected ? Colors.white : color),
                    const SizedBox(width: 5),
                    Text(s,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : color,
                          fontFamily: 'Cairo',
                        )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppProvider provider, task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المهمة', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف هذه المهمة؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.deleteTask(id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddObstacleDialog(BuildContext context, AppProvider provider, String taskId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String impact = 'متوسط';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تسجيل عائق',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  const SizedBox(height: 16),
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'اسم العائق')),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'وصف العائق')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: impact,
                    decoration: const InputDecoration(labelText: 'مستوى التأثير'),
                    items: AppConstants.impactLevels
                        .map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontFamily: 'Cairo'))))
                        .toList(),
                    onChanged: (v) => setSt(() => impact = v!),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: 'تسجيل العائق',
                      icon: Icons.warning_amber_rounded,
                      onTap: () async {
                        if (titleCtrl.text.trim().isEmpty) return;
                        await provider.addObstacle(
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          linkedId: taskId,
                          linkedType: 'task',
                          impactLevel: impact,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── PHASES TAB ───
class _PhasesTab extends StatelessWidget {
  final task;
  final List<PhaseModel> phases;
  const _PhasesTab({required this.task, required this.phases});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        ...phases.map((phase) => _PhaseCard(phase: phase)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showAddPhaseDialog(context, provider, task.id, phases.length),
          icon: const Icon(Icons.add),
          label: const Text('إضافة مرحلة', style: TextStyle(fontFamily: 'Cairo')),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _showAddPhaseDialog(BuildContext context, AppProvider provider, String taskId, int order) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة مرحلة', style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'اسم المرحلة')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await provider.addPhase(title: ctrl.text.trim(), taskId: taskId, orderIndex: order);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

class _PhaseCard extends StatefulWidget {
  final PhaseModel phase;
  const _PhaseCard({required this.phase});

  @override
  State<_PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<_PhaseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final phase = widget.phase;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AppUtils.getStatusColor(phase.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${phase.orderIndex + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(phase.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                      Row(
                        children: [
                          StatusBadge(status: phase.status, compact: true),
                          const SizedBox(width: 6),
                          Text(
                            '${(phase.progress * 100).round()}%',
                            style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Quick progress update
                GestureDetector(
                  onTap: () => _showPhaseEditScreen(context, phase),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                  ),
                ),
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  onPressed: () => setState(() => _expanded = !_expanded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppProgressBar(progress: phase.progress, color: statusColor, height: 6),
            if (_expanded) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              // Checklist
              if (phase.checklist.isNotEmpty) ...[
                const Text('قائمة المهام:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 6),
                ...List.generate(phase.checklist.length, (i) {
                  final done = i < phase.checklistDone.length && phase.checklistDone[i];
                  return CheckboxListTile(
                    value: done,
                    onChanged: (v) async {
                      while (phase.checklistDone.length <= i) {
                        phase.checklistDone.add(false);
                      }
                      phase.checklistDone[i] = v ?? false;
                      final completed = phase.checklistDone.where((d) => d).length;
                      phase.progress = completed / phase.checklist.length;
                      await provider.updatePhase(phase);
                    },
                    title: Text(phase.checklist[i],
                        style: TextStyle(
                          fontSize: 13,
                          decoration: done ? TextDecoration.lineThrough : null,
                          fontFamily: 'Cairo',
                        )),
                    dense: true,
                    activeColor: AppColors.primary,
                  );
                }),
                const SizedBox(height: 8),
              ],
              // Add checklist item
              OutlinedButton.icon(
                onPressed: () => _showAddChecklistItem(context, provider, phase),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('إضافة عنصر', style: TextStyle(fontSize: 12, fontFamily: 'Cairo')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (phase.notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(phase.notes,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          fontFamily: 'Cairo')),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _showPhaseEditScreen(BuildContext context, PhaseModel phase) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPhaseScreen(phase: phase)),
    );
  }

  void _showAddChecklistItem(BuildContext context, AppProvider provider, PhaseModel phase) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة عنصر', style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'العنصر')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              phase.checklist.add(ctrl.text.trim());
              phase.checklistDone.add(false);
              await provider.updatePhase(phase);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

// ─── DETAILS TAB ───
class _DetailsTab extends StatelessWidget {
  final task;
  const _DetailsTab({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: [
        if (task.description.isNotEmpty) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.description_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('الوصف', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                ]),
                const SizedBox(height: 10),
                Text(task.description, style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontFamily: 'Cairo')),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('معلومات المهمة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              ]),
              const SizedBox(height: 14),
              _infoRow(Icons.category_rounded, 'النوع', task.taskType, isDark),
              _infoRow(Icons.speed_rounded, 'الصعوبة', task.difficulty, isDark),
              _infoRow(Icons.flag_rounded, 'الأولوية', 'P${task.priority} - ${AppUtils.getPriorityLabel(task.priority)}', isDark),
              _infoRow(Icons.calendar_today, 'تاريخ الإنشاء', AppUtils.formatFullDate(task.createdAt), isDark),
              if (task.deadline != null)
                _infoRow(Icons.event_rounded, 'الموعد النهائي', AppUtils.formatFullDate(task.deadline), isDark),
              _infoRow(Icons.hourglass_bottom, 'الوقت المقدر', AppUtils.formatDuration(task.estimatedMinutes), isDark),
              _infoRow(Icons.timer, 'الوقت الفعلي', AppUtils.formatDuration(task.actualMinutes), isDark),
            ],
          ),
        ),
        if (task.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.label_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('التاجات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                ]),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: task.tags.map<Widget>((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tag, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontFamily: 'Cairo')),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontFamily: 'Cairo')),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}

// ─── OBSTACLES TAB ───
class _ObstaclesTab extends StatelessWidget {
  final task;
  final List<ObstacleModel> obstacles;
  const _ObstaclesTab({required this.task, required this.obstacles});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (obstacles.isEmpty) {
      return const EmptyState(
        title: 'لا توجد عوائق',
        subtitle: 'ممتاز! لم تواجه أي عوائق في هذه المهمة',
        icon: Icons.shield_rounded,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      itemCount: obstacles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final obs = obstacles[i];
        final impactColor = AppUtils.getImpactColor(obs.impactLevel);
        return AppCard(
          border: Border.all(color: impactColor.withOpacity(0.3)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: impactColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(obs.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: impactColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Text(obs.impactLevel, style: TextStyle(fontSize: 11, color: impactColor, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: obs.isResolved ? AppColors.statusCompleted.withOpacity(0.12) : AppColors.statusPaused.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      obs.isResolved ? 'محلول' : 'قائم',
                      style: TextStyle(
                        fontSize: 11,
                        color: obs.isResolved ? AppColors.statusCompleted : AppColors.statusPaused,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
              if (obs.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(obs.description, style: const TextStyle(fontSize: 13, fontFamily: 'Cairo')),
              ],
              if (obs.solution.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.statusCompleted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(obs.solution, style: const TextStyle(fontSize: 12, color: AppColors.statusCompleted, fontFamily: 'Cairo'))),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(AppUtils.formatFullDate(obs.occurredAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                  const Spacer(),
                  if (!obs.isResolved)
                    GestureDetector(
                      onTap: () async {
                        obs.isResolved = true;
                        await provider.updateObstacle(obs);
                      },
                      child: const Text('تحديد كمحلول',
                          style: TextStyle(fontSize: 11, color: AppColors.primary, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── RELATIONS TAB ───
class _RelationsTab extends StatelessWidget {
  final task;
  const _RelationsTab({required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final related = task.relatedTaskIds as List<String>;

    if (related.isEmpty) {
      return EmptyState(
        title: 'لا توجد علاقات',
        subtitle: 'لم يتم ربط هذه المهمة بمهام أخرى',
        icon: Icons.hub_rounded,
        actionLabel: 'ربط بمهمة',
        onAction: () => _showLinkDialog(context, provider),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      itemCount: related.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final relTask = provider.getTask(related[i]);
        if (relTask == null) return const SizedBox.shrink();
        final relType = i < task.relationTypes.length ? task.relationTypes[i] : '—';
        final color = AppUtils.getTaskTypeColor(relTask.taskType);
        return AppCard(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(AppUtils.getTaskTypeIcon(relTask.taskType, provider), color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(relTask.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    Text(relType, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontFamily: 'Cairo')),
                  ],
                ),
              ),
              StatusBadge(status: relTask.status, compact: true),
            ],
          ),
        );
      },
    );
  }

  void _showLinkDialog(BuildContext context, AppProvider provider) {
    final allTasks = provider.tasks.where((t) => t.id != task.id).toList();
    if (allTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد مهام أخرى للربط', style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }
    String? selectedTaskId;
    String relType = AppConstants.relationTypes.first;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ربط بمهمة أخرى', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTaskId,
                  hint: const Text('اختر مهمة', style: TextStyle(fontFamily: 'Cairo')),
                  decoration: const InputDecoration(labelText: 'المهمة'),
                  items: allTasks.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)))).toList(),
                  onChanged: (v) => setSt(() => selectedTaskId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: relType,
                  decoration: const InputDecoration(labelText: 'نوع العلاقة'),
                  items: AppConstants.relationTypes.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                  onChanged: (v) => setSt(() => relType = v!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'ربط المهمة',
                    icon: Icons.link_rounded,
                    onTap: () async {
                      if (selectedTaskId == null) return;
                      task.relatedTaskIds.add(selectedTaskId!);
                      task.relationTypes.add(relType);
                      await provider.updateTask(task);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
