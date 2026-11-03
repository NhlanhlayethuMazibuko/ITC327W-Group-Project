import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/core.dart';
import '../models/models.dart';
import 'application_service.dart';
import 'student_service.dart';

class ReviewService {
  SupabaseClient get _db => Supabase.instance.client;

  /// Reads the public view, which only exposes first names.
  Future<List<Review>> previous() async {
    final rows = await _db.from(Db.reviewPublic).select().order('created_at', ascending: false).limit(20);
    return rows.map<Review>((r) => Review.fromMap(r)).toList();
  }

  Future<void> submit(int rating, String comment) async {
    final s = await StudentService().requireStudent();
    // room_id comes from the student's latest application; null if there is none.
    final app = await ApplicationService().latest();
    await _db.from(Db.review).insert({'student_id': s.id, 'room_id': app?.roomId, 'rating': rating, 'comment': comment.trim()});
  }
}
