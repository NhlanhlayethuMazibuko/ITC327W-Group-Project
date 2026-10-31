import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/custom_bottom_nav.dart';

class MaintenanceRequestSubmittedScreen extends StatelessWidget {
  const MaintenanceRequestSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String referenceCode = 'BB-MNT-2026-004';

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
                            context.go('/home');
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
                'Maintenance Request\nSubmitted',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

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

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Keep this reference number for follow up on your request.',

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 25),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),

                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: const Color(0xFFF3DFC2),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 18),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: Text(
                        'Management will review the issue and contact you if access arrangements are required. For urgent safety issues, contact management directly.',

                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // BACK TO HOME
              SizedBox(
                width: 220,
                height: 50,

                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
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

              // VIEW REQUESTS
              SizedBox(
                width: 220,
                height: 50,

                child: OutlinedButton(
                  onPressed: () {
                    context.go('/maintenance-requests');
                  },

                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  child: const Text('View Requests'),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
