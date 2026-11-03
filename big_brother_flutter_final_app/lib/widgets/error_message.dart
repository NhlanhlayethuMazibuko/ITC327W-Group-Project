import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage(this.message, {super.key});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(message!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
    );
  }
}
