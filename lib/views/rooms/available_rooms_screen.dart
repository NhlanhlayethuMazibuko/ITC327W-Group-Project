import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class AvailableRoomsScreen extends StatelessWidget {
  const AvailableRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        title: const Text(
          'Available Rooms',
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Choose the perfect room to suit your lifestyle and budget',
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  _roomCard(
                    context,
                    image: 'assets/rooms/room1.jpeg',
                    type: 'Single Room',
                    furnished: 'Furnished',
                    price: 'R5,500/Month',
                  ),

                  _roomCard(
                    context,
                    image: 'assets/rooms/room2.jpeg',
                    type: 'Sharing Room',
                    furnished: 'Furnished',
                    price: 'R4,500/Month',
                  ),

                  _roomCard(
                    context,
                    image: 'assets/rooms/room3.jpeg',
                    type: 'Single Room',
                    furnished: 'Furnished',
                    price: 'R5,500/Month',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _roomCard(
    BuildContext context, {
    required String image,
    required String type,
    required String furnished,
    required String price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Unit',

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Text('$type • $furnished'),

                const SizedBox(height: 5),

                Text(
                  price,

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.green.shade100,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text('Available'),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              context.go(RouteNames.roomDetails);
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
            ),

            child: const Text(
              'View Details',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
