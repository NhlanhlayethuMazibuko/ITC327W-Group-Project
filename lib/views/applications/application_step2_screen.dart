import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApplicationStep2Screen extends StatefulWidget {
  const ApplicationStep2Screen({super.key});

  @override
  State<ApplicationStep2Screen> createState() => _ApplicationStep2ScreenState();
}

class _ApplicationStep2ScreenState extends State<ApplicationStep2Screen> {
  final TextEditingController _institutionController = TextEditingController();

  final TextEditingController _studentNumberController =
      TextEditingController();

  final TextEditingController _yearOfStudyController = TextEditingController();

  bool _nsfasFunded = false;

  @override
  void dispose() {
    _institutionController.dispose();
    _studentNumberController.dispose();
    _yearOfStudyController.dispose();
    super.dispose();
  }

  Widget _buildStep(String number, bool active, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: active
              ? const Color(0xFFFF9800)
              : Colors.grey.shade300,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 10,
              color: active ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: active ? const Color(0xFFFF9800) : Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,

              decoration: const BoxDecoration(
                color: Color(0xFFFF9800),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),

              child: Column(
                children: [
                  Image.asset('assets/images/logo.jpeg', height: 80),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Student Accommodation Application',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            const Text(
              'Complete your application - Step 2 of 4',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 25),

            // STEP INDICATOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  _buildStep('1', true, 'Personal\nDetails'),

                  _buildStep('2', true, 'Academic\nDetails'),

                  _buildStep('3', false, 'Family\nInformation'),

                  _buildStep('4', false, 'Upload\nDocument'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // FORM
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Column(
                children: [
                  TextField(
                    controller: _institutionController,

                    decoration: InputDecoration(
                      hintText: 'Institution Name',

                      prefixIcon: const Icon(Icons.school_outlined),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _studentNumberController,

                    decoration: InputDecoration(
                      hintText: 'Student Number',

                      prefixIcon: const Icon(Icons.badge_outlined),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _yearOfStudyController,

                    keyboardType: TextInputType.number,

                    decoration: InputDecoration(
                      hintText: 'Year Of Study',

                      prefixIcon: const Icon(Icons.menu_book_outlined),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: CheckboxListTile(
                      value: _nsfasFunded,

                      title: const Text('NSFAS Funded'),

                      activeColor: const Color(0xFFFF9800),

                      onChanged: (value) {
                        setState(() {
                          _nsfasFunded = value ?? false;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.pop();
                          },

                          child: const Text('Back'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/application-step-3');
                            /*
                            FUTURE:

                            Save Academic Details
                            To Supabase

                            context.go(
                              '/application-step-3',
                            );
                            */
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                          ),

                          child: const Text(
                            'Next',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Your home away from home',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
