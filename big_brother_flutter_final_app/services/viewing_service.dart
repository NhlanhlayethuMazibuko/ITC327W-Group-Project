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
    if (await StudentService().tenantRoomId(s.id) != null) {
      throw const UserMessage("You're already a tenant, so you can't book a viewing. Contact management if you plan to move out.");
    }
    final row = await _db.from(Db.booking).insert({
      'student_id': s.id,
      'room_id': await _roomFor(d.roomType),
      'booking_date': isoDate(d.date),
      'preferred_time': d.preferred,
      'alternative_time': d.alternative,
      'room_type': d.roomType,
      'gender': d.gender,
      'message': viewingMessage(d.roomType, d.gender),
      'booking_status': 'Pending',
    }).select('reference_code').single();
    return (row['reference_code'] ?? '') as String;
  }

  /// Room types the website uses for each choice on the viewing form.
  static const _typesFor = {
    'Singles': ['single room'],
    'Sharing': ['sharing room', '2-bedroom apartment'],
    'Bachelors': ['1-bedroom apartment', 'studio apartment'],
  };

  /// Picks an available room of the chosen kind so the web admin can show which
  /// room the viewing is for. Null when none matches.
  Future<String?> _roomFor(String roomType) async {
    final wanted = _typesFor[roomType] ?? [roomType.toLowerCase()];
    final rooms = await _db.from(Db.room).select('room_id, room_type').eq('availability_status', true).eq('is_listed', true).order('room_name');
    for (final r in rooms) {
      if (wanted.contains((r['room_type'] ?? '').toString().toLowerCase())) return r['room_id'] as String;
    }
    return null;
  }
}
