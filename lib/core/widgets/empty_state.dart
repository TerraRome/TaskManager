import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  /// Preset: no tasks found
  factory EmptyState.noTasks({VoidCallback? onAction}) => EmptyState(
        icon: Icons.task_alt_rounded,
        title: 'No Tasks Found',
        description: 'You have no tasks here yet.\nTap the + button to create one.',
        iconColor: AppColors.taskBlue,
        actionLabel: onAction != null ? 'Create Task' : null,
        onAction: onAction,
      );

  /// Preset: no projects found
  factory EmptyState.noProjects({VoidCallback? onAction}) => EmptyState(
        icon: Icons.folder_outlined,
        title: 'No Projects Found',
        description: 'You have no projects yet.\nStart by creating a new project.',
        iconColor: AppColors.taskPurple,
        actionLabel: onAction != null ? 'Create Project' : null,
        onAction: onAction,
      );

  /// Preset: no search results
  factory EmptyState.noResults({String query = ''}) => EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Results',
        description: query.isNotEmpty
            ? 'No results found for "$query".\nTry a different keyword.'
            : 'No results found.\nTry a different keyword.',
        iconColor: AppColors.textSecondary,
      );

  /// Preset: no messages
  factory EmptyState.noMessages() => const EmptyState(
        icon: Icons.mark_chat_read_outlined,
        title: 'All Caught Up',
        description: 'You have no notifications.\nWe\'ll let you know when something arrives.',
        iconColor: AppColors.taskGreen,
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = iconColor ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: color.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.body.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
