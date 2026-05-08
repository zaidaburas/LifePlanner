import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/task_model.dart';
import '../../providers/app_provider.dart';
import 'task_detail_screen.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final surf = isDark ? AppColors.darkSurface : AppColors.surface;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, provider, isDark),
            if (_showSearch) _buildSearchBar(context, provider, isDark),
            _buildFiltersRow(context, provider, isDark),
            _buildSortRow(context, provider, isDark),
            _buildTabBar(surf, isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TaskList(
                    tasks: provider.filteredTasks,
                    emptyTitle: 'لا توجد مهام',
                    emptySubtitle: 'أضف مهمتك الأولى الآن',
                    emptyIcon: Icons.task_alt,
                  ),
                  _TaskList(
                    tasks: provider.filteredTasks
                        .where((t) => t.status == AppConstants.statusInProgress)
                        .toList(),
                    emptyTitle: 'لا توجد مهام جارية',
                    emptySubtitle: 'ابدأ بتنفيذ إحدى مهامك',
                    emptyIcon: Icons.timelapse,
                  ),
                  _TaskList(
                    tasks: provider.urgentTasks,
                    emptyTitle: 'لا توجد مهام عاجلة',
                    emptySubtitle: 'عمل رائع! كل شيء تحت السيطرة',
                    emptyIcon: Icons.flash_on_rounded,
                  ),
                  _TaskList(
                    tasks: provider.overdueTasks,
                    emptyTitle: 'لا توجد مهام متأخرة',
                    emptySubtitle: 'أنت في الموعد! استمر',
                    emptyIcon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'مهمة جديدة',
          style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'المهام',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                provider.setSearchQuery('');
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            onPressed: () => _showFilterSheet(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        onChanged: provider.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'ابحث عن مهمة...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    provider.setSearchQuery('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context, AppProvider provider, bool isDark) {
    final filters = ['الكل', ...AppConstants.defaultTaskTypes,...provider.allTaskTypes];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == 0
              ? provider.filterType.isEmpty
              : provider.filterType == filters[i];
          final color = i == 0 ? AppColors.primary : AppUtils.getTaskTypeColor(filters[i]);
          return GestureDetector(
            onTap: () => provider.setFilterType(i == 0 ? '' : filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i > 0) ...[
                    Icon(AppUtils.getTaskTypeIcon(filters[i]),
                        size: 13,
                        color: isSelected ? Colors.white : color),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    filters[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      fontFamily: 'Cairo',
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

  Widget _buildSortRow(BuildContext context, AppProvider provider, bool isDark) {
    final sorts = ['أولوية', 'موعد', 'تقدم'];
    final icons = [Icons.flag_rounded, Icons.event, Icons.trending_up];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Text(
            'ترتيب:',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(
            sorts.length,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => provider.setSortMode(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider.sortMode == i
                        ? AppColors.primary.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: provider.sortMode == i
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icons[i], size: 13,
                          color: provider.sortMode == i
                              ? AppColors.primary
                              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                      const SizedBox(width: 4),
                      Text(
                        sorts[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: provider.sortMode == i
                              ? AppColors.primary
                              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color surf, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        unselectedLabelStyle:
            const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
        labelColor: AppColors.primary,
        unselectedLabelColor:
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        indicator: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'الكل'),
          Tab(text: 'جارية'),
          Tab(text: 'عاجلة'),
          Tab(text: 'متأخرة'),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(provider: provider),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;

  const _TaskList({
    required this.tasks,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyState(
        title: emptyTitle,
        subtitle: emptySubtitle,
        icon: emptyIcon,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _TaskCard(task: tasks[i]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final typeColor = AppUtils.getTaskTypeColor(task.taskType);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = task.deadline != null &&
        task.deadline!.isBefore(DateTime.now()) &&
        task.status != 'مكتملة';

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)),
      ),
      border: Border.all(
        color: task.isUrgent
            ? AppColors.secondary.withOpacity(0.4)
            : isOverdue
                ? AppColors.priorityCritical.withOpacity(0.3)
                : (isDark ? AppColors.darkBorder : AppColors.border),
        width: task.isUrgent || isOverdue ? 1.5 : 1,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppUtils.getTaskTypeIcon(task.taskType),
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo', 
                        decoration: task.status == 'مكتملة'
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == 'مكتملة'
                            ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriorityBadge(priority: task.priority, compact: true),
                  if (task.isUrgent) ...[
                    const SizedBox(height: 4),
                    const UrgentBadge(compact: true),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppProgressBar(
                  progress: task.progress,
                  color: typeColor,
                  height: 6,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(task.progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StatusBadge(status: task.status, compact: true),
              const SizedBox(width: 8),
              if (task.deadline != null) ...[
                Icon(
                  Icons.event_rounded,
                  size: 13,
                  color: isOverdue
                      ? AppColors.priorityCritical
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
                const SizedBox(width: 3),
                Text(
                  AppUtils.formatDate(task.deadline),
                  style: TextStyle(
                    fontSize: 11,
                    color: isOverdue
                        ? AppColors.priorityCritical
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(Icons.access_time, size: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              const SizedBox(width: 3),
              Text(
                AppUtils.formatDuration(task.estimatedMinutes),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.taskType,
                  style: TextStyle(
                    fontSize: 10,
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final AppProvider provider;
  const _FilterSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('فلترة حسب الحالة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _filterChip(context, '', 'الكل', provider),
              ...AppConstants.taskStatuses.map((s) => _filterChip(context, s, s, provider)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                provider.setFilterStatus('');
                Navigator.pop(context);
              },
              child: const Text('إعادة تعيين'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String val, String label, AppProvider provider) {
    final isSelected = provider.filterStatus == val;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        provider.setFilterStatus(val);
        Navigator.pop(context);
      },
    );
  }
}
