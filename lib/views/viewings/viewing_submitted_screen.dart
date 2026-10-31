import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class ViewingSubmittedScreen extends StatelessWidget {
  const ViewingSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String referenceCode = 'BB-VW-261012-K7P4';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

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
                            context.go(RouteNames.home);
                          },

                          icon: const Icon(Icons.arrow_back),
                        ),
                      ],
                    ),

                    Image.asset('assets/images/logo.jpeg', height: 80),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Viewing Request\nSubmitted',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 35),

              // SUCCESS ICON
              Container(
                width: 100,
                height: 100,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: const Color(0xFFFFE0B2),
                ),

                child: const Center(
                  child: CircleAvatar(
                    radius: 35,

                    backgroundColor: Color(0xFFFF9800),

                    child: Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Your Reference Code',

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFF3DFC2),

                  borderRadius: BorderRadius.circular(10),
                ),

                child: Text(
                  referenceCode,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Keep this code for your records.',

                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 35),

              // BACK TO HOME
              SizedBox(
                width: 220,
                height: 50,

                child: ElevatedButton(
                  onPressed: () {
                    context.go(RouteNames.home);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  child: const Text(
                    'Back To Home',

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // GO TO VIEWINGS
              SizedBox(
                width: 220,
                height: 50,

                child: OutlinedButton(
                  onPressed: () {
                    context.go(RouteNames.scheduledViewings);
                  },

                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  child: const Text('Go To Viewings'),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}
