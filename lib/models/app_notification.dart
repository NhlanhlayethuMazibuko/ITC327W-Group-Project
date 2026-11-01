import '../core/utils/format.dart';

class AppNotification {
  const AppNotification({required this.id, required this.title, required this.message, this.createdAt, this.isRead = true, this.isAnnouncement = false});
  final String id, title, message;
  final DateTime? createdAt;
  final bool isRead, isAnnouncement;

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
        id: m['notification_id'] as String,
        title: (m['title'] ?? '') as String,
        message: (m['message'] ?? '') as String,
        createdAt: parseDate(m['created_at']),
        isRead: m['is_read'] == true,
      );

  factory AppNotification.fromAnnouncement(Map<String, dynamic> m) => AppNotification(
        id: m['announcement_id'] as String,
        title: (m['title'] ?? '') as String,
        message: (m['message'] ?? '') as String,
        createdAt: parseDate(m['created_at']),
        isAnnouncement: true,
      );
}
