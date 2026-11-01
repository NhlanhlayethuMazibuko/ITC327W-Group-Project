class Validators {
  static String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email address is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email address';
  }

  // Minimum length is an assumption - align it with the Supabase Auth setting.
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    return v.length < 8 ? 'Use at least 8 characters' : null;
  }

  static String? confirm(String? v, String original) =>
      v != original ? 'Passwords do not match' : null;
}
