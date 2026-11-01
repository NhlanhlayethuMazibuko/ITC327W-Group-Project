import '../core/utils/format.dart';

class Student {
  const Student({
    required this.id, required this.fullName, this.studentNumber = '', this.phone = '',
    this.dateOfBirth, this.institution, this.yearOfStudy, this.nsfasFunded,
    this.guardianName = '', this.guardianEmail = '', this.guardianContact = '', this.relationship,
  });
  final String id, fullName, studentNumber, phone, guardianName, guardianEmail, guardianContact;
  final DateTime? dateOfBirth;
  final String? institution, relationship;
  final int? yearOfStudy;
  final bool? nsfasFunded;

  factory Student.fromMap(Map<String, dynamic> m) => Student(
        id: m['student_id'] as String,
        fullName: (m['full_name'] ?? '') as String,
        studentNumber: (m['student_number'] ?? '') as String,
        phone: (m['phone_number'] ?? '') as String,
        dateOfBirth: parseDate(m['date_of_birth']),
        institution: m['institution'] as String?,
        yearOfStudy: (m['year_of_study'] as num?)?.toInt(),
        nsfasFunded: m['nsfas_funded'] as bool?,
        guardianName: (m['guardian_name'] ?? '') as String,
        guardianEmail: (m['guardian_email'] ?? '') as String,
        guardianContact: (m['guardian_contact'] ?? '') as String,
        relationship: m['relationship'] as String?,
      );
}
