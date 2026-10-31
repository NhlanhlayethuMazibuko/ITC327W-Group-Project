import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _studentNumberController =
      TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _studentNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  'Create Account',

                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Create your student account',

                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // FULL NAME
                TextField(
                  controller: _fullNameController,

                  decoration: InputDecoration(
                    labelText: 'Full Name',

                    prefixIcon: const Icon(Icons.person_outline),

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // EMAIL
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

                // STUDENT NUMBER
                TextField(
                  controller: _studentNumberController,

                  decoration: InputDecoration(
                    labelText: 'Student Number',

                    prefixIcon: const Icon(Icons.badge_outlined),

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PASSWORD
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

                const SizedBox(height: 20),

                // CONFIRM PASSWORD
                TextField(
                  controller: _confirmPasswordController,

                  obscureText: _obscureConfirmPassword,

                  decoration: InputDecoration(
                    labelText: 'Confirm Password',

                    prefixIcon: const Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },

                      icon: Icon(
                        _obscureConfirmPassword
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

                const SizedBox(height: 30),

                // CREATE ACCOUNT BUTTON
                SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      // Register via AuthViewModel
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    child: const Text(
                      'Create Account',

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
                    const Text('Already have an account?'),

                    TextButton(
                      onPressed: () {
                        context.go(RouteNames.login);
                      },

                      child: const Text('Login'),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
