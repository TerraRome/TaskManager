import 'package:flutter/material.dart';

class ProjectItem {
  final String id;
  final String title;
  final String description;
  final Color color;
  final int totalTasks;
  final int completedTasks;
  final List<String> members;
  final DateTime deadline;

  const ProjectItem({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.totalTasks,
    required this.completedTasks,
    required this.members,
    required this.deadline,
  });

  double get progress =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  ProjectItem copyWith({
    String? id,
    String? title,
    String? description,
    Color? color,
    int? totalTasks,
    int? completedTasks,
    List<String>? members,
    DateTime? deadline,
  }) {
    return ProjectItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      members: members ?? this.members,
      deadline: deadline ?? this.deadline,
    );
  }
}
