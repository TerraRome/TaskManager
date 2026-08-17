import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/notification_item.dart';
import '../widgets/notification_tile.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../schedule/presentation/widgets/schedule_bottom_nav.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  int _currentNavIndex = 3;
  int _selectedFilter = 0;

  static const _filters = ['All', 'Unread', 'Tasks', 'Projects'];

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Alice assigned you a task',
      body: '"Review login screen mockup" is due tomorrow at 5 PM.',
      type: NotificationType.task,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      avatarInitial: 'A',
    ),
    NotificationItem(
      id: '2',
      title: 'Bob mentioned you',
      body: '@you Can you check the color palette I updated in Figma?',
      type: NotificationType.mention,
      time: DateTime.now().subtract(const Duration(minutes: 32)),
      isRead: false,
      avatarInitial: 'B',
    ),
    NotificationItem(
      id: '3',
      title: 'Fintech App Redesign updated',
      body: 'Project deadline moved to Sep 20. 3 new tasks added.',
      type: NotificationType.project,
      time: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Reminder: Daily standup',
      body: 'Your daily standup meeting starts in 15 minutes.',
      type: NotificationType.reminder,
      time: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Carol completed a task',
      body: '"Onboarding flow wireframes" marked as done.',
      type: NotificationType.task,
      time: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      avatarInitial: 'C',
    ),
    NotificationItem(
      id: '6',
      title: 'Design System v2.0 completed',
      body: 'All 36 tasks have been completed. Great work team!',
      type: NotificationType.project,
      time: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
    NotificationItem(
      id: '7',
      title: 'Dave mentioned you',
      body: '@you The user research report is ready for your review.',
      type: NotificationType.mention,
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      avatarInitial: 'D',
    ),
    NotificationItem(
      id: '8',
      title: 'System maintenance',
      body: 'Scheduled maintenance on Aug 17, 2–4 AM. App may be unavailable.',
      type: NotificationType.system,
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  List<NotificationItem> get _filtered {
    switch (_selectedFilter) {
      case 1:
        return _notifications.where((n) => !n.isRead).toList();
      case 2:
        return _notifications
            .where((n) => n.type == NotificationType.task)
            .toList();
      case 3:
        return _notifications
            .where((n) => n.type == NotificationType.project)
            .toList();
      default:
        return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = NotificationItem(
          id: _notifications[i].id,
          title: _notifications[i].title,
          body: _notifications[i].body,
          type: _notifications[i].type,
          time: _notifications[i].time,
          isRead: true,
          avatarInitial: _notifications[i].avatarInitial,
        );
      }
    });
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/schedule');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/projects');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildFilterRow()),
              filtered.isEmpty
                  ? SliverFillRemaining(child: _buildEmpty())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = filtered[index];
                          // Date separator
                          final showSeparator = index == 0 ||
                              !_isSameDay(
                                  filtered[index - 1].time, item.time);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showSeparator)
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      20,
                                      index == 0 ? 4 : 16,
                                      20,
                                      8),
                                  child: Text(
                                    _sectionLabel(item.time),
                                    style: AppTextStyles.label.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              NotificationTile(
                                item: item,
                                onTap: () => setState(() {}),
                              ),
                              if (index == filtered.length - 1)
                                const SizedBox(height: 120),
                            ],
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScheduleBottomNav(
              currentIndex: _currentNavIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            const Spacer(),
            Text('Notifications', style: AppTextStyles.heading2),
            const Spacer(),
            if (_unreadCount > 0)
              GestureDetector(
                onTap: _markAllRead,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$_unreadCount unread',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (i) {
            final isSelected = i == _selectedFilter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  _filters[i],
                  style: AppTextStyles.captionMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return EmptyState.noMessages();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _sectionLabel(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }
}
