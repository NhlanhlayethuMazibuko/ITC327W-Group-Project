import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class ScheduledViewingsScreen extends StatelessWidget {
  const ScheduledViewingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      body: SafeArea(
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

                  const SizedBox(height: 15),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Scheduled Viewings',

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.go(RouteNames.viewingDetails);
                      },

                      child: Container(
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: const Color(0xFFF3DFC2),

                          borderRadius: BorderRadius.circular(12),

                          boxShadow: const [
                            BoxShadow(blurRadius: 3, color: Colors.black12),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Single Room (Females)',

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.orange,

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: const Text(
                                    'Pending',

                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 5),

                                const Icon(Icons.chevron_right),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14),

                                const SizedBox(width: 5),

                                const Text('Mon, 12 Oct'),

                                const Spacer(),

                                const Icon(Icons.access_time, size: 14),

                                const SizedBox(width: 5),

                                const Text('10:00 AM / 2:00 PM'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF9800),

        onPressed: () {
          context.push(RouteNames.bookViewing);
        },

        child: const Icon(Icons.add, color: Colors.black),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}
