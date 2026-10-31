import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class ApplicationSubmittedScreen extends StatelessWidget {
  const ApplicationSubmittedScreen({super.key});

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
                  const SizedBox(height: 10),

                  Image.asset('assets/images/logo.jpeg', height: 80),

                  const SizedBox(height: 15),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Application Submitted',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            // SUCCESS ICON
            Container(
              width: 120,
              height: 120,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.orange.shade100,
              ),

              child: Center(
                child: Container(
                  width: 90,
                  height: 90,

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,

                    color: Color(0xFFFF9800),
                  ),

                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Thank You!',

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),

              child: Text(
                'We have received your application. Your application is currently under review by management.',

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: 220,
              height: 50,

              child: ElevatedButton(
                onPressed: () {
                  context.go(RouteNames.applicationTracker);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),

                child: const Text(
                  'Track Application',

                  style: TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.only(bottom: 10),

              child: Text(
                'Your home away from home',

                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}
