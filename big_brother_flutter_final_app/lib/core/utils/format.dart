const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String two(int n) => n.toString().padLeft(2, '0');
String fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
String fmtDateTime(DateTime d) => '${fmtDate(d)}, ${two(d.hour)}:${two(d.minute)}';
String isoDate(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';
DateTime? parseDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

/// Turns stored values like 'awaiting_verification' or 'Requested' into display text.
/// The web and the app write slightly different words for the same state.
String statusLabel(String raw) {
  final s = raw.trim().replaceAll('_', ' ').toLowerCase();
  const same = {'requested': 'Pending', 'submitted': 'Submitted', 'preference saved': 'Awaiting Payment'};
  if (same.containsKey(s)) return same[s]!;
  return s.split(' ').where((w) => w.isNotEmpty).map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

String money(num n) {
  final s = n.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return 'R$s';
}
