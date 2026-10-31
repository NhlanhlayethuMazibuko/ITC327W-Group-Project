import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/custom_bottom_nav.dart';
//import '../../core/routes/app_router.dart';

class MaintenanceRequestsScreen extends StatelessWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      body: SafeArea(
        child: Column(
          children: [
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

                        icon: const Icon(Icons.arrow_back),
                      ),
                    ],
                  ),

                  Image.asset('assets/images/logo.jpeg', height: 80),

                  const SizedBox(height: 15),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Maintenance Requests',

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            const Icon(
              Icons.inventory_2_outlined,
              size: 50,
              color: Colors.grey,
            ),

            const SizedBox(height: 10),

            const Text(
              'No current maintenance requests',
              style: TextStyle(color: Colors.grey),
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: () {
                context.push('/new-maintenance-request');
              },

              icon: const Icon(Icons.add, color: Colors.white),

              label: const Text(
                'New Request',

                style: TextStyle(color: Colors.white),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
