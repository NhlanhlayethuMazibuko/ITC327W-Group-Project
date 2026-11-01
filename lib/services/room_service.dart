import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import '../core/config/db_names.dart';
import '../models/room.dart';

class RoomService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Room>> fetchRooms({bool featuredOnly = false}) async {
    var query = _db.from(Db.room).select('*, ${Db.roomImage}(image_path)');
    if (featuredOnly) query = query.eq('is_featured', true);
    final rows = await query.order('price');
    return rows.map<Room>((r) => Room.fromMap(r)).toList();
  }

  /// image_path may be a full URL or a path inside the room image bucket.
  static String imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return Supabase.instance.client.storage.from(AppConfig.roomImageBucket).getPublicUrl(path);
  }
}
