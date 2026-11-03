import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppDropdown extends StatelessWidget {
  const AppDropdown({super.key, required this.hint, required this.icon, required this.items, required this.value, required this.onChanged, this.validator});
  final String hint;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        isExpanded: true,
        validator: validator,
        onChanged: onChanged,
        hint: Text(hint, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
        decoration: InputDecoration(prefixIcon: Icon(icon, size: 20, color: AppColors.text)),
      ),
    );
  }
}

/// Read-only field that opens a picker (used for dates).
class AppPickerField extends StatelessWidget {
  const AppPickerField({super.key, required this.controller, required this.hint, required this.icon, required this.onTap, this.validator});
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 20, color: AppColors.text)),
      ),
    );
  }
}
