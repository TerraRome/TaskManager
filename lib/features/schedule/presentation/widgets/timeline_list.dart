import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/task_item.dart';
import 'task_card.dart';

class TimelineList extends StatelessWidget {
  final List<TaskItem> tasks;

  const TimelineList({super.key, required this.tasks});

  static const List<int> _hours = [
    7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      itemCount: _hours.length,
      itemBuilder: (context, index) {
        final hour = _hours[index];
        final hourTasks = tasks
            .where((t) => t.startTime.hour == hour)
            .toList();

        return _TimelineRow(hour: hour, tasks: hourTasks);
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final int hour;
  final List<TaskItem> tasks;

  const _TimelineRow({required this.hour, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _formatHour(hour),
                style: AppTextStyles.timeLabel,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Timeline line + dot
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: tasks.isNotEmpty
                      ? AppColors.timelineDot
                      : AppColors.timelineLine,
                  shape: BoxShape.circle,
                  border: tasks.isNotEmpty
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppColors.timelineLine,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Task cards or empty space
          Expanded(
            child: tasks.isEmpty
                ? const SizedBox(height: 56)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: tasks
                          .map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: TaskCard(task: t),
                              ))
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    final suffix = hour < 12 ? 'AM' : 'PM';
    final h = hour > 12 ? hour - 12 : hour;
    return '$h $suffix';
  }
}
