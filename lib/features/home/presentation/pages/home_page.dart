import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../schedule/presentation/widgets/schedule_bottom_nav.dart';
import '../widgets/stat_card.dart';
import '../widgets/home_task_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentNavIndex = 0;

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/schedule');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/projects');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final today = DateTime.now();
    final todayTasks = taskState.tasksForDate(today);
    final doneTodayCount = todayTasks.where((t) => t.isDone).length;
    final totalTodayCount = todayTasks.length;
    final pendingCount = todayTasks.where((t) => !t.isDone).length;
    final progressRate = totalTodayCount == 0 ? 0.0 : doneTodayCount / totalTodayCount;
    final progressPercent = (progressRate * 100).round();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(
                child: _buildStatsRow(
                  total: totalTodayCount,
                  pending: pendingCount,
                  done: doneTodayCount,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildProgressSection(
                  done: doneTodayCount,
                  total: totalTodayCount,
                  percent: progressPercent,
                  rate: progressRate,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Today's Tasks", style: AppTextStyles.heading3),
                      Text('${todayTasks.length} tasks',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ),
              if (todayTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                    child: Column(
                      children: [
                        Icon(Icons.task_alt_rounded,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text('No tasks today',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4),
                            )),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20,
                          index == todayTasks.length - 1 ? 120 : 10),
                      child: HomeTaskCard(task: todayTasks[index]),
                    ),
                    childCount: todayTasks.length,
                  ),
                ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScheduleBottomNav(
              currentIndex: _currentNavIndex,
              onTap: _onNavTap,
            ),
          ),
          Positioned(
            right: 28,
            bottom: 104,
            child: _buildFab(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting, style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text('Alex Morgan 👋', style: AppTextStyles.heading1),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/search'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.search_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Center(
                  child: Text(
                    'AM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow({
    required int total,
    required int pending,
    required int done,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              value: '$total',
              label: 'Tasks Today',
              icon: Icons.task_alt_rounded,
              color: AppColors.taskBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              value: '$pending',
              label: 'In Progress',
              icon: Icons.timelapse_rounded,
              color: AppColors.taskOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              value: '$done',
              label: 'Completed',
              icon: Icons.check_circle_rounded,
              color: AppColors.taskGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection({
    required int done,
    required int total,
    required int percent,
    required double rate,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Overall Progress', style: AppTextStyles.bodyMedium),
                Text('$percent%',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: rate,
                minHeight: 8,
                backgroundColor: AppColors.primaryLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text('$done of $total tasks completed today',
                style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/new-task'),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}
