import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/core.dart';
import '../models/models.dart';
import 'student_service.dart';
import 'storage_service.dart';

class ApplicationService {
  SupabaseClient get _db => Supabase.instance.client;
  static const bucket = 'documents';

  Future<Application?> latest() async {
    final s = await StudentService().requireStudent();
    final rows = await _db
        .from(Db.application)
        .select('*, ${Db.applicationStatus}(status_name), ${Db.room}(room_name)')
        .eq('student_id', s.id)
        .order('application_date', ascending: false)
        .limit(1);
    return rows.isEmpty ? null : Application.fromMap(rows.first);
  }

  Future<List<DocumentItem>> documents(String applicationId) async {
    final rows = await _db.from(Db.document).select('document_type, file_path').eq('application_id', applicationId);
    return rows.map<DocumentItem>((r) => DocumentItem(type: (r['document_type'] ?? '') as String, path: (r['file_path'] ?? '') as String)).toList();
  }

  Future<void> uploadDocument(String applicationId, String type, UploadFile file) async {
    final path = await StorageService().upload(bucket, applicationId, file);
    await _db.from(Db.document).insert({'application_id': applicationId, 'document_type': type, 'file_path': path});
  }

  /// Saves the form answers, creates the application, then uploads any chosen documents.
  /// A failed upload does not lose the application: it is listed so the student can retry.
  Future<({String number, List<String> failed})> submit({
    required String roomId,
    required Map<String, dynamic> studentValues,
    required Map<String, UploadFile?> files,
  }) async {
    final student = await StudentService().requireStudent();
    await StudentService().update(studentValues);
    final status = await _db.from(Db.applicationStatus).select('status_id').eq('status_name', 'Submitted').maybeSingle();
    if (status == null) throw const UserMessage('The application system is not set up yet. Please contact support.');
    final created = await _db
        .from(Db.application)
        .insert({'student_id': student.id, 'room_id': roomId, 'status_id': status['status_id'], 'application_date': isoDate(DateTime.now())})
        .select('application_id, application_number')
        .single();
    final appId = created['application_id'] as String;
    final failed = <String>[];
    for (final entry in files.entries) {
      if (entry.value == null) continue;
      try {
        await uploadDocument(appId, entry.key, entry.value!);
      } catch (_) {
        failed.add(entry.key);
      }
    }
    return (number: (created['application_number'] ?? '') as String, failed: failed);
  }
}

class DocumentItem {
  const DocumentItem({required this.type, required this.path});
  final String type, path;
}
