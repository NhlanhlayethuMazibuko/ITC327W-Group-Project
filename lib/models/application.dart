import '../core/config/db_names.dart';
import '../core/utils/format.dart';

const kDocTypes = ['ID Document', 'Proof of Registration', 'Funding Approval / Parent Payslip'];

class Application {
  const Application({required this.id, required this.number, required this.statusName, required this.roomName, this.date});
  final String id, number, statusName, roomName;
  final DateTime? date;

  factory Application.fromMap(Map<String, dynamic> m) {
    final st = m[Db.applicationStatus] as Map?;
    final room = m[Db.room] as Map?;
    return Application(
      id: m['application_id'] as String,
      number: (m['application_number'] ?? '') as String,
      statusName: (st?['status_name'] ?? 'Submitted') as String,
      roomName: (room?['room_name'] ?? '') as String,
      date: parseDate(m['application_date']),
    );
  }
}
