import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

/// A message that is already safe to show to the student.
class UserMessage implements Exception {
  const UserMessage(this.message);
  final String message;
}

/// Safe, student-friendly text for any backend error.
String friendlyError(Object e) {
  if (e is UserMessage) return e.message;
  if (e is PostgrestException) {
    if (e.code == '42P01' || e.code == 'PGRST205') {
      return 'This screen needs data that is not set up on the server yet.';
    }
    if (e.code == '42501') return 'You do not have permission to view this.';
    return 'The server could not load this data. Please try again.';
  }
  return AuthService.friendlyMessage(e);
}
