import '../core/utils/format.dart';

class MaintenanceRequest {
  const MaintenanceRequest({required this.id, required this.reference, required this.category, required this.priority, required this.type, required this.description, required this.status, this.photoPath, this.createdAt});
  final String id, reference, category, priority, type, description, status;
  final String? photoPath;
  final DateTime? createdAt;

  factory MaintenanceRequest.fromMap(Map<String, dynamic> m) => MaintenanceRequest(
        id: m['request_id'] as String,
        reference: (m['reference_code'] ?? '') as String,
        category: (m['category'] ?? '') as String,
        priority: (m['priority'] ?? '') as String,
        type: (m['request_type'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        status: (m['status'] ?? 'Pending') as String,
        photoPath: m['photo_path'] as String?,
        createdAt: parseDate(m['created_at']),
      );
}
