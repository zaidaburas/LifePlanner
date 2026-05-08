import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../providers/app_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = provider.dashboardStats;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            _buildOverviewRow(context, stats, isDark),
            const SizedBox(height: 8),
            _buildTabBar(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ProgressTab(provider: provider, isDark: isDark),
                  _TimeTab(provider: provider, isDark: isDark),
                  _ObstaclesTab(provider: provider, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'التحليلات',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
            ),
          ),
          const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 28),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(BuildContext context, Map<String, dynamic> stats, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _kpiCard('${stats['completionRate']}%', 'معدل الإنجاز', Icons.pie_chart_rounded, AppColors.primary, isDark),
          const SizedBox(width: 10),
          _kpiCard('${stats['completedTasks']}', 'مكتملة', Icons.check_circle_outline, AppColors.statusCompleted, isDark),
          const SizedBox(width: 10),
          _kpiCard('${stats['overdueTasks']}', 'متأخرة', Icons.warning_amber_rounded, AppColors.priorityHigh, isDark),
          const SizedBox(width: 10),
          _kpiCard(AppUtils.formatDuration(stats['totalMinutes'] as int), 'وقت كلي', Icons.timer_rounded, AppColors.secondary, isDark),
        ],
      ),
    );
  }

  Widget _kpiCard(String val, String label, IconData icon, Color color, bool isDark) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(val,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        indicator: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)],
        ),
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: 'الإنجاز'), Tab(text: 'الوقت'), Tab(text: 'العوائق')],
      ),
    );
  }
}

