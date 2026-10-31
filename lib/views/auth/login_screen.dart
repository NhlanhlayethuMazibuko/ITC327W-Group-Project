import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              children: [
                const SizedBox(height: 30),

                Image.asset('assets/images/logo.jpeg', height: 110),

                const SizedBox(height: 20),

                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign in to continue',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(
                    labelText: 'Email Address',

                    prefixIcon: const Icon(Icons.email_outlined),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,

                  obscureText: _obscurePassword,

                  decoration: InputDecoration(
                    labelText: 'Password',

                    prefixIcon: const Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },

                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,

                  child: TextButton(
                    onPressed: () {
                      context.go(RouteNames.forgotPassword);
                    },

                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      print('LOGIN BUTTON CLICKED');
                      context.go(RouteNames.home);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text("Don't have an account?"),

                    TextButton(
                      onPressed: () {
                        context.go(RouteNames.register);
                      },

                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
