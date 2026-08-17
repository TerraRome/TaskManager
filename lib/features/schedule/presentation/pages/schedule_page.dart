import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../core/widgets/filter_bottom_sheet.dart';
import '../widgets/day_selector.dart';
import '../widgets/timeline_list.dart';
import '../widgets/schedule_bottom_nav.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  int _currentNavIndex = 1;
  bool _showMonthDropdown = false;
  bool _showToast = false;
  FilterResult _filterResult = FilterResult.empty();

  static final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/projects');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

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
    final taskState = ref.watch(taskProvider);
    final tasksForDay = taskState.tasksForDate(_selectedDate);

    // Apply FilterResult on top of provider results
    final filtered = tasksForDay.where((t) {
      if (_filterResult.status == 'done' && !t.isDone) return false;
      if (_filterResult.status == 'pending' && t.isDone) return false;
      if (_filterResult.color != null &&
          t.color.toARGB32() != _filterResult.color!.toARGB32()) {
        return false;
      }
      return true;
    }).toList();

    // Sort
    if (_filterResult.sortBy == 'title') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (_filterResult.sortBy == 'time') {
      filtered.sort((a, b) {
        if (a.startTime == null || b.startTime == null) return 0;
        return a.startTime!.compareTo(b.startTime!);
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                child: TimelineList(tasks: filtered),
              ),
            ],
          ),
          if (_showMonthDropdown) _buildMonthDropdownOverlay(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScheduleBottomNav(
              currentIndex: _currentNavIndex,
              onTap: _onNavTap,
            ),
          ),
          Positioned(
            right: 28,
            bottom: 104,
            child: _buildFab(),
          ),
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
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
            const Spacer(),
            Text('Schedule', style: AppTextStyles.heading2),
            const Spacer(),
            Row(
              children: [
                _IconBtn(
                  icon: Icons.search_rounded,
                  onTap: () => Navigator.pushNamed(context, '/search'),
                ),
                const SizedBox(width: 8),
                _IconBtn(
                  icon: Icons.tune_rounded,
                  onTap: () async {
                    final result = await FilterBottomSheet.show(
                      context,
                      config: FilterConfig.schedule(),
                      current: _filterResult,
                    );
                    if (result != null) setState(() => _filterResult = result);
                  },
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _IconBtn(
                      icon: Icons.notifications_none_rounded,
                      onTap: () => Navigator.pushNamed(context, '/messages'),
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
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).colorScheme.onSurface,
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
        child: Builder(builder: (context) {
          final cs = Theme.of(context).colorScheme;
          return Stack(
            children: [
              Positioned(
                top: 120,
                left: 20,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surface,
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
                                    : cs.onSurface,
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
          );
        }),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, '/new-task');
        _showTaskCreatedToast();
      },
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
    final iconBtnColor = Theme.of(context).colorScheme.surface;
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBtnColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