// ─── PROGRESS TAB ───
class _ProgressTab extends StatelessWidget {
  final AppProvider provider;
  final bool isDark;
  const _ProgressTab({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final byType = provider.tasksByType;
    final tasks = provider.tasks;
    final completed = tasks.where((t) => t.status == 'مكتملة').length;
    final inProgress = tasks.where((t) => t.status == 'قيد التنفيذ').length;
    final paused = tasks.where((t) => t.status == 'متوقفة').length;
    final notStarted = tasks.where((t) => t.status == 'لم تبدأ').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: [
        // Status donut chart
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('توزيع حالات المهام',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              const SizedBox(height: 16),
              if (tasks.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا توجد بيانات كافية', style: TextStyle(fontFamily: 'Cairo')),
                ))
              else
                SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            sections: [
                              if (completed > 0)
                                PieChartSectionData(
                                  value: completed.toDouble(),
                                  color: AppColors.statusCompleted,
                                  radius: 30,
                                  title: '$completed',
                                  titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              if (inProgress > 0)
                                PieChartSectionData(
                                  value: inProgress.toDouble(),
                                  color: AppColors.statusInProgress,
                                  radius: 30,
                                  title: '$inProgress',
                                  titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              if (paused > 0)
                                PieChartSectionData(
                                  value: paused.toDouble(),
                                  color: AppColors.statusPaused,
                                  radius: 30,
                                  title: '$paused',
                                  titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              if (notStarted > 0)
                                PieChartSectionData(
                                  value: notStarted.toDouble(),
                                  color: AppColors.statusNotStarted,
                                  radius: 30,
                                  title: '$notStarted',
                                  titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legend('مكتملة', AppColors.statusCompleted, completed),
                          _legend('جارية', AppColors.statusInProgress, inProgress),
                          _legend('متوقفة', AppColors.statusPaused, paused),
                          _legend('لم تبدأ', AppColors.statusNotStarted, notStarted),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // By task type bar
        if (byType.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('المهام حسب النوع',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 16),
                ...byType.entries.map((e) {
                  final color = AppUtils.getTaskTypeColor(e.key);
                  final maxVal = byType.values.reduce((a, b) => a > b ? a : b);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Row(
                            children: [
                              Icon(AppUtils.getTaskTypeIcon(e.key), size: 14, color: color),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(e.key,
                                    style: TextStyle(fontSize: 11, color: color, fontFamily: 'Cairo'),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: e.value / maxVal,
                              minHeight: 10,
                              backgroundColor: isDark ? AppColors.darkBorder : AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${e.value}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Goals progress
        if (provider.goals.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تقدم الأهداف',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 16),
                ...provider.goals.map((goal) {
                  final c = AppUtils.goalColor(goal.colorIndex);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(goal.title,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            Text('${(goal.progress * 100).round()}%',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c, fontFamily: 'Cairo')),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppProgressBar(progress: goal.progress, color: c, height: 8),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _legend(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontFamily: 'Cairo')),
          const SizedBox(width: 6),
          Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}

// ─── TIME TAB ───
class _TimeTab extends StatelessWidget {
  final AppProvider provider;
  final bool isDark;
  const _TimeTab({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final timeByType = provider.timeByType;
    final tasks = provider.tasks;
    final totalMins = tasks.fold(0, (s, t) => s + t.actualMinutes);
    final estimatedMins = tasks.fold(0, (s, t) => s + t.estimatedMinutes);
    final efficiency = estimatedMins > 0 ? (totalMins / estimatedMins).clamp(0.0, 2.0) : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: [
        // Time summary
        Row(
          children: [
            Expanded(
              child: AppCard(
                child: Column(
                  children: [
                    const Icon(Icons.timer_rounded, color: AppColors.secondary, size: 26),
                    const SizedBox(height: 8),
                    Text(AppUtils.formatDuration(totalMins),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary, fontFamily: 'Cairo')),
                    Text('الوقت الفعلي',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppCard(
                child: Column(
                  children: [
                    const Icon(Icons.hourglass_bottom, color: AppColors.accentBlue, size: 26),
                    const SizedBox(height: 8),
                    Text(AppUtils.formatDuration(estimatedMins),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accentBlue, fontFamily: 'Cairo')),
                    Text('الوقت المقدر',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppCard(
                child: Column(
                  children: [
                    Icon(Icons.speed_rounded,
                        color: efficiency <= 1.0 ? AppColors.statusCompleted : AppColors.priorityHigh,
                        size: 26),
                    const SizedBox(height: 8),
                    Text('${(efficiency * 100).round()}%',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: efficiency <= 1.0 ? AppColors.statusCompleted : AppColors.priorityHigh,
                            fontFamily: 'Cairo')),
                    Text('الكفاءة',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Top time-consuming tasks
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('أكثر الأنواع استهلاكاً للوقت',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              const SizedBox(height: 14),
              if (timeByType.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('لا توجد بيانات وقت مسجلة',
                        style: TextStyle(fontFamily: 'Cairo',
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                  ),
                )
              else
                ...(() {
                  final sorted = timeByType.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final maxVal = sorted.first.value;
                  return sorted.map((e) {
                    final color = AppUtils.getTaskTypeColor(e.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(AppUtils.getTaskTypeIcon(e.key), size: 14, color: color),
                              const SizedBox(width: 6),
                              Text(e.key, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                              const Spacer(),
                              Text(AppUtils.formatDuration(e.value),
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: e.value / maxVal,
                              minHeight: 8,
                              backgroundColor: isDark ? AppColors.darkBorder : AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                })(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tasks with most time spent
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('المهام الأكثر وقتاً',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              const SizedBox(height: 14),
              ...(() {
                final sorted = List.from(provider.tasks)
                  ..sort((a, b) => b.actualMinutes.compareTo(a.actualMinutes));
                return sorted.take(5).map<Widget>((t) {
                  final color = AppUtils.getTaskTypeColor(t.taskType);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Icon(AppUtils.getTaskTypeIcon(t.taskType), size: 16, color: color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(t.title,
                              style: const TextStyle(fontSize: 13, fontFamily: 'Cairo'),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Text(AppUtils.formatDuration(t.actualMinutes),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
                      ],
                    ),
                  );
                }).toList();
              })(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── OBSTACLES TAB ───
class _ObstaclesTab extends StatelessWidget {
  final AppProvider provider;
  final bool isDark;
  const _ObstaclesTab({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final obstacles = provider.obstacles;
    final byImpact = provider.obstaclesByImpact;
    final resolved = obstacles.where((o) => o.isResolved).length;
    final unresolved = obstacles.length - resolved;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: [
        // Summary
        Row(
          children: [
            Expanded(
              child: AppCard(
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.priorityHigh, size: 24),
                    const SizedBox(height: 6),
                    Text('${obstacles.length}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                            color: AppColors.priorityHigh, fontFamily: 'Cairo')),
                    Text('إجمالي العوائق',
                        style: TextStyle(fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppCard(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.statusCompleted, size: 24),
                    const SizedBox(height: 6),
                    Text('$resolved',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                            color: AppColors.statusCompleted, fontFamily: 'Cairo')),
                    Text('محلولة',
                        style: TextStyle(fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppCard(
                child: Column(
                  children: [
                    const Icon(Icons.pending_actions, color: AppColors.statusPaused, size: 24),
                    const SizedBox(height: 6),
                    Text('$unresolved',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                            color: AppColors.statusPaused, fontFamily: 'Cairo')),
                    Text('قائمة',
                        style: TextStyle(fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // By impact
        if (byImpact.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('العوائق حسب مستوى التأثير',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 14),
                ...byImpact.entries.map((e) {
                  final color = AppUtils.getImpactColor(e.key);
                  final max = byImpact.values.reduce((a, b) => a > b ? a : b);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(e.key, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: e.value / max,
                              minHeight: 10,
                              backgroundColor: isDark ? AppColors.darkBorder : AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${e.value}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Recent obstacles
        if (obstacles.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('آخر العوائق المسجلة',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 12),
                ...obstacles.take(5).map((obs) {
                  final color = AppUtils.getImpactColor(obs.impactLevel);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: color, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(obs.title,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(AppUtils.formatFullDate(obs.occurredAt),
                                  style: TextStyle(fontSize: 11,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: obs.isResolved
                                ? AppColors.statusCompleted.withOpacity(0.12)
                                : AppColors.statusPaused.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            obs.isResolved ? 'محلول' : 'قائم',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: obs.isResolved ? AppColors.statusCompleted : AppColors.statusPaused,
                                fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        if (obstacles.isEmpty)
          const EmptyState(
            title: 'لا توجد عوائق',
            subtitle: 'رائع! لم تواجه أي عوائق حتى الآن',
            icon: Icons.shield_rounded,
          ),
      ],
    );
  }
}
