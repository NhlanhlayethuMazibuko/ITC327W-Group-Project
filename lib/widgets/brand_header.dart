import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path()..lineTo(0, size.height - 30);
    p.quadraticBezierTo(size.width * 0.25, size.height + 10, size.width * 0.5, size.height - 20);
    p.quadraticBezierTo(size.width * 0.8, size.height - 55, size.width, size.height - 15);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Uses assets/images/logo.png when present, otherwise a text fallback.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.height = 90, this.onOrange = false});
  final double height;
  final bool onOrange;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      onOrange ? 'assets/images/logo_on_orange.png' : 'assets/images/logo.png',
      height: height,
      errorBuilder: (_, __, ___) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home_work_rounded, size: 48, color: AppColors.text),
          Text('BIG BROTHER STUDENT',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.text)),
          Text('ACCOMMODATIONS', style: TextStyle(fontSize: 10, letterSpacing: 4)),
        ],
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.height = 220, this.showBack = false, this.showLogo = true});
  final double height;
  final bool showBack;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.orange,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              if (showBack)
                Positioned(
                  left: 4,
                  top: 4,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              if (showLogo)
                const Center(child: Padding(padding: EdgeInsets.only(bottom: 24), child: BrandLogo(height: 100, onOrange: true))),
            ],
          ),
        ),
      ),
    );
  }
}

class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('Your home away from home',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppColors.muted)),
      );
}

/// Shared layout for all pre-login screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, this.subtitle, required this.child, this.showBack = true, this.fab});
  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBack;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: fab,
      body: SingleChildScrollView(
        child: Column(
          children: [
            BrandHeader(showBack: showBack),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                  const SizedBox(height: 20),
                  child,
                ],
              ),
            ),
            const BrandFooter(),
          ],
        ),
      ),
    );
  }
}
