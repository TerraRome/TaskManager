import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/project_provider.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../projects/domain/models/project_item.dart';
import '../../../schedule/domain/models/task_item.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  int _selectedFilter = 0;

  static const _filters = ['All', 'Tasks', 'Projects'];

  List<TaskItem> _filteredTasks(List<TaskItem> all) => all
      .where((t) =>
          t.title.toLowerCase().contains(_query.toLowerCase()) ||
          (t.description?.toLowerCase().contains(_query.toLowerCase()) ??
              false) ||
          t.tags.any((tag) =>
              tag.toLowerCase().contains(_query.toLowerCase())))
      .toList();

  List<ProjectItem> _filteredProjects(List<ProjectItem> all) => all
      .where((p) =>
          p.title.toLowerCase().contains(_query.toLowerCase()) ||
          p.description.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allTasks = ref.watch(taskProvider).tasks;
    final allProjects = ref.watch(projectsWithTaskCountProvider);
    final showTasks = _selectedFilter == 0 || _selectedFilter == 1;
    final showProjects = _selectedFilter == 0 || _selectedFilter == 2;
    final tasks = showTasks ? _filteredTasks(allTasks) : <TaskItem>[];
    final projects = showProjects ? _filteredProjects(allProjects) : <ProjectItem>[];
    final hasResults = tasks.isNotEmpty || projects.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, cs),
            _buildFilterRow(cs),
            Expanded(
              child: _query.isEmpty
                  ? _buildEmptyState(cs)
                  : !hasResults
                      ? _buildNoResults(cs)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          children: [
                            if (tasks.isNotEmpty) ...[
                              _buildSectionLabel('Tasks', tasks.length, cs),
                              const SizedBox(height: 8),
                              ...tasks.map((t) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: _TaskResultCard(task: t),
                                  )),
                              const SizedBox(height: 8),
                            ],
                            if (projects.isNotEmpty) ...[
                              _buildSectionLabel(
                                  'Projects', projects.length, cs),
                              const SizedBox(height: 8),
                              ...projects.map((p) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: _ProjectResultCard(project: p),
                                  )),
                            ],
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                style: AppTextStyles.body.copyWith(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search tasks, projects...',
                  hintStyle: AppTextStyles.body
                      .copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 20, color: cs.onSurface.withValues(alpha: 0.4)),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          child: Icon(Icons.close_rounded,
                              size: 18,
                              color: cs.onSurface.withValues(alpha: 0.4)),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        children: List.generate(_filters.length, (i) {
          final isSelected = i == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : cs.surface,
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
                      : cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionLabel(String label, int count, ColorScheme cs) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return EmptyState(
      icon: Icons.search_rounded,
      title: 'Search Anything',
      description: 'Find tasks, projects, tags...\nStart typing to see results.',
      iconColor: AppColors.primary,
    );
  }

  Widget _buildNoResults(ColorScheme cs) {
    return EmptyState.noResults(query: _query);
  }
}

class _TaskResultCard extends StatelessWidget {
  final TaskItem task;
  const _TaskResultCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/task-detail', arguments: task),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: task.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(task.title,
                                style: AppTextStyles.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  task.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Task',
                                style: AppTextStyles.label
                                    .copyWith(color: task.color)),
                          ),
                        ],
                      ),
                      if (task.description != null) ...[
                        const SizedBox(height: 4),
                        Text(task.description!,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                      if (task.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          children: task.tags
                              .take(3)
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Text(tag,
                                        style: AppTextStyles.label
                                            .copyWith(
                                                color: AppColors.primary,
                                                fontSize: 10)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectResultCard extends StatelessWidget {
  final ProjectItem project;
  const _ProjectResultCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percent = (project.progress * 100).toInt();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/project-detail',
          arguments: project),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: project.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(project.title,
                                style: AppTextStyles.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: project.color
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('$percent%',
                                style: AppTextStyles.label.copyWith(
                                    color: project.color)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(project.description,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: project.progress,
                          minHeight: 4,
                          backgroundColor:
                              cs.onSurface.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              project.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
