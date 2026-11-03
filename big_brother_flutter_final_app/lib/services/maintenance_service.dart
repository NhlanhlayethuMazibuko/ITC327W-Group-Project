import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/core.dart';
import '../models/models.dart';
import 'student_service.dart';
import 'storage_service.dart';

class MaintenanceService {
  SupabaseClient get _db => Supabase.instance.client;
  static const bucket = 'maintenance-photos';

  Future<List<MaintenanceRequest>> list() async {
    final s = await StudentService().requireStudent();
    final rows = await _db.from(Db.maintenance).select().eq('student_id', s.id).order('created_at', ascending: false);
    return rows.map<MaintenanceRequest>((r) => MaintenanceRequest.fromMap(r)).toList();
  }

  Future<String> create({required String category, required String priority, required String type, required String description, UploadFile? photo}) async {
    final s = await StudentService().requireStudent();
    // Same as the web: only tenants report issues, and the room comes from their approved application.
    final roomId = await StudentService().tenantRoomId(s.id);
    if (roomId == null) {
      throw const UserMessage('Maintenance requests open once your application has been approved and you are a tenant.');
    }
    final photoPath = photo == null ? null : await StorageService().upload(bucket, 'requests', photo);
    final row = await _db.from(Db.maintenance).insert({
      'student_id': s.id,
      'room_id': roomId,
      'category': category,
      'priority': priority,
      'request_type': type,
      'description': description,
      'photo_path': photoPath,
      'status': 'submitted',
    }).select('reference_code').single();
    return (row['reference_code'] ?? '') as String;
  }

  Future<List<MaintenanceUpdate>> updates(String requestId) async {
    final rows = await _db.from(Db.maintenanceUpdate).select().eq('request_id', requestId).order('created_at');
    return rows.map<MaintenanceUpdate>((r) => MaintenanceUpdate.fromMap(r)).toList();
  }

  Future<String> photoUrl(String path) => StorageService().signedUrl(bucket, path);
}
