import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/core.dart';
import '../models/models.dart';
import 'student_service.dart';
import 'storage_service.dart';

class ApplicationService {
  SupabaseClient get _db => Supabase.instance.client;
  static const bucket = 'application-documents';

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

  /// Replaces any earlier file of the same type, so editing doesn't leave duplicates.
  Future<void> uploadDocument(String applicationId, String type, UploadFile file) async {
    final path = await StorageService().upload(bucket, applicationId, file);
    final old = await _db.from(Db.document).select('document_id, file_path').eq('application_id', applicationId).eq('document_type', type);
    await _db.from(Db.document).insert({'application_id': applicationId, 'document_type': type, 'file_path': path});
    for (final d in old) {
      await _db.from(Db.document).delete().eq('document_id', d['document_id']);
      await StorageService().remove(bucket, d['file_path'] as String?);
    }
  }

  /// Students may change or withdraw an application until staff start reviewing it.
  static bool canChange(Application app) => app.statusId == kStatusSubmitted || app.statusId == kStatusDraft;

  /// Saves edited answers and replaces any documents the student picked again.
  Future<List<String>> update({
    required Application app,
    required Map<String, dynamic> studentValues,
    required Map<String, UploadFile?> files,
  }) async {
    if (!canChange(app)) throw const UserMessage('This application is already being reviewed, so it can no longer be changed.');
    await StudentService().update(studentValues);
    final failed = <String>[];
    for (final entry in files.entries) {
      if (entry.value == null) continue;
      try {
        await uploadDocument(app.id, entry.key, entry.value!);
      } catch (_) {
        failed.add(entry.key);
      }
    }
    return failed;
  }

  /// Withdraws the application and its documents.
  Future<void> delete(Application app) async {
    if (!canChange(app)) throw const UserMessage('This application is already being reviewed, so it can no longer be deleted.');
    final docs = await _db.from(Db.document).select('file_path').eq('application_id', app.id);
    await _db.from(Db.document).delete().eq('application_id', app.id);
    await _db.from(Db.application).delete().eq('application_id', app.id);
    for (final d in docs) {
      await StorageService().remove(bucket, d['file_path'] as String?);
    }
  }

  /// Saves the form answers, creates the application, then uploads any chosen documents.
  /// A failed upload does not lose the application: it is listed so the student can retry.
  Future<({String number, List<String> failed})> submit({
    required String roomId,
    required Map<String, dynamic> studentValues,
    required Map<String, UploadFile?> files,
  }) async {
    final student = await StudentService().requireStudent();
    final room = await _db.from(Db.room).select('availability_status').eq('room_id', roomId).maybeSingle();
    if (room == null || room['availability_status'] != true) {
      throw const UserMessage('Sorry, that room is fully occupied. Please choose another available room.');
    }
    await StudentService().update(studentValues);
    final created = await _db
        .from(Db.application)
        .insert({'student_id': student.id, 'room_id': roomId, 'status_id': kStatusSubmitted, 'application_date': isoDate(DateTime.now())})
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
