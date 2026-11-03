import '../core/config/db_names.dart';
import '../core/utils/format.dart';

const kDocTypes = ['ID Document', 'Proof of Registration', 'Funding Approval / Parent Payslip'];

/// application.status_id values (application_status table).
const kStatusNames = {1: 'Submitted', 2: 'Under Review', 3: 'Approved', 4: 'Rejected', 5: 'Draft', 6: 'Moved Out'};
const kStatusSubmitted = 1;
const kStatusApproved = 3;
const kStatusRejected = 4;
const kStatusDraft = 5;
const kStatusMovedOut = 6;

class Application {
  const Application({required this.id, required this.number, required this.statusId, required this.statusName, required this.roomName, this.roomId, this.date, this.staffNote});
  final String id, number, statusName, roomName;
  final int statusId;
  final String? roomId, staffNote;
  final DateTime? date;

  factory Application.fromMap(Map<String, dynamic> m) {
    final st = m[Db.applicationStatus] as Map?;
    final room = m[Db.room] as Map?;
    final statusId = (m['status_id'] as num?)?.toInt() ?? kStatusSubmitted;
    return Application(
      id: m['application_id'] as String,
      number: (m['application_number'] ?? '') as String,
      statusId: statusId,
      statusName: (st?['status_name'] ?? kStatusNames[statusId] ?? 'Submitted') as String,
      roomName: (room?['room_name'] ?? '') as String,
      roomId: m['room_id'] as String?,
      date: parseDate(m['application_date']),
      staffNote: m['staff_note'] as String?,
    );
  }
}
