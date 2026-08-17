import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../core/providers/project_provider.dart';
import '../../../../features/projects/domain/models/project_item.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  int _selectedPeriod = 0; // 0=Week, 1=Month, 2=Year
  static const _periods = ['Week', 'Month', 'Year'];

  // Sample data per period
  static const _weekData = [4, 7, 5, 8, 3, 6, 9];
  static const _monthData = [18, 24, 20, 28, 22, 26, 30, 25, 19, 27, 23, 21];
  static const _yearData = [65, 80, 72, 90, 85, 95, 88, 76, 92, 84, 78, 96];

  static const _weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const _yearLabels = [
    '2020', '2021', '2022', '2023', '2024', '2025',
    '2026', '2027', '2028', '2029', '2030', '2031'
  ];

  List<int> get _currentData {
    switch (_selectedPeriod) {
      case 1: return _monthData;
      case 2: return _yearData;
      default: return _weekData;
    }
  }

  List<String> get _currentLabels {
    switch (_selectedPeriod) {
      case 1: return _monthLabels;
      case 2: return _yearLabels;
      default: return _weekLabels;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final taskState = ref.watch(taskProvider);
    final projects = ref.watch(projectsWithTaskCountProvider);
    final total = taskState.totalTasks;
    final done = taskState.doneTasks;
    final pending = taskState.pendingTasks;
    final score = total > 0 ? (done / total * 100).round() : 0;
    final maxVal = _currentData.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, cs),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _buildSummaryRow(cs, total, done, pending),
                  const SizedBox(height: 24),
                  _buildPeriodSelector(cs),
                  const SizedBox(height: 20),
                  _buildBarChart(cs, maxVal),
                  const SizedBox(height: 24),
                  _buildTaskBreakdown(cs, done, pending),
                  const SizedBox(height: 24),
                  _buildProductivityCard(cs, score),
                  const SizedBox(height: 24),
                  _buildTopProjectsCard(cs, projects),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: cs.onSurface),
            ),
          ),
          const Spacer(),
          Text('Statistics', style: AppTextStyles.heading2),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ColorScheme cs, int total, int done, int pending) {
    return Row(
      children: [
        _buildSummaryCard(cs,
            label: 'Total Tasks',
            value: '$total',
            icon: Icons.task_alt_rounded,
            color: AppColors.taskBlue),
        const SizedBox(width: 12),
        _buildSummaryCard(cs,
            label: 'Completed',
            value: '$done',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.taskGreen),
        const SizedBox(width: 12),
        _buildSummaryCard(cs,
            label: 'Pending',
            value: '$pending',
            icon: Icons.pending_outlined,
            color: AppColors.taskOrange),
      ],
    );
  }

  Widget _buildSummaryCard(
    ColorScheme cs, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: AppTextStyles.heading2.copyWith(color: cs.onSurface)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(ColorScheme cs) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_periods.length, (i) {
          final isSelected = i == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _periods[i],
                  style: AppTextStyles.captionMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBarChart(ColorScheme cs, int maxVal) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text('Tasks Completed', style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(
            _selectedPeriod == 0
                ? 'This week'
                : _selectedPeriod == 1
                    ? 'This year (monthly)'
                    : 'All years',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_currentData.length, (i) {
                final val = _currentData[i];
                final heightRatio = maxVal > 0 ? val / maxVal : 0.0;
                final isHighest = val == maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isHighest)
                          Text(
                            '$val',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: 100 * heightRatio,
                          decoration: BoxDecoration(
                            color: isHighest
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currentLabels[i],
                          style: AppTextStyles.label.copyWith(fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskBreakdown(ColorScheme cs, int done, int pending) {
    final breakdown = [
      _BreakdownItem('Design', 32, AppColors.taskBlue),
      _BreakdownItem('Development', 45, AppColors.taskPurple),
      _BreakdownItem('Research', 13, AppColors.taskGreen),
      _BreakdownItem('Meeting', 10, AppColors.taskOrange),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text('Task Breakdown', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          ...breakdown.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.label,
                              style: AppTextStyles.body
                                  .copyWith(color: cs.onSurface)),
                        ),
                        Text('${item.percent}%',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: cs.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.percent / 100,
                        backgroundColor:
                            item.color.withValues(alpha: 0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(item.color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProductivityCard(ColorScheme cs, int score) {
    final prev = (score - 5).clamp(0, 100);
    final diff = score - prev;
    final diffText = diff >= 0 ? '+$diff%' : '$diff%';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productivity Score',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score%',
                  style: AppTextStyles.heading1
                      .copyWith(color: Colors.white, fontSize: 36),
                ),
                const SizedBox(height: 4),
                Text(
                  '$diffText from last period',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProjectsCard(ColorScheme cs, List<ProjectItem> projects) {
    final top = projects
        .where((p) => p.totalTasks > 0)
        .toList()
      ..sort((a, b) => b.completedTasks.compareTo(a.completedTasks));
    final display = top.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text('Top Projects', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          ...display.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 40,
                      decoration: BoxDecoration(
                        color: p.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: cs.onSurface),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: p.totalTasks > 0
                                  ? p.completedTasks / p.totalTasks
                                  : 0.0,
                              backgroundColor:
                                  p.color.withValues(alpha: 0.15),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(p.color),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${p.completedTasks}/${p.totalTasks}',
                      style: AppTextStyles.caption
                          .copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _BreakdownItem {
  final String label;
  final int percent;
  final Color color;
  const _BreakdownItem(this.label, this.percent, this.color);
}


