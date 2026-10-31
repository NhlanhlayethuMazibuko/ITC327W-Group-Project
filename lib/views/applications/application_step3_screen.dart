import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApplicationStep3Screen extends StatefulWidget {
  const ApplicationStep3Screen({super.key});

  @override
  State<ApplicationStep3Screen> createState() => _ApplicationStep3ScreenState();
}

class _ApplicationStep3ScreenState extends State<ApplicationStep3Screen> {
  final TextEditingController _guardianNameController = TextEditingController();

  final TextEditingController _guardianEmailController =
      TextEditingController();

  final TextEditingController _guardianPhoneController =
      TextEditingController();

  final TextEditingController _relationshipController = TextEditingController();

  @override
  void dispose() {
    _guardianNameController.dispose();
    _guardianEmailController.dispose();
    _guardianPhoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
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
              'Complete your application - Step 3 of 4',

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

                  _buildStep('3', true, 'Family\nInformation'),

                  _buildStep('4', false, 'Upload\nDocument'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Column(
                children: [
                  TextField(
                    controller: _guardianNameController,

                    decoration: InputDecoration(
                      hintText: 'Guardian Full Name',

                      prefixIcon: const Icon(Icons.person_outline),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _guardianEmailController,

                    keyboardType: TextInputType.emailAddress,

                    decoration: InputDecoration(
                      hintText: 'Guardian Email',

                      prefixIcon: const Icon(Icons.email_outlined),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _guardianPhoneController,

                    keyboardType: TextInputType.phone,

                    decoration: InputDecoration(
                      hintText: 'Guardian Phone Number',

                      prefixIcon: const Icon(Icons.phone_outlined),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _relationshipController,

                    decoration: InputDecoration(
                      hintText: 'Relationship',

                      prefixIcon: const Icon(Icons.people_outline),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                            context.go('/application-step-4');
                            /*
                            FUTURE:

                            Save Family Information
                            to Supabase

                            context.go(
                              '/application-step-4',
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

  Widget _buildStep(String number, bool active, String title) {
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
              color: active ? Colors.white : Colors.black,

              fontSize: 10,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,

          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 10,

            color: active ? const Color(0xFFFF9800) : Colors.grey,
          ),
        ),
      ],
    );
  }
}
