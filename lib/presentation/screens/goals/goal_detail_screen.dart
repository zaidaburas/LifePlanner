import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../providers/app_provider.dart';
import '../projects/project_detail_screen.dart';
import '../projects/add_project_screen.dart';
import 'edit_goal_screen.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final goal = provider.getGoal(goalId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (goal == null) {
      return Scaffold(appBar: AppBar(title: const Text('الهدف')),
          body: const Center(child: Text('الهدف غير موجود')));
    }

    final color = AppUtils.goalColor(goal.colorIndex);
    final projects = provider.getProjectsForGoal(goalId);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                tooltip: 'تعديل الهدف',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditGoalScreen(goal: goal)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddProjectScreen(preselectedGoalId: goalId)),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'delete') _confirmDelete(context, provider, goal.id);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('حذف الهدف', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.flag_rounded, color: Colors.white54, size: 28),
                    const SizedBox(height: 6),
                    Text(goal.title,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.bold, fontFamily: 'Cairo',
                        )),
                    if (goal.description.isNotEmpty)
                      Expanded(
                        child: Text(goal.description,
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontFamily: 'Cairo'),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('${(goal.progress * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 28,
                              fontWeight: FontWeight.bold, fontFamily: 'Cairo',
                            )),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: goal.progress,
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info row
            Row(
              children: [
                _infoChip(Icons.folder_rounded, '${projects.length} مشروع', color),
                const SizedBox(width: 8),
                _infoChip(AppUtils.getStatusIcon(goal.status), goal.status,
                    AppUtils.getStatusColor(goal.status)),
                if (goal.deadline != null) ...[
                  const SizedBox(width: 8),
                  _infoChip(Icons.event_rounded, AppUtils.formatDate(goal.deadline), AppColors.accentBlue),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Projects
            SectionHeader(
              title: 'المشاريع (${projects.length})',
              actionLabel: '+ إضافة مشروع',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddProjectScreen(preselectedGoalId: goalId)),
              ),
            ),
            const SizedBox(height: 12),
            if (projects.isEmpty)
              const EmptyState(
                title: 'لا توجد مشاريع',
                subtitle: 'أضف مشروعاً لتحقيق هذا الهدف',
                icon: Icons.folder_open_rounded,
              )
            else
              ...projects.map((project) {
                final pc = AppUtils.goalColor(project.colorIndex);
                final tasks = provider.getTasksForProject(project.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: project.id)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [pc, pc.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.folder_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(project.title,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('${tasks.length} مهمة',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                          fontFamily: 'Cairo')),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${(project.progress * 100).round()}%',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: pc, fontFamily: 'Cairo')),
                                StatusBadge(status: project.status, compact: true),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AppProgressBar(progress: project.progress, color: pc, height: 6),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الهدف', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('سيتم حذف الهدف وجميع مشاريعه ومهامه. هل أنت متأكد؟',
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.deleteGoal(id);
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
}
