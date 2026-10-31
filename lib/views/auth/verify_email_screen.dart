import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _digit1 = TextEditingController();

  final TextEditingController _digit2 = TextEditingController();

  final TextEditingController _digit3 = TextEditingController();

  final TextEditingController _digit4 = TextEditingController();

  final TextEditingController _digit5 = TextEditingController();

  final TextEditingController _digit6 = TextEditingController();

  @override
  void dispose() {
    _digit1.dispose();
    _digit2.dispose();
    _digit3.dispose();
    _digit4.dispose();
    _digit5.dispose();
    _digit6.dispose();
    super.dispose();
  }

  Widget _codeBox(TextEditingController controller) {
    return SizedBox(
      width: 42,
      child: TextField(
        controller: controller,
        maxLength: 1,
        textAlign: TextAlign.center,

        decoration: const InputDecoration(counterText: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      body: SafeArea(
        child: Column(
          children: [
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
                      onPressed: () {
                        context.pop();
                      },

                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),

                  Image.asset('assets/images/logo.jpeg', height: 90),

                  const SizedBox(height: 15),
                ],
              ),
            ),

            const SizedBox(height: 50),

            const Text(
              'Verify your email address',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text('Enter the 6-digit verification code'),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                _codeBox(_digit1),
                const SizedBox(width: 6),

                _codeBox(_digit2),
                const SizedBox(width: 6),

                _codeBox(_digit3),
                const SizedBox(width: 6),

                _codeBox(_digit4),
                const SizedBox(width: 6),

                _codeBox(_digit5),
                const SizedBox(width: 6),

                _codeBox(_digit6),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 250,
              height: 50,

              child: ElevatedButton(
                onPressed: () {
                  /*
                  FUTURE SUPABASE

                  Verify OTP

                  await Supabase.instance
                    .client.auth.verifyOTP(...)

                  If success:

                  context.go(
                    RouteNames.resetPassword,
                  );
                  */

                  context.go(RouteNames.resetPassword);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                ),

                child: const Text(
                  'Verify',

                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Text('Did not receive code? '),

                TextButton(
                  onPressed: () {
                    /*
                    FUTURE

                    Resend OTP
                    */
                  },

                  child: const Text('Resend code'),
                ),
              ],
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.only(bottom: 20),

              child: Text('Your home away from home'),
            ),
          ],
        ),
      ),
    );
  }
}
