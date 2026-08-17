import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/schedule/domain/models/task_item.dart';
import '../constants/app_colors.dart';
import '../storage/local_storage_service.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class TaskState {
  final List<TaskItem> tasks;
  final String searchQuery;
  final String? filterStatus; // 'all' | 'done' | 'pending'
  final Color? filterColor;

  const TaskState({
    this.tasks = const [],
    this.searchQuery = '',
    this.filterStatus,
    this.filterColor,
  });

  TaskState copyWith({
    List<TaskItem>? tasks,
    String? searchQuery,
    String? filterStatus,
    Color? filterColor,
    bool clearFilterColor = false,
    bool clearFilterStatus = false,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: clearFilterStatus ? null : filterStatus ?? this.filterStatus,
      filterColor: clearFilterColor ? null : filterColor ?? this.filterColor,
    );
  }

  /// Tasks filtered by date, search query, status, and color.
  List<TaskItem> tasksForDate(DateTime date) {
    return tasks.where((t) {
      // Date filter
      if (t.startTime != null) {
        final s = t.startTime!;
        if (s.year != date.year || s.month != date.month || s.day != date.day) {
          return false;
        }
      }
      // Search
      if (searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !(t.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)) {
        return false;
      }
      // Status filter
      if (filterStatus == 'done' && !t.isDone) return false;
      if (filterStatus == 'pending' && t.isDone) return false;
      // Color filter
      if (filterColor != null && t.color.toARGB32() != filterColor!.toARGB32()) return false;
      return true;
    }).toList();
  }

  /// All tasks matching search + filters (no date restriction) — for SearchPage.
  List<TaskItem> get filteredTasks {
    return tasks.where((t) {
      if (searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !(t.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)) {
        return false;
      }
      if (filterStatus == 'done' && !t.isDone) return false;
      if (filterStatus == 'pending' && t.isDone) return false;
      if (filterColor != null && t.color.toARGB32() != filterColor!.toARGB32()) return false;
      return true;
    }).toList();
  }

  int get totalTasks => tasks.length;
  int get doneTasks => tasks.where((t) => t.isDone).length;
  int get pendingTasks => tasks.where((t) => !t.isDone).length;
  double get completionRate => totalTasks == 0 ? 0 : doneTasks / totalTasks;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class TaskNotifier extends StateNotifier<TaskState> {
  TaskNotifier() : super(TaskState(tasks: _loadOrSeedTasks()));

  // ---- CRUD ---------------------------------------------------------------

  void addTask(TaskItem task) {
    final updated = [...state.tasks, task];
    state = state.copyWith(tasks: updated);
    LocalStorageService.saveTask(task);
  }

  void updateTask(TaskItem updated) {
    final tasks = state.tasks.map((t) => t.id == updated.id ? updated : t).toList();
    state = state.copyWith(tasks: tasks);
    LocalStorageService.saveTask(updated);
  }

  void deleteTask(String id) {
    final tasks = state.tasks.where((t) => t.id != id).toList();
    state = state.copyWith(tasks: tasks);
    LocalStorageService.deleteTask(id);
  }

  void toggleDone(String id) {
    final tasks = state.tasks
        .map((t) => t.id == id ? t.copyWith(isDone: !t.isDone) : t)
        .toList();
    state = state.copyWith(tasks: tasks);
    final toggled = tasks.firstWhere((t) => t.id == id);
    LocalStorageService.saveTask(toggled);
  }

  // ---- Filter / Search ----------------------------------------------------

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterStatus(String? status) {
    if (status == null) {
      state = state.copyWith(clearFilterStatus: true);
    } else {
      state = state.copyWith(filterStatus: status);
    }
  }

  void setFilterColor(Color? color) {
    if (color == null) {
      state = state.copyWith(clearFilterColor: true);
    } else {
      state = state.copyWith(filterColor: color);
    }
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      clearFilterStatus: true,
      clearFilterColor: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier();
});

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

/// Load from Hive on first build; seed with sample data if box is empty.
List<TaskItem> _loadOrSeedTasks() {
  final stored = LocalStorageService.loadTasks();
  if (stored.isNotEmpty) return stored;
  final seed = _sampleTasks();
  LocalStorageService.saveAllTasks(seed);
  return seed;
}

List<TaskItem> _sampleTasks() {
  final now = DateTime.now();
  return [
    TaskItem(
      id: 't1',
      title: 'UI Design Review',
      description: 'Review the latest mockups and provide feedback to the design team.',
      timeRange: '09:00 - 10:30 AM',
      startTime: DateTime(now.year, now.month, now.day, 9),
      endTime: DateTime(now.year, now.month, now.day, 10, 30),
      color: AppColors.taskBlue,
      members: ['Alice', 'Bob', 'Carol'],
      tags: ['Design', 'UI/UX'],
      projectId: 'p1',
    ),
    TaskItem(
      id: 't2',
      title: 'Sprint Planning',
      description: 'Plan tasks and story points for the upcoming sprint.',
      timeRange: '11:00 - 12:00 PM',
      startTime: DateTime(now.year, now.month, now.day, 11),
      endTime: DateTime(now.year, now.month, now.day, 12),
      color: AppColors.taskPurple,
      members: ['Dave', 'Eve'],
      tags: ['Agile', 'Planning'],
      projectId: 'p2',
    ),
    TaskItem(
      id: 't3',
      title: 'Backend API Integration',
      description: 'Connect the new endpoints to the mobile client.',
      timeRange: '13:00 - 15:00 PM',
      startTime: DateTime(now.year, now.month, now.day, 13),
      endTime: DateTime(now.year, now.month, now.day, 15),
      color: AppColors.taskGreen,
      members: ['Frank', 'Alice'],
      tags: ['Backend', 'API'],
      projectId: 'p1',
    ),
    TaskItem(
      id: 't4',
      title: 'User Testing Session',
      description: 'Conduct usability testing with 5 participants.',
      timeRange: '15:30 - 17:00 PM',
      startTime: DateTime(now.year, now.month, now.day, 15, 30),
      endTime: DateTime(now.year, now.month, now.day, 17),
      color: AppColors.taskOrange,
      members: ['Carol', 'Dave'],
      tags: ['Research', 'UX'],
      projectId: 'p2',
      isDone: true,
    ),
    TaskItem(
      id: 't5',
      title: 'Stakeholder Presentation',
      description: 'Present Q3 progress to stakeholders.',
      timeRange: '10:00 - 11:00 AM',
      startTime: DateTime(now.year, now.month, now.day + 1, 10),
      endTime: DateTime(now.year, now.month, now.day + 1, 11),
      color: AppColors.taskRed,
      members: ['Alice', 'Bob'],
      tags: ['Management'],
      projectId: 'p3',
    ),
    TaskItem(
      id: 't6',
      title: 'Code Review',
      description: 'Review pull requests from the team.',
      timeRange: '14:00 - 15:00 PM',
      startTime: DateTime(now.year, now.month, now.day + 1, 14),
      endTime: DateTime(now.year, now.month, now.day + 1, 15),
      color: AppColors.taskBlue,
      members: ['Frank'],
      tags: ['Engineering'],
      projectId: 'p1',
      isDone: true,
    ),
  ];
}
