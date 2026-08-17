import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../schedule/domain/models/task_item.dart';

class EditTaskPage extends ConsumerStatefulWidget {
  final TaskItem task;

  const EditTaskPage({super.key, required this.task});

  @override
  ConsumerState<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends ConsumerState<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  late String? _selectedProject;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Color _selectedColor;
  late List<String> _selectedAssignees;

  static const _projects = [
    'Fintech App Redesign',
    'Q4 Marketing Assets',
    'Design System v2.0',
  ];

  static const _allAssignees = ['Alice', 'Bob', 'Carol', 'Dave', 'Eve', 'Frank'];

  static const _colorOptions = [
    AppColors.taskBlue,
    AppColors.taskPurple,
    AppColors.taskGreen,
    AppColors.taskOrange,
    AppColors.taskRed,
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task.title);
    _descController = TextEditingController(text: task.description ?? '');
    _selectedColor = task.color;
    _selectedAssignees = List.from(task.members);
    _selectedProject = _projects.contains(task.tags.isNotEmpty ? task.tags.first : null)
        ? task.tags.first
        : null;

    // Pre-fill times from task
    if (task.startTime != null) {
      _startTime = TimeOfDay(
          hour: task.startTime!.hour, minute: task.startTime!.minute);
    } else {
      _startTime = const TimeOfDay(hour: 9, minute: 0);
    }
    if (task.endTime != null) {
      _endTime = TimeOfDay(
          hour: task.endTime!.hour, minute: task.endTime!.minute);
    } else {
      _endTime = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final start = DateTime(
          now.year, now.month, now.day, _startTime.hour, _startTime.minute);
      final end = DateTime(
          now.year, now.month, now.day, _endTime.hour, _endTime.minute);
      final startHour = _startTime.hour.toString().padLeft(2, '0');
      final startMin = _startTime.minute.toString().padLeft(2, '0');
      final endHour = _endTime.hour.toString().padLeft(2, '0');
      final endMin = _endTime.minute.toString().padLeft(2, '0');
      final timeRange = '$startHour:$startMin - $endHour:$endMin';

      final updated = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        color: _selectedColor,
        members: List.from(_selectedAssignees),
        startTime: start,
        endTime: end,
        timeRange: timeRange,
      );

      ref.read(taskProvider.notifier).updateTask(updated);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Task Title'),
                      _buildTitleField(),
                      const SizedBox(height: 20),
                      _buildSection('Project'),
                      _buildProjectSelector(),
                      const SizedBox(height: 20),
                      _buildSection('Time'),
                      _buildTimeRow(),
                      const SizedBox(height: 20),
                      _buildSection('Color'),
                      _buildColorPicker(),
                      const SizedBox(height: 20),
                      _buildSection('Assignees'),
                      _buildAssignees(),
                      const SizedBox(height: 20),
                      _buildSection('Description'),
                      _buildDescField(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
                  size: 16, color: cs.onSurface),
            ),
          ),
          const Spacer(),
          Text('Edit Task', style: AppTextStyles.heading2),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: AppTextStyles.label),
    );
  }

  Widget _buildTitleField() {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: _titleController,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Enter task title...',
        hintStyle: AppTextStyles.body.copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Title is required' : null,
    );
  }

  Widget _buildProjectSelector() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedProject,
        hint: Text('Select project',
            style: AppTextStyles.body
                .copyWith(color: cs.onSurface.withValues(alpha: 0.4))),
        style: AppTextStyles.body.copyWith(color: cs.onSurface),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: _projects
            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
            .toList(),
        onChanged: (v) => setState(() => _selectedProject = v),
        dropdownColor: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Expanded(child: _buildTimePicker(label: 'Start', isStart: true)),
        const SizedBox(width: 12),
        Expanded(child: _buildTimePicker(label: 'End', isStart: false)),
      ],
    );
  }

  Widget _buildTimePicker({required String label, required bool isStart}) {
    final cs = Theme.of(context).colorScheme;
    final time = isStart ? _startTime : _endTime;
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: () => _pickTime(isStart: isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded,
                size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text('$hour:$min', style: AppTextStyles.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: _colorOptions.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            width: isSelected ? 36 : 30,
            height: isSelected ? 36 : 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssignees() {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allAssignees.map((name) {
        final isSelected = _selectedAssignees.contains(name);
        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              _selectedAssignees.remove(name);
            } else {
              _selectedAssignees.add(name);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : cs.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              name,
              style: AppTextStyles.captionMedium.copyWith(
                color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescField() {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: _descController,
      style: AppTextStyles.body,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Add a description...',
        hintStyle: AppTextStyles.body.copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Save Changes',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
