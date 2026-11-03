import '../core/utils/format.dart';

class ViewingDraft {
  const ViewingDraft({required this.date, required this.preferred, required this.alternative, required this.gender, required this.roomType});
  final DateTime date;
  final String preferred, alternative, gender, roomType;
}

/// Also written to booking.message so staff see it on older bookings and in the web admin.
String viewingMessage(String roomType, String gender) => 'Room type: $roomType; Gender: $gender';

String _messageField(String? message, String label) {
  final match = RegExp('$label: ([^;]*)').firstMatch(message ?? '');
  return match?.group(1)?.trim() ?? '';
}

class Viewing {
  const Viewing({required this.id, required this.reference, required this.date, required this.preferred, required this.alternative, required this.gender, required this.roomType, required this.status, this.staffAltDate, this.staffAltTime, this.staffMessage, this.respondedAt});
  final String id, reference, preferred, alternative, gender, roomType, status;
  final DateTime? date, staffAltDate, respondedAt;
  final String? staffAltTime, staffMessage;

  factory Viewing.fromMap(Map<String, dynamic> m) => Viewing(
        id: m['booking_id'] as String,
        reference: (m['reference_code'] ?? '') as String,
        date: parseDate(m['booking_date']),
        preferred: (m['preferred_time'] ?? '') as String,
        alternative: (m['alternative_time'] ?? '') as String,
        gender: (m['gender'] as String?) ?? _messageField(m['message'] as String?, 'Gender'),
        roomType: (m['room_type'] as String?) ?? _messageField(m['message'] as String?, 'Room type'),
        status: (m['booking_status'] ?? 'Pending') as String,
        staffAltDate: parseDate(m['staff_alt_date']),
        staffAltTime: m['staff_alt_time'] as String?,
        staffMessage: m['staff_message'] as String?,
        respondedAt: parseDate(m['responded_at']),
      );
}
