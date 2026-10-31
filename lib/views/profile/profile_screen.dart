import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /*
    ========================================
    CURRENT MOCK DATA
    ========================================
    */

    const String fullName = 'Thandiwe Vilakazi';

    const String email = 'thandiwevilakazi702@gmail.com';

    const String phoneNumber = '0714523258';

    const String studentNumber = '223567400';

    /*
    ========================================
    FUTURE SUPABASE IMPLEMENTATION
    ========================================

    final currentUser =
        Supabase.instance.client.auth.currentUser;

    final student =
        await supabase
            .from('student')
            .select()
            .eq(
              'user_id',
              currentUser!.id,
            )
            .single();

    final fullName =
        '${student['first_name']} ${student['last_name']}';

    final email =
        student['email'];

    final phoneNumber =
        student['phone_number'];

    final studentNumber =
        student['student_number'];

    ========================================
    */

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,

                decoration: const BoxDecoration(
                  color: Color(0xFFFF9800),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                  ),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            context.pop();
                          },

                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    Image.asset('assets/images/logo.jpeg', height: 80),

                    const SizedBox(height: 15),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // PROFILE IMAGE
              CircleAvatar(
                radius: 40,

                backgroundColor: Colors.grey.shade300,

                child: const Icon(Icons.person, size: 45),
              ),

              const SizedBox(height: 10),

              Text(
                fullName,

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // EMAIL
              _profileTile(
                icon: Icons.email_outlined,

                title: 'Email Address',

                value: email,
              ),

              const SizedBox(height: 12),

              // PHONE
              _profileTile(
                icon: Icons.phone_outlined,

                title: 'Phone Number',

                value: phoneNumber,
              ),

              const SizedBox(height: 12),

              // STUDENT NUMBER
              _profileTile(
                icon: Icons.school_outlined,

                title: 'Student Number',

                value: studentNumber,
              ),

              const SizedBox(height: 30),

              // CHANGE PASSWORD
              ListTile(
                leading: const Icon(Icons.lock_outline),

                title: const Text('Change Password'),

                onTap: () {
                  context.go(RouteNames.forgotPassword);
                },
              ),

              // LOGOUT
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),

                title: const Text(
                  'Log Out',

                  style: TextStyle(color: Colors.red),
                ),

                onTap: () {
                  /*
                  FUTURE SUPABASE

                  await Supabase
                      .instance
                      .client
                      .auth
                      .signOut();

                  */

                  context.go(RouteNames.login);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  static Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          Icon(icon),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
