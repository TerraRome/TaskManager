import 'package:flutter/material.dart';

class TaskFormData {
  final String title;
  final String? project;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;
  final List<String> assignees;
  final String description;

  const TaskFormData({
    required this.title,
    this.project,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.assignees,
    required this.description,
  });
}
