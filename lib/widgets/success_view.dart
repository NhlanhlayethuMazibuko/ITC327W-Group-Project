import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'app_button.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key, required this.message, required this.primaryLabel, required this.onPrimary, this.reference, this.warning, this.secondaryLabel, this.onSecondary, this.child});
  final String message, primaryLabel;
  final VoidCallback onPrimary;
  final String? reference, warning, secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const CircleAvatar(radius: 40, backgroundColor: Color(0xFFFFE0B2), child: Icon(Icons.check_circle, size: 56, color: AppColors.orange)),
      const SizedBox(height: 16),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      if (reference != null && reference!.isNotEmpty) ...[
        const SizedBox(height: 16),
        const Text('Your Reference Code:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0xFFFFF0D5),
          child: Text(reference!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ],
      if (child != null) ...[const SizedBox(height: 12), child!],
      if (warning != null) ...[
        const SizedBox(height: 12),
        Text(warning!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
      ],
      const SizedBox(height: 24),
      AppButton(label: primaryLabel, onPressed: onPrimary),
      if (secondaryLabel != null) ...[
        const SizedBox(height: 10),
        AppButton(label: secondaryLabel!, outlined: true, onPressed: onSecondary),
      ],
    ]);
  }
}
