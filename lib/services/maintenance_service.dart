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
    final photoPath = photo == null ? null : await StorageService().upload(bucket, 'requests', photo);
    final row = await _db.from(Db.maintenance).insert({
      'student_id': s.id,
      'category': category,
      'priority': priority,
      'request_type': type,
      'description': description,
      'photo_path': photoPath,
      'status': 'Pending',
    }).select('reference_code').single();
    return (row['reference_code'] ?? '') as String;
  }

  Future<String> photoUrl(String path) => StorageService().signedUrl(bucket, path);
}
