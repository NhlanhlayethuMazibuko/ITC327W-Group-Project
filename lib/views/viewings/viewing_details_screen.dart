import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class ViewingDetailsScreen extends StatelessWidget {
  const ViewingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                            context.go(RouteNames.scheduledViewings);
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
                'Viewing Details',

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // ROOM IMAGE CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  boxShadow: const [
                    BoxShadow(blurRadius: 4, color: Colors.black12),
                  ],
                ),

                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),

                        topRight: Radius.circular(12),
                      ),

                      child: Image.asset(
                        'assets/rooms/room1.jpeg',

                        height: 180,

                        width: double.infinity,

                        fit: BoxFit.cover,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
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

                          const SizedBox(height: 10),

                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text(
                                'Single Room',

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                'R5500 p/m',

                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          const Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),

                              SizedBox(width: 5),

                              Text('Universitas, Bloemfontein'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // VIEWING DATE/TIME
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),

                        const SizedBox(width: 10),

                        const Text('Monday, 12 October 2026'),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18),

                        const SizedBox(width: 10),

                        const Text('10:00 AM / 2:00 PM'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // STATUS CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFFF3DFC2),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),

                        const SizedBox(width: 8),

                        const Text(
                          'Awaiting Confirmation',

                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Your viewing request has been submitted. We will notify you when the residence confirms the viewing.',

                      style: TextStyle(fontSize: 12),
                    ),
                  ],
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
