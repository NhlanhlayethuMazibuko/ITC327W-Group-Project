import 'package:flutter/material.dart';
import '../services/room_service.dart';

/// Accommodation photos bundled with the app (declared under `assets/images/`
/// in pubspec.yaml). Used for the built-in demo units and as a graceful
/// fallback whenever a Supabase room has no images of its own.
class LocalRoomImages {
  LocalRoomImages._();

  /// Distinct photo sets, one per unit. Each set is ordered:
  /// bedroom (the single cover shown on the home page and the rooms list),
  /// then kitchen, bathroom and an outside view (shown in the details
  /// slideshow).
  static const List<List<String>> galleries = <List<String>>[
    <String>[
      'assets/images/unit1.jpg',
      'assets/images/kitchen1.jpg',
      'assets/images/bath_new1.jpg',
      'assets/images/outside_new1.jpg',
    ],
    <String>[
      'assets/images/unit3.jpg',
      'assets/images/kitchen2.jpg',
      'assets/images/bath_new2.jpg',
      'assets/images/outside_new3.jpg',
    ],
    <String>[
      'assets/images/unit7.jpg',
      'assets/images/kitchen3.jpg',
      'assets/images/unit6.jpg',
      'assets/images/outside_new2.jpg',
    ],
    <String>[
      'assets/images/unit2.jpg',
      'assets/images/kitchen1.jpg',
      'assets/images/bath_new1.jpg',
      'assets/images/unit4.jpg',
    ],
  ];

  /// A distinct photo set for the unit at [index] (rotates if there are more
  /// units than photo sets).
  static List<String> galleryFor(int index) => galleries[index % galleries.length];

  /// The cover (bedroom) photo for the unit at [index].
  static String coverFor(int index) => galleryFor(index).first;

  /// All bedroom cover photos across the bundled galleries.
  static List<String> get bedrooms =>
      galleries.map((g) => g.first).toList();

  /// Pick a distinct bundled bedroom photo for a room, derived from its [id]
  /// so the same room always gets the same photo and different rooms get
  /// different ones.
  static String pick(String id) {
    final covers = bedrooms;
    if (covers.isEmpty) return 'assets/images/unit1.jpg';
    var hash = 0;
    for (final code in id.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return covers[hash % covers.length];
  }

  static Widget _fallbackIcon({double? width, double? height}) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF2F2F2),
        child: const Icon(Icons.bed_outlined, color: Color(0xFF9E9E9E)),
      );

  /// Render a bundled asset image with a graceful icon fallback.
  static Widget asset(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallbackIcon(width: width, height: height),
    );
  }

  /// Render a single image path that may be a bundled asset (`assets/...`) or a
  /// Supabase storage path / remote URL. If a remote image fails to load, the
  /// optional [fallbackAsset] bundled photo is shown instead of a blank icon.
  static Widget smart(String path, {double? width, double? height, BoxFit fit = BoxFit.cover, String? fallbackAsset}) {
    if (path.startsWith('assets/')) {
      return asset(path, width: width, height: height, fit: fit);
    }
    return Image.network(
      RoomService.imageUrl(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallbackAsset != null
          ? asset(fallbackAsset, width: width, height: height, fit: fit)
          : _fallbackIcon(width: width, height: height),
    );
  }
}
