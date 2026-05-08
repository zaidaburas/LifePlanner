import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../tasks/task_detail_screen.dart';
import '../tasks/add_task_screen.dart';
import 'edit_project_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final project = provider.getProject(projectId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (project == null) {
      return Scaffold(appBar: AppBar(title: const Text('المشروع')),
          body: const Center(child: Text('المشروع غير موجود')));
    }

    final color = AppUtils.goalColor(project.colorIndex);
    final tasks = provider.getTasksForProject(projectId);
    final obstacles = provider.getObstaclesForLinked(projectId);
    final completedTasks = tasks.where((t) => t.status == 'مكتملة').length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                tooltip: 'تعديل المشروع',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProjectScreen(project: project),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_task, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTaskScreen(preselectedProjectId: projectId),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'delete') _confirmDelete(context, provider, project.id);
                  if (v == 'obstacle') _showAddObstacleDialog(context, provider, project.id);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'obstacle', child: Text('إضافة عائق')),
                  const PopupMenuItem(value: 'delete',
                      child: Text('حذف المشروع', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.folder_rounded, color: Colors.white54, size: 28),
                    const SizedBox(height: 6),
                    Text(project.title,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.bold, fontFamily: 'Cairo',
                        )),
                    if (project.description.isNotEmpty)
                      Text(project.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13, fontFamily: 'Cairo',
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Stats row
            Row(
              children: [
                _statBox('${tasks.length}', 'مهام', Icons.task_alt, color, isDark),
                const SizedBox(width: 10),
                _statBox('$completedTasks', 'مكتملة', Icons.check_circle_outline, AppColors.statusCompleted, isDark),
                const SizedBox(width: 10),
                _statBox('${(project.progress * 100).round()}%', 'تقدم', Icons.trending_up, AppColors.secondary, isDark),
                const SizedBox(width: 10),
                _statBox('${obstacles.length}', 'عوائق', Icons.warning_amber_rounded,
                    obstacles.isEmpty ? AppColors.statusCompleted : AppColors.priorityHigh, isDark),
              ],
            ),
            const SizedBox(height: 16),

            // Progress
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('التقدم الكلي',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                      Text('${(project.progress * 100).round()}%',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppProgressBar(progress: project.progress, color: color, height: 12),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatusBadge(status: project.status),
                      const SizedBox(width: 8),
                      if (project.deadline != null) ...[
                        const Icon(Icons.event_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(AppUtils.formatDate(project.deadline),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tasks
            SectionHeader(
              title: 'المهام (${tasks.length})',
              actionLabel: '+ إضافة',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddTaskScreen(preselectedProjectId: projectId)),
              ),
            ),
            const SizedBox(height: 10),
            if (tasks.isEmpty)
              const EmptyState(
                title: 'لا توجد مهام',
                subtitle: 'أضف مهمتك الأولى لهذا المشروع',
                icon: Icons.task_alt,
              )
            else
              ...tasks.map((t) {
                final tc = AppUtils.getTaskTypeColor(t.taskType);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: t.id)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: tc.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(AppUtils.getTaskTypeIcon(t.taskType), color: tc, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.title,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              AppProgressBar(progress: t.progress, color: tc, height: 4),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${(t.progress * 100).round()}%',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tc, fontFamily: 'Cairo')),
                            StatusBadge(status: t.status, compact: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            if (obstacles.isNotEmpty) ...[
              const SizedBox(height: 20),
              SectionHeader(title: 'العوائق (${obstacles.length})'),
              const SizedBox(height: 10),
              ...obstacles.map((obs) {
                final ic = AppUtils.getImpactColor(obs.impactLevel);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    border: Border.all(color: ic.withOpacity(0.25)),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: ic, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(obs.title,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                              Text(obs.impactLevel,
                                  style: TextStyle(fontSize: 11, color: ic, fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (obs.isResolved ? AppColors.statusCompleted : AppColors.statusPaused).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(obs.isResolved ? 'محلول' : 'قائم',
                              style: TextStyle(
                                fontSize: 11,
                                color: obs.isResolved ? AppColors.statusCompleted : AppColors.statusPaused,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String val, String label, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
            Text(label, style: TextStyle(fontSize: 10,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المشروع', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('سيتم حذف المشروع وجميع مهامه. هل أنت متأكد؟',
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.deleteProject(id);
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

  void _showStatusDialog(BuildContext context, AppProvider provider, project) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تغيير الحالة', style: TextStyle(fontFamily: 'Cairo')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.taskStatuses.map((s) {
            final color = AppUtils.getStatusColor(s);
            return ListTile(
              leading: Icon(AppUtils.getStatusIcon(s), color: color),
              title: Text(s, style: const TextStyle(fontFamily: 'Cairo')),
              selected: project.status == s,
              selectedColor: color,
              onTap: () async {
                project.status = s;
                await provider.updateProject(project);
                if (context.mounted) Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddObstacleDialog(BuildContext context, AppProvider provider, String projectId) {
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
                  const Text('تسجيل عائق للمشروع',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  const SizedBox(height: 16),
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'اسم العائق')),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'الوصف')),
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
                          linkedId: projectId,
                          linkedType: 'project',
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
