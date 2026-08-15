import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/task_item.dart';
import '../widgets/day_selector.dart';
import '../widgets/timeline_list.dart';
import '../widgets/schedule_bottom_nav.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  int _currentNavIndex = 1;
  bool _showMonthDropdown = false;
  bool _showToast = false;

  static final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  // Sample tasks
  List<TaskItem> get _tasksForSelectedDay => [
    TaskItem(
      id: '1',
      title: 'UI Design Review',
      description: 'Review the latest mockups and provide feedback to the design team.',
      timeRange: '09:00 - 10:30 AM',
      startTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 9),
      endTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 10, 30),
      color: AppColors.taskBlue,
      members: ['Alice', 'Bob', 'Carol'],
      tags: ['Design', 'UI/UX'],
    ),
    TaskItem(
      id: '2',
      title: 'Sprint Planning',
      description: 'Plan tasks and story points for the upcoming sprint.',
      timeRange: '11:00 - 12:00 PM',
      startTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 11),
      endTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 12),
      color: AppColors.taskPurple,
      members: ['Dave', 'Eve'],
      tags: ['Agile', 'Planning'],
    ),
    TaskItem(
      id: '3',
      title: 'Backend API Integration',
      description: 'Connect the new endpoints to the mobile client.',
      timeRange: '13:00 - 15:00 PM',
      startTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 13),
      endTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 15),
      color: AppColors.taskGreen,
      members: ['Frank'],
      tags: ['Backend', 'API'],
    ),
    TaskItem(
      id: '4',
      title: 'Team Standup',
      description: 'Daily sync with the entire product team.',
      timeRange: '16:00 - 16:30 PM',
      startTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 16),
      endTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 16, 30),
      color: AppColors.taskOrange,
      members: ['Alice', 'Bob'],
      tags: ['Meeting'],
    ),
  ];

  void _onDaySelected(DateTime date) {
    setState(() => _selectedDate = date);
  }

  void _toggleMonthDropdown() {
    setState(() => _showMonthDropdown = !_showMonthDropdown);
  }

  void _selectMonth(int monthIndex) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, monthIndex + 1);
      _selectedDate = DateTime(_currentMonth.year, monthIndex + 1, 1);
      _showMonthDropdown = false;
    });
  }

  void _showTaskCreatedToast() {
    setState(() => _showToast = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  String get _monthYearLabel =>
      '${_months[_currentMonth.month - 1]} ${_currentMonth.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              _buildMonthSelector(),
              const SizedBox(height: 8),
              _buildDaySelector(),
              const SizedBox(height: 8),
              Expanded(
                child: TimelineList(tasks: _tasksForSelectedDay),
              ),
            ],
          ),
          // Month dropdown overlay
          if (_showMonthDropdown) _buildMonthDropdownOverlay(),
          // Floating bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScheduleBottomNav(
              currentIndex: _currentNavIndex,
              onTap: (i) => setState(() => _currentNavIndex = i),
            ),
          ),
          // FAB
          Positioned(
            right: 28,
            bottom: 80,
            child: _buildFab(),
          ),
          // Toast
          if (_showToast)
            Positioned(
              left: 20,
              right: 20,
              bottom: 100,
              child: _buildToast(),
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
            _IconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {},
            ),
            const Spacer(),
            Text('Schedule', style: AppTextStyles.heading2),
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _IconBtn(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {},
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.badge,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _toggleMonthDropdown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_monthYearLabel, style: AppTextStyles.heading3),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: _showMonthDropdown ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return DaySelector(
      selectedDate: _selectedDate,
      currentMonth: _currentMonth,
      onDaySelected: _onDaySelected,
    );
  }

  Widget _buildMonthDropdownOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showMonthDropdown = false),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              top: 120,
              left: 20,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surface,
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_months.length, (i) {
                      final isSelected = i + 1 == _currentMonth.month;
                      return GestureDetector(
                        onTap: () => _selectMonth(i),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_months[i]} ${_currentMonth.year}',
                            style: AppTextStyles.body.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: _showTaskCreatedToast,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildToast() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.toastBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.taskGreen, size: 20),
          const SizedBox(width: 10),
          Text(
            'Task created successfully!',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
