import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _unreadOnly = false;
  String _studentId = '';

  Future<List<AppNotification>> _load() async {
    final s = await StudentService().requireStudent();
    _studentId = s.id;
    return NotificationService().fetchAll(s.id);
  }

  bool _isToday(DateTime? d) {
    final n = DateTime.now();
    return d != null && d.year == n.year && d.month == n.month && d.day == n.day;
  }

  Widget _tile(AppNotification n, Future<void> Function() reload) {
    final unread = !n.isRead && !n.isAnnouncement;
    final when = n.createdAt == null ? '' : (_isToday(n.createdAt) ? '${two(n.createdAt!.hour)}:${two(n.createdAt!.minute)}' : fmtDate(n.createdAt!));
    return GestureDetector(
      onTap: () async {
        if (unread) {
          try { await NotificationService().markRead(n.id); } catch (_) {}
        }
        if (!mounted) return;
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationDetailScreen(notification: n)));
        await reload();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: unread ? AppColors.orange : const Color(0xFFFFF0D5), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(n.isAnnouncement ? Icons.campaign_outlined : Icons.notifications_none, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            Text(n.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
          ])),
          Text(when, style: const TextStyle(fontSize: 9)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Notifications',
      child: LoadView<List<AppNotification>>(
        loader: _load,
        builder: (context, list, reload) {
          if (list.isEmpty) return const EmptyState(icon: Icons.notifications_none, message: 'No new notifications yet');
          final unreadCount = list.where((n) => !n.isRead && !n.isAnnouncement).length;
          final shown = _unreadOnly ? list.where((n) => !n.isRead && !n.isAnnouncement).toList() : list;
          final today = shown.where((n) => _isToday(n.createdAt)).toList();
          final earlier = shown.where((n) => !_isToday(n.createdAt)).toList();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              ChoiceChip(label: const Text('All', style: TextStyle(fontSize: 11)), selected: !_unreadOnly, onSelected: (_) => setState(() => _unreadOnly = false)),
              const SizedBox(width: 8),
              ChoiceChip(label: Text('Unread ($unreadCount)', style: const TextStyle(fontSize: 11)), selected: _unreadOnly, onSelected: (_) => setState(() => _unreadOnly = true)),
              const Spacer(),
              TextButton(
                onPressed: unreadCount == 0 ? null : () async { await NotificationService().markAllRead(_studentId); await reload(); },
                child: const Text('Mark All as Read', style: TextStyle(fontSize: 11, color: AppColors.orange)),
              ),
            ]),
            if (shown.isEmpty) const EmptyState(icon: Icons.done_all, message: 'You are all caught up.'),
            if (today.isNotEmpty) ...[const Text('Today', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), const SizedBox(height: 6), for (final n in today) _tile(n, reload)],
            if (earlier.isNotEmpty) ...[const SizedBox(height: 8), const Text('Earlier', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), const SizedBox(height: 6), for (final n in earlier) _tile(n, reload)],
          ]);
        },
      ),
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key, required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return AuthScaffold(
      title: 'Notifications',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFFFF0D5), borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          if (n.createdAt != null) Text(fmtDateTime(n.createdAt!), style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          const SizedBox(height: 10),
          Text(n.message, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }
}
