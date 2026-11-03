import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase settings are passed at build time, never committed:
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'https://gtpujwmtglyffnzhbklo.supabase.co');
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY',
      defaultValue: 'sb_publishable_hpd_96hEo0RG_qoN1jlZmg_TjMHA9mc');

  // ASSUMPTION: room images live in this bucket when image_path is not a full URL.
  static const roomImageBucket = String.fromEnvironment('ROOM_IMAGE_BUCKET', defaultValue: 'room-images');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
  static bool _initialized = false;

  /// Returns null on success, or a student-friendly error message.
  static Future<String?> initialize() async {
    if (_initialized) return null;
    if (!isConfigured) {
      return 'The app is not configured yet. See the README for the Supabase setup.';
    }
    try {
      await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey)
          .timeout(const Duration(seconds: 10));
      _initialized = true;
      return null;
    } catch (_) {
      return 'Could not connect to the server. Check your internet connection and try again.';
    }
  }
}
