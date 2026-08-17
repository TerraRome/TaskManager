import 'package:flutter/material.dart';

class TaskItem {
  final String id;
  final String title;
  final String? description;
  final String timeRange;
  final DateTime? startTime;
  final DateTime? endTime;
  final Color color;
  final List<String> members;
  final List<String> tags;
  final bool isDone;
  final String? projectId;

  const TaskItem({
    required this.id,
    required this.title,
    this.description,
    required this.timeRange,
    this.startTime,
    this.endTime,
    required this.color,
    this.members = const [],
    this.tags = const [],
    this.isDone = false,
    this.projectId,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timeRange,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    List<String>? members,
    List<String>? tags,
    bool? isDone,
    String? projectId,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeRange: timeRange ?? this.timeRange,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      members: members ?? this.members,
      tags: tags ?? this.tags,
      isDone: isDone ?? this.isDone,
      projectId: projectId ?? this.projectId,
    );
  }
}
