import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../schedule/domain/models/task_item.dart';

class TaskDetailPage extends ConsumerWidget {
  final TaskItem task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live task state so isDone reflects current value
    final taskState = ref.watch(taskProvider);
    final liveTask = taskState.tasks.firstWhere(
      (t) => t.id == task.id,
      orElse: () => task,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, ref)),
              SliverToBoxAdapter(child: _buildHeroCard()),
              SliverToBoxAdapter(child: _buildInfoSection(context)),
              SliverToBoxAdapter(child: _buildMembersSection(context)),
              SliverToBoxAdapter(child: _buildTagsSection(context)),
              SliverToBoxAdapter(child: _buildDescriptionSection(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 36,
            child: _buildActionButtons(context, ref, liveTask),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    size: 18, color: cs.onSurface),
              ),
            ),
            const Spacer(),
            Text('Task Detail', style: AppTextStyles.heading2),
            const Spacer(),
            GestureDetector(
              onTap: () => _showMoreMenu(context, ref),
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
                child: Icon(Icons.more_horiz_rounded,
                    size: 20, color: cs.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuTile(
              context: context,
              icon: Icons.edit_outlined,
              label: 'Edit Task',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/edit-task', arguments: task);
              },
            ),
            _buildMenuTile(
              context: context,
              icon: Icons.share_outlined,
              label: 'Share Task',
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuTile(
              context: context,
              icon: Icons.delete_outline_rounded,
              label: 'Delete Task',
              color: AppColors.taskRed,
              onTap: () {
                ref.read(taskProvider.notifier).deleteTask(task.id);
                Navigator.pop(context); // close modal
                Navigator.pop(context); // back to previous screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = color ?? cs.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: effectiveColor),
            const SizedBox(width: 16),
            Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: effectiveColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: task.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.tags.isNotEmpty ? task.tags.first : 'Task',
                style: AppTextStyles.label.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              task.title,
              style: AppTextStyles.heading1.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  task.timeRange,
                  style:
                      AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _buildCard(context,
        child: Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.play_circle_outline_rounded,
                label: 'Start',
                value: task.timeRange.split(' - ').first,
              ),
            ),
            Container(width: 1, height: 40, color: cs.onSurface.withValues(alpha: 0.1)),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.stop_circle_outlined,
                label: 'End',
                value: task.timeRange.split(' - ').last,
              ),
            ),
            Container(width: 1, height: 40, color: cs.onSurface.withValues(alpha: 0.1)),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.circle_rounded,
                label: 'Priority',
                value: 'High',
                iconColor: AppColors.taskRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    if (task.members.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _buildCard(context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assignees', style: AppTextStyles.captionMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: task.members
                  .map((name) => _buildMemberChip(name))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberChip(String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(name, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    if (task.tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _buildCard(context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tags', style: AppTextStyles.captionMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.primary),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    if (task.description == null || task.description!.isEmpty) {
      return const SizedBox.shrink();
    }
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _buildCard(context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description', style: AppTextStyles.captionMedium),
            const SizedBox(height: 10),
            Text(
              task.description!,
              style: AppTextStyles.body
                  .copyWith(color: cs.onSurface.withValues(alpha: 0.6), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, TaskItem liveTask) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              '/edit-task',
              arguments: liveTask,
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('Edit Task',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ref.read(taskProvider.notifier).toggleDone(liveTask.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: liveTask.isDone
                  ? AppColors.taskGreen
                  : AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              liveTask.isDone ? 'Completed ✓' : 'Mark Done',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
