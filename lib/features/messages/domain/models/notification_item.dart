class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime time;
  final bool isRead;
  final String? avatarInitial;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.isRead = false,
    this.avatarInitial,
  });
}

enum NotificationType { task, mention, project, reminder, system }
