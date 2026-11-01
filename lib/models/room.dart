import '../core/config/db_names.dart';

class Room {
  const Room({
    required this.id, required this.name, required this.type, required this.price,
    required this.capacity, required this.available, required this.description,
    required this.wifi, required this.laundry, required this.security,
    required this.shuttle, required this.furniture, required this.featured,
    required this.imagePaths,
  });

  final String id, name, type, description;
  final num price;
  final int capacity;
  final bool available, wifi, laundry, security, shuttle, furniture, featured;
  final List<String> imagePaths;

  factory Room.fromMap(Map<String, dynamic> m) {
    bool b(String k) => m[k] == true;
    final images = (m[Db.roomImage] as List?)
            ?.map((e) => (e as Map)['image_path'])
            .whereType<String>()
            .toList() ??
        <String>[];
    return Room(
      id: m['room_id'] as String,
      name: (m['room_name'] ?? 'Unit') as String,
      type: (m['room_type'] ?? '') as String,
      price: num.tryParse('${m['price']}') ?? 0,
      capacity: (m['capacity'] as num?)?.toInt() ?? 0,
      available: b('availability_status'),
      description: (m['description'] ?? '') as String,
      // ASSUMPTION: the ERD's "Wi-Fi" column is named wifi in Postgres.
      wifi: b('wifi'),
      laundry: b('laundry'),
      security: b('security'),
      shuttle: b('shuttle'),
      furniture: b('furniture'),
      featured: b('is_featured'),
      imagePaths: images,
    );
  }

  String get priceLabel {
    final digits = price.round().toString();
    final grouped = digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return 'R$grouped/Month';
  }
}
