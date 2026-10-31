import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';
import '../../widgets/custom_bottom_nav.dart';

class BookViewingScreen extends StatefulWidget {
  const BookViewingScreen({super.key});

  @override
  State<BookViewingScreen> createState() => _BookViewingScreenState();
}

class _BookViewingScreenState extends State<BookViewingScreen> {
  String? selectedDate;
  String? preferredTime;
  String? alternativeTime;
  String? selectedGender;
  String? selectedRoom;

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

              // IMAGE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: Image.asset(
                    'assets/rooms/room1.jpeg',

                    height: 170,

                    width: double.infinity,

                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Book a Viewing',

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const Text('Choose a preferred date and time.'),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: 'Mon, 12 Oct 2026',

                          child: Text('Mon, 12 Oct 2026'),
                        ),

                        DropdownMenuItem(
                          value: 'Tue, 13 Oct 2026',

                          child: Text('Tue, 13 Oct 2026'),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() {
                          selectedDate = value;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Preferred Time',
                              border: OutlineInputBorder(),
                            ),

                            items: const [
                              DropdownMenuItem(
                                value: '10:00 AM',

                                child: Text('10:00 AM'),
                              ),

                              DropdownMenuItem(
                                value: '02:00 PM',

                                child: Text('02:00 PM'),
                              ),
                            ],

                            onChanged: (value) {
                              setState(() {
                                preferredTime = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Alternative Time',
                              border: OutlineInputBorder(),
                            ),

                            items: const [
                              DropdownMenuItem(
                                value: '10:00 AM',

                                child: Text('10:00 AM'),
                              ),

                              DropdownMenuItem(
                                value: '02:00 PM',

                                child: Text('02:00 PM'),
                              ),
                            ],

                            onChanged: (value) {
                              setState(() {
                                alternativeTime = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),

                        DropdownMenuItem(
                          value: 'Female',

                          child: Text('Female'),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Room Type',
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: 'Single Room (Females)',

                          child: Text('Single Room (Females)'),
                        ),

                        DropdownMenuItem(
                          value: 'Sharing Room',

                          child: Text('Sharing Room'),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() {
                          selectedRoom = value;
                        });
                      },
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,

                      height: 50,

                      child: ElevatedButton(
                        onPressed: () {
                          context.go(RouteNames.bookingDetails);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                        ),

                        child: const Text(
                          'Submit',

                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}
