const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String two(int n) => n.toString().padLeft(2, '0');
String fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
String fmtDateTime(DateTime d) => '${fmtDate(d)}, ${two(d.hour)}:${two(d.minute)}';
String isoDate(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';
DateTime? parseDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

String money(num n) {
  final s = n.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return 'R$s';
}
