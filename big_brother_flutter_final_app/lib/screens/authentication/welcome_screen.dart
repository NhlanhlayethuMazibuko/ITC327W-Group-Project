import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/brand_header.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _feature(IconData icon, String label) => Column(
        children: [
          CircleAvatar(radius: 20, backgroundColor: const Color(0xFFFFE0B2), child: Icon(icon, color: AppColors.orangeDark, size: 20)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: false,
      title: 'Welcome to Big Brother Student Accommodation',
      subtitle: 'Find safe, affordable and convenient student accommodation with ease',
      child: Column(
        children: [
          AppButton(
            label: 'Log In',
            icon: Icons.arrow_forward,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Create New Account',
            outlined: true,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _feature(Icons.home_outlined, 'Find\naccommodation'),
              _feature(Icons.description_outlined, 'Submit\nApplications'),
              _feature(Icons.assignment_turned_in_outlined, 'Track Your\nApplication'),
            ],
          ),
        ],
      ),
    );
  }
}
