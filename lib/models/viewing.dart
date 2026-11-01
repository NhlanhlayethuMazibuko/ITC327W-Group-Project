import '../core/utils/format.dart';

class ViewingDraft {
  const ViewingDraft({required this.date, required this.preferred, required this.alternative, required this.gender, required this.roomType});
  final DateTime date;
  final String preferred, alternative, gender, roomType;
}

class Viewing {
  const Viewing({required this.id, required this.reference, required this.date, required this.preferred, required this.alternative, required this.gender, required this.roomType, required this.status});
  final String id, reference, preferred, alternative, gender, roomType, status;
  final DateTime? date;

  factory Viewing.fromMap(Map<String, dynamic> m) => Viewing(
        id: m['booking_id'] as String,
        reference: (m['reference_code'] ?? '') as String,
        date: parseDate(m['booking_date']),
        preferred: (m['preferred_time'] ?? '') as String,
        alternative: (m['alternative_time'] ?? '') as String,
        gender: (m['gender'] ?? '') as String,
        roomType: (m['room_type'] ?? '') as String,
        status: (m['booking_status'] ?? 'Pending') as String,
      );
}
