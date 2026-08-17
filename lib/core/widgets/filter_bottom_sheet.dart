import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Generic filter/sort bottom sheet.
///
/// Usage:
/// ```dart
/// final result = await FilterBottomSheet.show(
///   context,
///   config: FilterConfig(
///     sortOptions: ['Deadline', 'Name', 'Progress'],
///     colorOptions: [AppColors.taskBlue, ...],
///     showStatusFilter: true,
///   ),
///   current: _currentFilter,
/// );
/// if (result != null) setState(() => _currentFilter = result);
/// ```
class FilterBottomSheet extends StatefulWidget {
  final FilterConfig config;
  final FilterResult current;

  const FilterBottomSheet({
    super.key,
    required this.config,
    required this.current,
  });

  static Future<FilterResult?> show(
    BuildContext context, {
    required FilterConfig config,
    required FilterResult current,
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(config: config, current: current),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterResult _result;

  @override
  void initState() {
    super.initState();
    _result = widget.current.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(cs),
          _buildTitle(cs),
          if (widget.config.sortOptions.isNotEmpty) ...[
            _buildSectionLabel('Sort By', cs),
            _buildSortOptions(cs),
          ],
          if (widget.config.showStatusFilter) ...[
            _buildSectionLabel('Status', cs),
            _buildStatusOptions(cs),
          ],
          if (widget.config.colorOptions.isNotEmpty) ...[
            _buildSectionLabel('Color', cs),
            _buildColorOptions(cs),
          ],
          if (widget.config.priorityOptions.isNotEmpty) ...[
            _buildSectionLabel('Priority', cs),
            _buildPriorityOptions(cs),
          ],
          const SizedBox(height: 16),
          _buildActions(cs),
        ],
      ),
    );
  }

  Widget _buildHandle(ColorScheme cs) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Text('Filter & Sort', style: AppTextStyles.heading2),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() => _result = FilterResult.empty());
            },
            child: Text(
              'Reset',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label,
        style: AppTextStyles.label
            .copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildSortOptions(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.config.sortOptions.map((opt) {
          final isSelected = _result.sortBy == opt;
          return GestureDetector(
            onTap: () => setState(() => _result = _result.copyWith(sortBy: opt)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : cs.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : cs.onSurface.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                opt,
                style: AppTextStyles.captionMedium.copyWith(
                  color: isSelected ? Colors.white : cs.onSurface,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusOptions(ColorScheme cs) {
    const statuses = ['All', 'Active', 'Completed', 'Overdue'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: statuses.map((s) {
          final isSelected = _result.status == s;
          return GestureDetector(
            onTap: () =>
                setState(() => _result = _result.copyWith(status: s)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : cs.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : cs.onSurface.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                s,
                style: AppTextStyles.captionMedium.copyWith(
                  color: isSelected ? Colors.white : cs.onSurface,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorOptions(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        children: widget.config.colorOptions.map((color) {
          final isSelected = _result.color == color;
          return GestureDetector(
            onTap: () =>
                setState(() => _result = _result.copyWith(color: color)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? cs.onSurface : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriorityOptions(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.config.priorityOptions.map((p) {
          final isSelected = _result.priority == p;
          return GestureDetector(
            onTap: () =>
                setState(() => _result = _result.copyWith(priority: p)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : cs.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : cs.onSurface.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                p,
                style: AppTextStyles.captionMedium.copyWith(
                  color: isSelected ? Colors.white : cs.onSurface,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActions(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                    color: cs.onSurface.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Cancel',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: cs.onSurface)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _result),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Apply',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Configuration for what options to show in the filter sheet.
class FilterConfig {
  final List<String> sortOptions;
  final List<Color> colorOptions;
  final List<String> priorityOptions;
  final bool showStatusFilter;

  const FilterConfig({
    this.sortOptions = const [],
    this.colorOptions = const [],
    this.priorityOptions = const [],
    this.showStatusFilter = false,
  });

  /// Preset for Schedule page
  factory FilterConfig.schedule() => FilterConfig(
        sortOptions: const ['Time', 'Name', 'Color'],
        colorOptions: const [
          AppColors.taskBlue,
          AppColors.taskPurple,
          AppColors.taskGreen,
          AppColors.taskOrange,
          AppColors.taskRed,
        ],
        priorityOptions: const ['High', 'Medium', 'Low'],
        showStatusFilter: true,
      );

  /// Preset for Projects page
  factory FilterConfig.projects() => FilterConfig(
        sortOptions: const ['Deadline', 'Name', 'Progress'],
        colorOptions: const [
          AppColors.taskBlue,
          AppColors.taskPurple,
          AppColors.taskGreen,
          AppColors.taskOrange,
          AppColors.taskRed,
        ],
        showStatusFilter: true,
      );
}

/// Current filter state returned by the bottom sheet.
class FilterResult {
  final String? sortBy;
  final String? status;
  final Color? color;
  final String? priority;

  const FilterResult({
    this.sortBy,
    this.status,
    this.color,
    this.priority,
  });

  factory FilterResult.empty() => const FilterResult();

  bool get isEmpty =>
      sortBy == null && status == null && color == null && priority == null;

  int get activeCount => [sortBy, status, color, priority]
      .where((e) => e != null)
      .length;

  FilterResult copyWith({
    String? sortBy,
    String? status,
    Color? color,
    String? priority,
  }) {
    return FilterResult(
      sortBy: sortBy ?? this.sortBy,
      status: status ?? this.status,
      color: color ?? this.color,
      priority: priority ?? this.priority,
    );
  }
}
