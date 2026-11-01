import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/core.dart';
import '../models/models.dart';

class NotificationService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<AppNotification?> latest(String studentId) async {
    try {
      final rows = await _db.from(Db.notifications).select().eq('student_id', studentId).order('created_at', ascending: false).limit(1);
      return rows.isEmpty ? null : AppNotification.fromMap(rows.first);
    } catch (e) {
      debugPrint('NotificationService.latest failed: ${e.runtimeType}');
      return null;
    }
  }

  Future<List<AppNotification>> fetchAll(String studentId) async {
    final rows = await _db.from(Db.notifications).select().eq('student_id', studentId).order('created_at', ascending: false);
    final list = rows.map<AppNotification>((r) => AppNotification.fromMap(r)).toList();
    try {
      final a = await _db.from(Db.announcements).select().order('created_at', ascending: false).limit(10);
      list.addAll(a.map<AppNotification>((r) => AppNotification.fromAnnouncement(r)));
    } catch (e) {
      debugPrint('Announcements unavailable: ${e.runtimeType}');
    }
    list.sort((x, y) => (y.createdAt ?? DateTime(2000)).compareTo(x.createdAt ?? DateTime(2000)));
    return list;
  }

  Future<void> markRead(String id) => _db.from(Db.notifications).update({'is_read': true}).eq('notification_id', id);

  Future<void> markAllRead(String studentId) =>
      _db.from(Db.notifications).update({'is_read': true}).eq('student_id', studentId).eq('is_read', false);
}
