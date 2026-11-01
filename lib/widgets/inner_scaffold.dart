import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Orange title bar with a white rounded sheet, used by post-login screens.
class InnerScaffold extends StatelessWidget {
  const InnerScaffold({super.key, required this.title, required this.child, this.showBack = true, this.bottom});
  final String title;
  final Widget child;
  final bool showBack;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orange,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          SizedBox(
            height: 64,
            child: Row(children: [
              if (showBack)
                IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.text), onPressed: () => Navigator.of(context).maybePop())
              else
                const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.text)),
            ]),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: child,
            ),
          ),
          if (bottom != null) Container(color: Colors.white, child: bottom),
        ]),
      ),
    );
  }
}
