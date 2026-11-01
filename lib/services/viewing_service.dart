import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/core.dart';
import '../models/models.dart';
import 'student_service.dart';

class ViewingService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Viewing>> list() async {
    final s = await StudentService().requireStudent();
    final rows = await _db.from(Db.booking).select().eq('student_id', s.id).order('booking_date', ascending: false);
    return rows.map<Viewing>((r) => Viewing.fromMap(r)).toList();
  }

  Future<String> create(ViewingDraft d) async {
    final s = await StudentService().requireStudent();
    final row = await _db.from(Db.booking).insert({
      'student_id': s.id,
      'booking_date': isoDate(d.date),
      'preferred_time': d.preferred,
      'alternative_time': d.alternative,
      'gender': d.gender,
      'room_type': d.roomType,
      'booking_status': 'Pending',
    }).select('reference_code').single();
    return (row['reference_code'] ?? '') as String;
  }
}
