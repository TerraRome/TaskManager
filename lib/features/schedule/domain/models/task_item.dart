import 'package:flutter/material.dart';

class TaskItem {
  final String id;
  final String title;
  final String? description;
  final String timeRange;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final List<String> members;
  final List<String> tags;

  const TaskItem({
    required this.id,
    required this.title,
    this.description,
    required this.timeRange,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.members = const [],
    this.tags = const [],
  });
}
