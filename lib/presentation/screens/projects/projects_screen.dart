import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/project_model.dart';
import '../../providers/app_provider.dart';
import 'project_detail_screen.dart';
import 'add_project_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = provider.projects;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, projects.length),
            Expanded(
              child: projects.isEmpty
                  ? EmptyState(
                      title: 'لا توجد مشاريع',
                      subtitle: 'أنشئ مشروعك الأول الآن',
                      icon: Icons.folder_open_rounded,
                      actionLabel: 'مشروع جديد',
                      onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddProjectScreen()),
                      ),
                    )
                  : _buildProjectsList(context, projects, isDark),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProjectScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'مشروع جديد',
          style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المشاريع',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                ),
                Text(
                  '$count مشروع',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context, List<ProjectModel> projects, bool isDark) {
    // Group by goal
    final provider = context.read<AppProvider>();
    final goals = provider.goals;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // Summary stats
        _buildSummaryRow(context, projects, isDark),
        const SizedBox(height: 20),
        if (goals.isEmpty)
          ...projects.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProjectCard(project: p),
              ))
        else
          ...goals.map((goal) {
            final goalProjects = projects.where((p) => p.goalId == goal.id).toList();
            if (goalProjects.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppUtils.goalColor(goal.colorIndex),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppUtils.goalColor(goal.colorIndex).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${goalProjects.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppUtils.goalColor(goal.colorIndex),
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...goalProjects.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProjectCard(project: p),
                    )),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, List<ProjectModel> projects, bool isDark) {
    final completed = projects.where((p) => p.status == 'مكتملة').length;
    final inProgress = projects.where((p) => p.status == 'قيد التنفيذ').length;
    final avgProgress = projects.isEmpty
        ? 0.0
        : projects.fold(0.0, (s, p) => s + p.progress) / projects.length;

    return AppCard(
      color: AppColors.primary.withOpacity(0.06),
      child: Row(
        children: [
          _summaryItem('${projects.length}', 'الكل', AppColors.primary, isDark),
          _summaryItem('$inProgress', 'جارية', AppColors.statusInProgress, isDark),
          _summaryItem('$completed', 'مكتملة', AppColors.statusCompleted, isDark),
          _summaryItem('${(avgProgress * 100).round()}%', 'تقدم', AppColors.secondary, isDark),
        ],
      ),
    );
  }

  Widget _summaryItem(String val, String label, Color color, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final color = AppUtils.goalColor(project.colorIndex);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = provider.getTasksForProject(project.id);
    final completedTasks = tasks.where((t) => t.status == 'مكتملة').length;
    final isOverdue = project.deadline != null &&
        project.deadline!.isBefore(DateTime.now()) &&
        project.status != 'مكتملة';

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: project.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.folder_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.description.isNotEmpty)
                      Text(
                        project.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: project.status, compact: true),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressBar(progress: project.progress, color: color, height: 8),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.task_alt, size: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '$completedTasks/${tasks.length} مهمة',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(width: 12),
              if (project.deadline != null) ...[
                Icon(Icons.event_rounded, size: 14,
                    color: isOverdue ? AppColors.priorityCritical
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                const SizedBox(width: 4),
                Text(
                  AppUtils.formatDate(project.deadline),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? AppColors.priorityCritical
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${(project.progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
