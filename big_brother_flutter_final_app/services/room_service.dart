import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import '../core/config/db_names.dart';
import '../models/room.dart';
import '../widgets/local_room_images.dart';

class RoomService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Room>> fetchRooms({bool featuredOnly = false}) async {
    try {
      // room has no is_featured column, so featuredOnly no longer filters.
      // Same rooms and photos as the website: units A1-F1 in name order, photos from room_image.
      // is_listed = false hides test rooms, the same as on the website.
      final rows = await _db.from(Db.room).select('*, ${Db.roomImage}(image_path)').eq('is_listed', true).order('room_name');
      final rooms = rows.map<Room>((r) => Room.fromMap(r)).toList();
      if (rooms.isNotEmpty) {
        // Keep real Supabase photos when a room has them. For any room that
        // came back without images, assign a distinct bundled photo set by
        // index so each unit still shows its own pictures (instead of every
        // card falling back to the same placeholder).
        for (var i = 0; i < rooms.length; i++) {
          if (rooms[i].imagePaths.isEmpty) {
            rooms[i] = rooms[i].copyWith(imagePaths: LocalRoomImages.galleryFor(i));
          }
        }
        return rooms;
      }
    } catch (_) {
      // Supabase unreachable / table empty / not configured — fall back to the
      // bundled demo units below so the app still shows accommodation.
    }
    return demoRooms();
  }

  /// image_path may be a full URL or a path inside the room image bucket.
  static String imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return Supabase.instance.client.storage.from(AppConfig.roomImageBucket).getPublicUrl(path);
  }

  /// Built-in sample units bundled with the app. Each unit's [imagePaths] lists
  /// a bedroom photo first (used as its single picture on the home page and in
  /// the available-rooms list), followed by kitchen, bathroom and outside-view
  /// photos that appear in the slideshow on the unit details screen.
  static List<Room> demoRooms() => const [
        Room(
          id: 'demo-1',
          name: '1-Bedroom Apartment',
          type: '1-Bedroom',
          price: 4500,
          capacity: 1,
          available: true,
          description:
              'A private, comfortable 1-bedroom apartment with a study desk, a '
              'fitted kitchen and a private bathroom. Secure complex close to campus.',
          amenities: ['WiFi', 'Laundry', 'Security Camera', 'Shuttle service', 'Furnished'],
          imagePaths: [
            'assets/images/unit1.jpg',
            'assets/images/kitchen1.jpg',
            'assets/images/bath_new1.jpg',
            'assets/images/outside_new1.jpg',
          ],
        ),
        Room(
          id: 'demo-2',
          name: '2-Bedroom Apartment',
          type: '2-Bedroom',
          price: 5500,
          capacity: 2,
          available: true,
          description:
              'Spacious 2-bedroom unit with a shared lounge, a modern kitchen and '
              'a full bathroom. Ideal for sharing with a roommate.',
          amenities: ['WiFi', 'Laundry', 'Security Camera', 'Shuttle service', 'Furnished'],
          imagePaths: [
            'assets/images/unit3.jpg',
            'assets/images/kitchen2.jpg',
            'assets/images/bath_new2.jpg',
            'assets/images/outside_new3.jpg',
          ],
        ),
        Room(
          id: 'demo-3',
          name: 'Single Room with Balcony',
          type: 'Single Room',
          price: 4000,
          capacity: 1,
          available: true,
          description:
              'Cozy single room featuring a private balcony and study nook, with a '
              'shared kitchen and bathroom. Great natural light.',
          amenities: ['WiFi', 'Laundry', 'Security Camera', 'Shuttle service', 'Furnished'],
          imagePaths: [
            'assets/images/unit7.jpg',
            'assets/images/kitchen3.jpg',
            'assets/images/unit6.jpg',
            'assets/images/outside_new2.jpg',
          ],
        ),
        Room(
          id: 'demo-4',
          name: 'Studio Apartment',
          type: 'Studio',
          price: 5000,
          capacity: 1,
          available: true,
          description:
              'Self-contained studio with a built-in wardrobe, a kitchenette and a '
              'private bathroom. Secure complex with shuttle service.',
          amenities: ['WiFi', 'Laundry', 'Security Camera', 'Shuttle service', 'Furnished'],
          imagePaths: [
            'assets/images/unit2.jpg',
            'assets/images/kitchen1.jpg',
            'assets/images/bath_new1.jpg',
            'assets/images/unit4.jpg',
          ],
        ),
      ];
}
