import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/error_message.dart';
import '../authentication/welcome_screen.dart';
import '../home/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() { _error = null; _ready = false; });
    final error = await AppConfig.initialize();
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (AuthService().currentSession != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
      return;
    }
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const BrandHeader(height: 150, showLogo: false),
          const Spacer(),
          const BrandLogo(height: 110),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                ErrorMessage(_error),
                if (_error != null)
                  AppButton(label: 'Try again', onPressed: _init)
                else
                  AppButton(
                    label: 'Continue',
                    onPressed: _ready
                        ? () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()))
                        : null,
                    loading: !_ready,
                  ),
              ],
            ),
          ),
          const BrandFooter(),
        ],
      ),
    );
  }
}
