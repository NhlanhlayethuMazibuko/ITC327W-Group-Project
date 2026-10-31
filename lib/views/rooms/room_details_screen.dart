import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/custom_bottom_nav.dart';

class RoomDetailsScreen extends StatefulWidget {
  const RoomDetailsScreen({super.key});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  final List<String> images = [
    'assets/unit/unitpic1.jpeg',
    'assets/unit/unitpic2.jpeg',
    'assets/unit/unitpic3.jpeg',
    'assets/unit/unitpic4.jpeg',
    'assets/unit/unitpic5.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),

        title: const Text(
          'Unit Details',
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(
                height: 220,

                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _controller,

                      itemCount: images.length,

                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },

                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15),

                          child: Image.asset(
                            images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),

                    Positioned(
                      left: 10,
                      top: 90,

                      child: CircleAvatar(
                        backgroundColor: Colors.black54,

                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),

                          onPressed: () {
                            if (currentPage > 0) {
                              _controller.previousPage(
                                duration: const Duration(milliseconds: 300),

                                curve: Curves.ease,
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    Positioned(
                      right: 10,
                      top: 90,

                      child: CircleAvatar(
                        backgroundColor: Colors.black54,

                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),

                          onPressed: () {
                            if (currentPage < images.length - 1) {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 300),

                                curve: Curves.ease,
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: List.generate(images.length, (index) {
                          return Container(
                            width: 8,
                            height: 8,

                            margin: const EdgeInsets.symmetric(horizontal: 3),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: currentPage == index
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Unit',

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),

              const Text('1-Bedroom Apartment'),

              const SizedBox(height: 10),

              const Text(
                'R5,500/Month',

                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: Colors.green.shade100,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Text('Available'),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: const [
                  _Amenity(icon: Icons.wifi, title: 'Wi-Fi'),

                  _Amenity(icon: Icons.local_laundry_service, title: 'Laundry'),

                  _Amenity(icon: Icons.security, title: 'Security'),

                  _Amenity(icon: Icons.directions_bus, title: 'Shuttle'),

                  _Amenity(icon: Icons.chair, title: 'Furniture'),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Description',

                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                'A private comfortable room with a bed, study desk, storage space and access to shared accommodation facilities.',
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: () {
                    context.go('/application');
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                  ),

                  child: const Text(
                    'Apply Now',

                    style: TextStyle(color: Colors.white),
                  ),
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

class _Amenity extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Amenity({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(child: Icon(icon)),

        const SizedBox(height: 5),

        Text(title),
      ],
    );
  }
}
