import 'package:flutter/material.dart';
import '../core/utils/format.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final l = label.toLowerCase();
    Color bg = const Color(0xFFFFE0B2), fg = const Color(0xFFE65100);
    if (['approved', 'confirmed', 'verified', 'resolved', 'completed', 'paid'].any(l.contains)) {
      bg = const Color(0xFFC8F7D0); fg = const Color(0xFF1B7F3A);
    } else if (['rejected', 'cancelled', 'declined'].any(l.contains)) {
      bg = const Color(0xFFFFCDD2); fg = const Color(0xFFC62828);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(statusLabel(label), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
