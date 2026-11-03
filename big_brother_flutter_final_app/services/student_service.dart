import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/core.dart';
import '../models/models.dart';

class StudentService {
  SupabaseClient get _db => Supabase.instance.client;

  /// Throws if the student row is missing. The id always comes from the signed-in user.
  Future<Student> requireStudent() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw const UserMessage('Your session has expired. Please log in again.');
    final row = await _db.from(Db.student).select().eq('user_id', uid).maybeSingle();
    if (row == null) {
      throw const UserMessage('Your student profile was not found. Please contact support.');
    }
    return Student.fromMap(row);
  }

  /// Used by Home, where a missing profile should not block the screen.
  Future<Student?> currentStudent() async {
    try {
      return await requireStudent();
    } catch (e) {
      debugPrint('StudentService.currentStudent failed: ${e.runtimeType}');
      return null;
    }
  }

  /// The room from the student's approved application, or null when they are not a tenant.
  Future<String?> tenantRoomId(String studentId) async {
    final rows = await _db
        .from(Db.application)
        .select('room_id')
        .eq('student_id', studentId)
        .eq('status_id', kStatusApproved)
        .order('created_at', ascending: false)
        .limit(1);
    return rows.isEmpty ? null : rows.first['room_id'] as String?;
  }

  /// Tenants are students whose application has been approved.
  Future<bool> isTenant() async {
    final s = await currentStudent();
    if (s == null) return false;
    try {
      return await tenantRoomId(s.id) != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> update(Map<String, dynamic> values) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw const UserMessage('Your session has expired. Please log in again.');
    await _db.from(Db.student).update(values).eq('user_id', uid);
  }
}
