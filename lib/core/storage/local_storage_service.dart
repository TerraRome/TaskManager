import 'package:hive_flutter/hive_flutter.dart';
import '../../features/projects/domain/models/project_item.dart';
import '../../features/schedule/domain/models/task_item.dart';
import 'task_item_adapter.dart';
import 'project_item_adapter.dart';

class LocalStorageService {
  static const String _tasksBox = 'tasks';
  static const String _projectsBox = 'projects';

  /// Call once in main() before runApp.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskItemAdapter());
    Hive.registerAdapter(ProjectItemAdapter());
    await Hive.openBox<TaskItem>(_tasksBox);
    await Hive.openBox<ProjectItem>(_projectsBox);
  }

  // ── Tasks ──────────────────────────────────────────────────────────────────

  static Box<TaskItem> get _tasks => Hive.box<TaskItem>(_tasksBox);

  static List<TaskItem> loadTasks() => _tasks.values.toList();

  static Future<void> saveTask(TaskItem task) =>
      _tasks.put(task.id, task);

  static Future<void> deleteTask(String id) => _tasks.delete(id);

  static Future<void> saveAllTasks(List<TaskItem> tasks) async {
    await _tasks.clear();
    final map = {for (final t in tasks) t.id: t};
    await _tasks.putAll(map);
  }

  // ── Projects ───────────────────────────────────────────────────────────────

  static Box<ProjectItem> get _projects =>
      Hive.box<ProjectItem>(_projectsBox);

  static List<ProjectItem> loadProjects() => _projects.values.toList();

  static Future<void> saveProject(ProjectItem project) =>
      _projects.put(project.id, project);

  static Future<void> deleteProject(String id) => _projects.delete(id);

  static Future<void> saveAllProjects(List<ProjectItem> projects) async {
    await _projects.clear();
    final map = {for (final p in projects) p.id: p};
    await _projects.putAll(map);
  }
}
