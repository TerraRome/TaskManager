import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/project_provider.dart';
import '../../domain/models/project_item.dart';
import '../widgets/project_card.dart';
import '../../../schedule/presentation/widgets/schedule_bottom_nav.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_bottom_sheet.dart';

class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  int _currentNavIndex = 2;
  int _selectedFilter = 0;
  FilterResult _filterResult = FilterResult.empty();

  static const _filters = ['All', 'Active', 'Completed'];

  List<ProjectItem> _getFiltered(List<ProjectItem> projects) {
    switch (_selectedFilter) {
      case 1:
        return projects.where((p) => p.progress < 1.0).toList();
      case 2:
        return projects.where((p) => p.progress >= 1.0).toList();
      default:
        return projects;
    }
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/schedule');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsWithTaskCountProvider);
    final filtered = _getFiltered(projects);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildSummaryRow(projects)),
              SliverToBoxAdapter(child: _buildFilterRow()),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: EmptyState.noProjects(
                    onAction: () => Navigator.pushNamed(context, '/new-task'),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: EdgeInsets.fromLTRB(
                        20, 0, 20,
                        index == filtered.length - 1 ? 120 : 12,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/project-detail',
                          arguments: filtered[index],
                        ),
                        child: ProjectCard(project: filtered[index]),
                      ),
                    ),
                    childCount: filtered.length,
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
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            const Spacer(),
            Text('Projects', style: AppTextStyles.heading2),
            const Spacer(),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/search'),
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
                    child: Icon(Icons.search_rounded,
                        size: 18, color: cs.onSurface),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final result = await FilterBottomSheet.show(
                      context,
                      config: FilterConfig.projects(),
                      current: _filterResult,
                    );
                    if (result != null) setState(() => _filterResult = result);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _filterResult.isEmpty
                          ? cs.surface
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: _filterResult.isEmpty ? cs.onSurface : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(List<ProjectItem> projects) {
    final active = projects.where((p) => p.progress < 1.0).length;
    final completed = projects.where((p) => p.progress >= 1.0).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _buildSummaryChip(
            label: 'Total',
            value: '${projects.length}',
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          _buildSummaryChip(
            label: 'Active',
            value: '$active',
            color: AppColors.taskOrange,
          ),
          const SizedBox(width: 10),
          _buildSummaryChip(
            label: 'Done',
            value: '$completed',
            color: AppColors.taskGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.heading2.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: List.generate(_filters.length, (i) {
          final isSelected = i == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Text(
                _filters[i],
                style: AppTextStyles.captionMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
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
