import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper over Supabase Auth. No passwords are stored anywhere else.
class AuthService {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  Session? get currentSession => _auth.currentSession;
  User? get currentUser => _auth.currentUser;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
  }) =>
      _auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim(), 'student_number': studentNumber.trim()},
      );

  Future<AuthResponse> verifyOtp({
    required String email,
    required String code,
    required OtpType type,
  }) =>
      _auth.verifyOTP(email: email.trim(), token: code, type: type);

  Future<void> resendSignupCode(String email) =>
      _auth.resend(type: OtpType.signup, email: email.trim());

  Future<AuthResponse> signIn(String email, String password) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  Future<void> sendRecoveryCode(String email) =>
      _auth.resetPasswordForEmail(email.trim());

  Future<UserResponse> updatePassword(String newPassword) =>
      _auth.updateUser(UserAttributes(password: newPassword));

  Future<void> signOut() => _auth.signOut();

  /// Converts backend errors into messages that are safe to show a student.
  static String friendlyMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Please try again.';
    }
    if (error is AuthException) {
      final m = error.message.toLowerCase();
      if (m.contains('invalid login')) return 'Incorrect email or password.';
      if (m.contains('not confirmed')) return 'Please verify your email address first.';
      if (m.contains('already registered')) return 'An account with this email already exists.';
      if (m.contains('expired') || m.contains('invalid') && m.contains('token')) {
        return 'That code is invalid or has expired. Request a new one.';
      }
      if (m.contains('rate limit') || m.contains('too many')) {
        return 'Too many attempts. Please wait a moment and try again.';
      }
      if (m.contains('password')) return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
