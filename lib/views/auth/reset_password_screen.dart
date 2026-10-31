import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              'Reset Password',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),

              child: Column(
                children: [
                  TextField(
                    controller: _passwordController,

                    obscureText: _hidePassword,

                    decoration: InputDecoration(
                      hintText: 'Enter new password',

                      prefixIcon: const Icon(Icons.lock_outline),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },

                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _confirmPasswordController,

                    obscureText: _hideConfirm,

                    decoration: InputDecoration(
                      hintText: 'Confirm new password',

                      prefixIcon: const Icon(Icons.lock_outline),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hideConfirm = !_hideConfirm;
                          });
                        },

                        icon: Icon(
                          _hideConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: 250,
              height: 50,

              child: ElevatedButton(
                onPressed: () {
                  /*
                  FUTURE SUPABASE

                  await Supabase.instance
                      .client.auth
                      .updateUser(
                        UserAttributes(
                          password:
                          _passwordController.text,
                        ),
                      );

                  GO TO LOGIN
                  */

                  context.go(RouteNames.login);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                ),

                child: const Text(
                  'Continue',

                  style: TextStyle(color: Colors.white),
                ),
              ),
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
