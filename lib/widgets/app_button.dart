import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed, this.loading = false, this.outlined = false, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final content = loading
        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (icon != null) ...[const SizedBox(width: 6), Icon(icon, size: 16)],
            ],
          );
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: outlined
          ? OutlinedButton(
              onPressed: enabled ? onPressed : null,
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orange, side: const BorderSide(color: AppColors.orange), shape: shape),
              child: content,
            )
          : ElevatedButton(
              onPressed: enabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange, foregroundColor: Colors.white, elevation: 0, shape: shape),
              child: content,
            ),
    );
  }
}
