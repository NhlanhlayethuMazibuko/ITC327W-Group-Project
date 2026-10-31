import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String studentName = 'Thando';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 25,
                ),

                decoration: const BoxDecoration(
                  color: Color(0xFFFF9800),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                  ),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,

                          child: Icon(Icons.person, color: Colors.black),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Hello, $studentName',

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Image.asset('assets/images/logo.jpeg', height: 45),
                      ],
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for rooms',

                        prefixIcon: const Icon(Icons.search),

                        filled: true,

                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // QUICK ACTIONS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    'Quick Actions',

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  GestureDetector(
                    onTap: () {
                      context.go('/maintenance-requests');
                    },

                    child: _quickAction(
                      Icons.build_circle,
                      'Maintenance\nRequests',
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      context.go(RouteNames.applicationTracker);
                    },

                    child: _quickAction(Icons.description, 'My\nApplications'),
                  ),

                  GestureDetector(
                    onTap: () {
                      context.go(RouteNames.scheduledViewings);
                    },

                    child: _quickAction(
                      Icons.calendar_month,
                      'Scheduled\nViewings',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // FEATURED UNITS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'Featured Units',

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        context.go(RouteNames.rooms);
                      },

                      child: const Text(
                        'See All',

                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 230,

                child: ListView(
                  scrollDirection: Axis.horizontal,

                  children: [
                    GestureDetector(
                      onTap: () {
                        context.go(RouteNames.roomDetails);
                      },

                      child: const _RoomCard(
                        roomName: 'Unit A',
                        roomType: 'Single Room',
                        price: 'R5,500/Month',

                        imagePath: 'assets/rooms/room1.jpeg',
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        context.go(RouteNames.roomDetails);
                      },

                      child: const _RoomCard(
                        roomName: 'Unit B',
                        roomType: 'Sharing Room',
                        price: 'R4,500/Month',

                        imagePath: 'assets/rooms/room2.jpeg',
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        context.go(RouteNames.roomDetails);
                      },

                      child: const _RoomCard(
                        roomName: 'Unit C',
                        roomType: 'Single Room',
                        price: 'R5,200/Month',

                        imagePath: 'assets/rooms/room3.jpeg',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // LATEST NOTIFICATIONS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    'Latest Notifications',

                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Container(
                margin: const EdgeInsets.all(16),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.campaign_outlined, color: Colors.orange),

                    SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'New accommodation units available! Don’t miss out on our latest listings.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  static Widget _quickAction(IconData icon, String title) {
    return Container(
      width: 105,
      height: 95,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFE0B2),

            child: Icon(icon, color: Colors.orange),
          ),

          const SizedBox(height: 8),

          Text(
            title,

            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final String roomName;
  final String roomType;
  final String price;
  final String imagePath;

  const _RoomCard({
    required this.roomName,
    required this.roomType,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,

      margin: const EdgeInsets.only(left: 16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),

              topRight: Radius.circular(12),
            ),

            child: Image.asset(
              imagePath,

              height: 100,

              width: double.infinity,

              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  roomName,

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(roomType),

                const SizedBox(height: 4),

                Text(price),

                const SizedBox(height: 8),

                Chip(
                  backgroundColor: Colors.green.shade100,

                  label: const Text('Available'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
