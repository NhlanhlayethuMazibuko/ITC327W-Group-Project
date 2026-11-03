import '../core/config/db_names.dart';

class Room {
  const Room({
    required this.id, required this.name, required this.type, required this.price,
    required this.capacity, required this.available, required this.description,
    required this.amenities, required this.imagePaths, this.deposit = 0, this.location = '',
  });

  final String id, name, type, description, location;
  final num price, deposit;
  final int capacity;
  final bool available;
  final List<String> amenities, imagePaths;

  // room.amenities is a jsonb list of strings, e.g. ["WiFi","Furnished","Laundry"].
  bool _has(List<String> keys) => amenities.any((a) => keys.any(a.toLowerCase().contains));
  bool get wifi => _has(['wifi', 'wi-fi']);
  bool get laundry => _has(['laundry']);
  bool get security => _has(['security']);
  bool get shuttle => _has(['shuttle']);
  bool get furniture => _has(['furnish', 'furniture']);

  factory Room.fromMap(Map<String, dynamic> m) {
    List<String> strings(Object? v) => (v as List?)?.whereType<String>().toList() ?? <String>[];
    final linked = (m[Db.roomImage] as List?)
            ?.map((e) => (e as Map)['image_path'])
            .whereType<String>()
            .toList() ??
        <String>[];
    return Room(
      id: m['room_id'] as String,
      name: (m['room_name'] ?? 'Unit') as String,
      type: (m['room_type'] ?? '') as String,
      price: num.tryParse('${m['price']}') ?? 0,
      deposit: num.tryParse('${m['deposit']}') ?? 0,
      location: (m['location'] ?? '') as String,
      capacity: (m['capacity'] as num?)?.toInt() ?? 0,
      available: m['availability_status'] == true,
      description: (m['description'] ?? '') as String,
      amenities: strings(m['amenities']).isNotEmpty ? strings(m['amenities']) : _flagAmenities(m),
      imagePaths: [...strings(m['images']), ...linked],
    );
  }

  /// The ASP.NET admin saves amenities as true/false columns rather than in the jsonb list.
  static List<String> _flagAmenities(Map<String, dynamic> m) => [
        if (m['wifi'] == true) 'WiFi',
        if (m['laundry'] == true) 'Laundry',
        if (m['security'] == true) 'Security',
        if (m['shuttle'] == true) 'Shuttle service',
        if (m['furniture'] == true) 'Furnished',
      ];

  Room copyWith({List<String>? imagePaths}) => Room(
        id: id,
        name: name,
        type: type,
        price: price,
        deposit: deposit,
        location: location,
        capacity: capacity,
        available: available,
        description: description,
        amenities: amenities,
        imagePaths: imagePaths ?? this.imagePaths,
      );

  String get priceLabel {
    final digits = price.round().toString();
    final grouped = digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return 'R$grouped/Month';
  }
}
