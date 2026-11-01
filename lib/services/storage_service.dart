import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/core.dart';

class UploadFile {
  const UploadFile(this.name, this.bytes, this.ext);
  final String name;
  final Uint8List bytes;
  final String ext;

  String get contentType => ext == 'pdf' ? 'application/pdf' : (ext == 'png' ? 'image/png' : 'image/jpeg');
  String get safeName => name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}

class StorageService {
  SupabaseClient get _db => Supabase.instance.client;
  static const _maxBytes = 5 * 1024 * 1024;

  String get uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw const UserMessage('Your session has expired. Please log in again.');
    return id;
  }

  /// Lets the student choose a JPG, PNG or PDF of up to 5 MB.
  Future<UploadFile?> pick({bool imagesOnly = false}) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: imagesOnly ? ['jpg', 'jpeg', 'png'] : ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (res == null || res.files.isEmpty) return null;
    final f = res.files.first;
    if (f.bytes == null) throw const UserMessage('That file could not be read. Please try another one.');
    if (f.size > _maxBytes) throw const UserMessage('The file is too large. The limit is 5 MB.');
    return UploadFile(f.name, f.bytes!, (f.extension ?? '').toLowerCase());
  }

  /// Files go in a folder named after the signed-in user so storage rules can protect them.
  Future<String> upload(String bucket, String subfolder, UploadFile file) async {
    final path = '$uid/$subfolder/${DateTime.now().millisecondsSinceEpoch}_${file.safeName}';
    await _db.storage.from(bucket).uploadBinary(path, file.bytes, fileOptions: FileOptions(contentType: file.contentType));
    return path;
  }

  Future<String> signedUrl(String bucket, String path) => _db.storage.from(bucket).createSignedUrl(path, 3600);
}
