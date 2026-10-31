import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      body: SafeArea(
        child: Column(
          children: [
            // TOP SECTION
            Container(
              width: double.infinity,

              decoration: const BoxDecoration(
                color: Color(0xFFFF9800),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(70),
                ),
              ),

              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 120,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // WELCOME TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),

              child: Text(
                'Welcome to Big\nBrother Student\nAccommodation',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 45),

              child: Text(
                'Find safe, affordable and convenient student accommodation with ease',

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),

            const SizedBox(height: 30),

            // LOGIN BUTTON
            SizedBox(
              width: 280,

              child: ElevatedButton(
                onPressed: () {
                  context.go(RouteNames.login);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),

                  minimumSize: const Size(double.infinity, 55),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      'Log In',

                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(width: 6),

                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // REGISTER BUTTON
            SizedBox(
              width: 280,

              child: OutlinedButton(
                onPressed: () {
                  context.go(RouteNames.register);
                },

                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF9800)),

                  minimumSize: const Size(double.infinity, 55),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                child: const Text(
                  'Create New Account',

                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // QUICK ACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: const [
                  _QuickAction(
                    icon: Icons.home_outlined,
                    label: 'Find\nAccommodation',
                  ),

                  _QuickAction(
                    icon: Icons.description_outlined,
                    label: 'Submit\nApplications',
                  ),

                  _QuickAction(
                    icon: Icons.fact_check_outlined,
                    label: 'Track Your\nApplication',
                  ),
                ],
              ),
            ),

            const Spacer(),

            // FOOTER
            Column(
              children: [
                const Text(
                  'Your home away from home',

                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),

                const SizedBox(height: 6),

                Container(
                  width: 60,
                  height: 3,

                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),

                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,

          backgroundColor: const Color(0xFFFFD180),

          child: Icon(icon, color: const Color(0xFF4E342E)),
        ),

        const SizedBox(height: 8),

        Text(
          label,

          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
