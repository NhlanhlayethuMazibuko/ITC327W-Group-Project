import 'package:flutter/material.dart';
import 'state.dart';
import 'ui.dart';
import 'viewings.dart';

DateTime _dt(M n) => DateTime.tryParse('${n['created_at']}')?.toLocal() ?? DateTime.now();
bool _today(DateTime d) { final n = DateTime.now(); return d.year == n.year && d.month == n.month && d.day == n.day; }
String _when(DateTime d) {
  if (!_today(d)) return fmtDMY(d);
  final m = DateTime.now().difference(d).inMinutes;
  if (m < 60) return '${m <= 0 ? 1 : m}m ago';
  return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotifState();
}

class _NotifState extends State<NotificationsScreen> {
  bool unreadOnly = false;
  Widget _chip(String t, bool sel, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: sel ? kPeach : const Color(0xFFFFF1DF), borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
          child: Text(t, style: const TextStyle(color: kOrange, fontWeight: FontWeight.w800, fontSize: 18)),
        ),
      );

  Widget _tile(M n, {required bool today}) {
    final unread = n['is_read'] != true;
    final fg = today && unread ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: () {
        app.markRead(id: '${n['notification_id']}');
        Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationDetailScreen(n: n)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(color: today && unread ? kOrangeTop : kPeach, borderRadius: BorderRadius.circular(22), boxShadow: today && unread ? cardShadow : null),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${n['title']}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: fg)),
            const SizedBox(height: 4),
            Text('${n['message']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: fg)),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (today && unread) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), decoration: BoxDecoration(color: kPeach, borderRadius: BorderRadius.circular(12)), child: const Text('New', style: TextStyle(color: kOrange, fontWeight: FontWeight.bold))),
            const SizedBox(height: 6),
            Text(_when(_dt(n)), style: TextStyle(fontWeight: FontWeight.w700, color: today && unread ? Colors.white : Colors.black87)),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final all = app.notifs.where((n) => !unreadOnly || n['is_read'] != true).toList();
          final unreadCount = app.notifs.where((n) => n['is_read'] != true).length;
          final today = all.where((n) => _today(_dt(n))).toList();
          final earlier = all.where((n) => !_today(_dt(n))).toList();
          return PageShell(
            navIndex: 0,
            child: app.notifs.isEmpty
                ? ListView(children: [
                    const Center(child: Text('Notifications', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
                    const SizedBox(height: 90),
                    const Icon(Icons.notifications_none, size: 56, color: Colors.grey),
                    const SizedBox(height: 14),
                    const Center(child: Text('No new notifications yet', style: TextStyle(fontSize: 18, color: Colors.grey))),
                  ])
                : ListView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 20), children: [
                    const Center(child: Text('Notifications', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
                    const SizedBox(height: 18),
                    Row(children: [
                      _chip('All', !unreadOnly, () => setState(() => unreadOnly = false)),
                      _chip('Unread ($unreadCount)', unreadOnly, () => setState(() => unreadOnly = true)),
                      const Spacer(),
                      GestureDetector(onTap: () => app.markRead(), child: const Text('Mark All as Read', style: TextStyle(color: kOrange, fontWeight: FontWeight.w800, fontSize: 17))),
                    ]),
                    const SizedBox(height: 22),
                    if (today.isNotEmpty) ...[const Text('Today', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 12), for (final n in today) _tile(n, today: true)],
                    if (earlier.isNotEmpty) ...[const SizedBox(height: 8), const Text('Eariler', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 12), for (final n in earlier) _tile(n, today: false)],
                  ]),
          );
        },
      );
}

class NotificationDetailScreen extends StatelessWidget {
  final M n;
  const NotificationDetailScreen({super.key, required this.n});
  @override
  Widget build(BuildContext context) {
    final isViewing = '${n['title']}'.toLowerCase().contains('viewing');
    return PageShell(
      navIndex: 0,
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 20), children: [
        const Center(child: Text('Notifications', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: kPeach, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)), border: Border.all(color: const Color(0xFFE8D2B8))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text('${n['title']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))), Text(_when(_dt(n)), style: const TextStyle(fontSize: 13))]),
            const SizedBox(height: 14),
            Text('${n['message']}', style: const TextStyle(fontSize: 19)),
          ]),
        ),
        const SizedBox(height: 120),
        if (isViewing) Center(child: SizedBox(width: 280, child: OBtn('Go to Viewings', dark: true, icon: Icons.arrow_forward, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ViewingsScreen()))))),
      ]),
    );
  }
}
