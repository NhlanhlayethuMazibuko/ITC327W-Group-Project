import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMPORARY DATA
    // Replace with actual booking data later

    const String viewingDate = 'Mon, 12 Oct 2026';

    const String preferredTime = '10:00 AM';

    const String alternativeTime = '2:00 PM';

    const String roomType = 'Single Room (Females)';

    const String fullName = 'Thandiwe Vilakazi';

    const String contactNumber = '0714523258';

    const String email = 'thandiwevilakazi702@gmail.com';

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
                'Booking Details',

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              // VIEWING DETAILS CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16),

                        SizedBox(width: 8),

                        Text(
                          'Viewing Details',

                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _detailRow('Date', viewingDate),

                    _detailRow('Preferred Time', preferredTime),

                    _detailRow('Alternative Time', alternativeTime),

                    _detailRow('Room Type', roomType),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // USER DETAILS CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person, size: 16),

                        SizedBox(width: 8),

                        Text(
                          'Your Details',

                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _detailRow('Full Name', fullName),

                    _detailRow('Contact Number', contactNumber),

                    _detailRow('Email Address', email),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Your viewing has not been booked yet. Confirm below to submit your request.',

                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // CONFIRM BUTTON
              SizedBox(
                width: 220,
                height: 50,

                child: ElevatedButton(
                  onPressed: () {
                    context.go(RouteNames.viewingSubmitted);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  child: const Text(
                    'Confirm',

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // EDIT BUTTON
              SizedBox(
                width: 220,
                height: 50,

                child: OutlinedButton(
                  onPressed: () {
                    context.go(RouteNames.bookViewing);
                  },

                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  child: const Text('Edit Viewing Details'),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(label),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
