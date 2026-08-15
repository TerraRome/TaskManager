import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/task_form_data.dart';

class NewTaskPage extends StatefulWidget {
  final VoidCallback? onTaskCreated;

  const NewTaskPage({super.key, this.onTaskCreated});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedProject;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 15);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 45);
  Color _selectedColor = AppColors.taskBlue;
  final List<String> _selectedAssignees = [];

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
      widget.onTaskCreated?.call();
      Navigator.pop(context, TaskFormData(
        title: _titleController.text.trim(),
        project: _selectedProject,
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        assignees: List.from(_selectedAssignees),
        description: _descController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(children: [
                      _buildLabel('Task Name'),
                      _buildTextField(
                        controller: _titleController,
                        hint: 'e.g. Mobile App Usability Testing',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Task name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Project'),
                      _buildProjectPicker(),
                    ]),
                    const SizedBox(height: 16),
                    _buildCard(children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Start Time'),
                                _buildTimeTile(
                                  time: _startTime,
                                  onTap: () => _pickTime(isStart: true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('End Time'),
                                _buildTimeTile(
                                  time: _endTime,
                                  onTap: () => _pickTime(isStart: false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildCard(children: [
                      _buildLabel('Color Accent'),
                      const SizedBox(height: 12),
                      _buildColorPicker(),
                    ]),
                    const SizedBox(height: 16),
                    _buildCard(children: [
                      _buildLabel('Assignees'),
                      const SizedBox(height: 12),
                      _buildAssigneePicker(),
                    ]),
                    const SizedBox(height: 16),
                    _buildCard(children: [
                      _buildLabel('Description'),
                      _buildTextField(
                        controller: _descController,
                        hint: 'Add task details...',
                        maxLines: 4,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppColors.textPrimary),
              ),
            ),
            const Spacer(),
            Text('New Task', style: AppTextStyles.heading2),
            const Spacer(),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.captionMedium),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildProjectPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProject,
          hint: Text('Select project',
              style: AppTextStyles.body.copyWith(color: AppColors.textLight)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          style: AppTextStyles.body,
          items: _projects
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) => setState(() => _selectedProject = v),
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(time.format(context), style: AppTextStyles.bodyMedium),
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
            margin: const EdgeInsets.only(right: 12),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: color, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssigneePicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allAssignees.map((name) {
        final isSelected = _selectedAssignees.contains(name);
        return GestureDetector(
          onTap: () => setState(() {
            isSelected
                ? _selectedAssignees.remove(name)
                : _selectedAssignees.add(name);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              name,
              style: AppTextStyles.captionMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
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
        child: Text('Create Task', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
      ),
    );
  }
}
