import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/projects/domain/models/project_item.dart';
import '../../features/schedule/domain/models/task_item.dart';
import '../constants/app_colors.dart';
import '../storage/local_storage_service.dart';
import 'task_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ProjectState {
  final List<ProjectItem> projects;
  final String searchQuery;

  const ProjectState({
    this.projects = const [],
    this.searchQuery = '',
  });

  ProjectState copyWith({
    List<ProjectItem>? projects,
    String? searchQuery,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ProjectItem> get filteredProjects {
    if (searchQuery.isEmpty) return projects;
    return projects
        .where((p) =>
            p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ProjectNotifier extends StateNotifier<ProjectState> {
  ProjectNotifier() : super(ProjectState(projects: _loadOrSeedProjects()));

  void addProject(ProjectItem project) {
    final updated = [...state.projects, project];
    state = state.copyWith(projects: updated);
    LocalStorageService.saveProject(project);
  }

  void updateProject(ProjectItem updated) {
    final projects =
        state.projects.map((p) => p.id == updated.id ? updated : p).toList();
    state = state.copyWith(projects: projects);
    LocalStorageService.saveProject(updated);
  }

  void deleteProject(String id) {
    final projects = state.projects.where((p) => p.id != id).toList();
    state = state.copyWith(projects: projects);
    LocalStorageService.deleteProject(id);
  }

  /// Sync completedTasks count from TaskState for a given project.
  void syncFromTasks(List<TaskItem> tasks, String projectId) {
    final project = state.projects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => state.projects.first,
    );
    final projectTasks = tasks.where((t) => t.projectId == projectId).toList();
    final done = projectTasks.where((t) => t.isDone).length;
    updateProject(project.copyWith(
      totalTasks: projectTasks.length,
      completedTasks: done,
    ));
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final projectProvider =
    StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier();
});

/// Derived provider: project list with live task counts from taskProvider.
final projectsWithTaskCountProvider = Provider<List<ProjectItem>>((ref) {
  final projectState = ref.watch(projectProvider);
  final taskState = ref.watch(taskProvider);

  return projectState.projects.map((project) {
    final projectTasks =
        taskState.tasks.where((t) => t.projectId != null && t.projectId == project.id).toList();
    final done = projectTasks.where((t) => t.isDone).length;
    return project.copyWith(
      totalTasks: projectTasks.length,
      completedTasks: done,
    );
  }).toList();
});

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

/// Load from Hive on first build; seed with sample data if box is empty.
List<ProjectItem> _loadOrSeedProjects() {
  final stored = LocalStorageService.loadProjects();
  if (stored.isNotEmpty) return stored;
  final seed = _sampleProjects();
  LocalStorageService.saveAllProjects(seed);
  return seed;
}

List<ProjectItem> _sampleProjects() {
  return [
    ProjectItem(
      id: 'p1',
      title: 'Fintech App Redesign',
      description: 'Complete UI/UX overhaul of the mobile banking application.',
      color: AppColors.taskBlue,
      totalTasks: 12,
      completedTasks: 7,
      members: ['Alice', 'Bob', 'Frank'],
      deadline: DateTime.now().add(const Duration(days: 14)),
    ),
    ProjectItem(
      id: 'p2',
      title: 'Q4 Marketing Assets',
      description: 'Design and produce all marketing materials for Q4 campaign.',
      color: AppColors.taskPurple,
      totalTasks: 8,
      completedTasks: 3,
      members: ['Carol', 'Dave', 'Eve'],
      deadline: DateTime.now().add(const Duration(days: 30)),
    ),
    ProjectItem(
      id: 'p3',
      title: 'Design System v2.0',
      description: 'Build a comprehensive design system for all product teams.',
      color: AppColors.taskGreen,
      totalTasks: 20,
      completedTasks: 15,
      members: ['Alice', 'Bob'],
      deadline: DateTime.now().add(const Duration(days: 60)),
    ),
    ProjectItem(
      id: 'p4',
      title: 'Dashboard Analytics',
      description: 'Develop real-time analytics dashboard for internal use.',
      color: AppColors.taskOrange,
      totalTasks: 6,
      completedTasks: 1,
      members: ['Frank', 'Dave'],
      deadline: DateTime.now().add(const Duration(days: 45)),
    ),
  ];
}
