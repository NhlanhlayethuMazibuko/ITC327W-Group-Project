import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,

              decoration: const BoxDecoration(
                color: Color(0xFFFF9800),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),

              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,

                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),

                      onPressed: () {
                        context.go(RouteNames.login);
                      },
                    ),
                  ),

                  Image.asset('assets/images/logo.jpeg', height: 90),

                  const SizedBox(height: 15),
                ],
              ),
            ),

            const SizedBox(height: 60),

            const Text(
              'Forgot Your Password?',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),

              child: TextField(
                controller: _emailController,

                keyboardType: TextInputType.emailAddress,

                decoration: InputDecoration(
                  hintText: 'Enter email address',

                  prefixIcon: const Icon(Icons.email_outlined),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 260,
              height: 50,

              child: ElevatedButton(
                onPressed: () {
                  /*
                  FUTURE SUPABASE

                  await Supabase
                      .instance
                      .client
                      .auth
                      .resetPasswordForEmail(
                        _emailController.text,
                      );

                  context.go(
                    RouteNames.verifyEmail,
                  );
                  */

                  context.go(RouteNames.verifyEmail);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),

                child: const Text(
                  'Continue',

                  style: TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                context.go(RouteNames.login);
              },

              child: const Text(
                '← Back to Login',

                style: TextStyle(color: Colors.orange),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),

              child: Column(
                children: [
                  const Text(
                    'Your home away from home',

                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    width: 60,
                    height: 2,

                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),

                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
