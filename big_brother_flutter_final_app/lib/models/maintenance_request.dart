import '../core/utils/format.dart';

class MaintenanceRequest {
  const MaintenanceRequest({required this.id, required this.reference, required this.category, required this.priority, required this.type, required this.description, required this.status, this.photoPath, this.photoUrl, this.createdAt});
  final String id, reference, category, priority, type, description, status;
  final String? photoPath, photoUrl;
  final DateTime? createdAt;

  factory MaintenanceRequest.fromMap(Map<String, dynamic> m) => MaintenanceRequest(
        id: m['request_id'] as String,
        reference: (m['reference_code'] ?? '') as String,
        category: (m['category'] ?? '') as String,
        priority: (m['priority'] ?? '') as String,
        type: (m['request_type'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        status: (m['status'] ?? 'submitted') as String,
        photoPath: m['photo_path'] as String?,
        photoUrl: m['photo_url'] as String?,
        createdAt: parseDate(m['created_at']),
      );
}

/// A row in maintenance_update, linked by request_id.
class MaintenanceUpdate {
  const MaintenanceUpdate({required this.id, required this.status, required this.message, this.createdAt});
  final String id, status, message;
  final DateTime? createdAt;

  factory MaintenanceUpdate.fromMap(Map<String, dynamic> m) => MaintenanceUpdate(
        id: m['update_id'] as String,
        status: (m['status'] ?? '') as String,
        message: (m['message'] ?? '') as String,
        createdAt: parseDate(m['created_at']),
      );
}
