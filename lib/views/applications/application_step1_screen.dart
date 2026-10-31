import 'package:bigbrother/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApplicationStep1Screen extends StatefulWidget {
  const ApplicationStep1Screen({super.key});

  @override
  State<ApplicationStep1Screen> createState() => _ApplicationStep1ScreenState();
}

class _ApplicationStep1ScreenState extends State<ApplicationStep1Screen> {
  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _dobController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),

      firstDate: DateTime(1950),

      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _dobController.text =
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
    }
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
            context.go(RouteNames.applicationStep2);
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
              'Complete your application - Step 1-4',

              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 25),

            // STEP INDICATOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  _buildStep('1', true, 'Personal\nDetails'),

                  _buildStep('2', false, 'Academic\nDetails'),

                  _buildStep('3', false, 'Family\nInformation'),

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
                    controller: _fullNameController,

                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),

                      hintText: 'Full Name',

                      filled: true,

                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _emailController,

                    keyboardType: TextInputType.emailAddress,

                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),

                      hintText: 'Email Address',

                      filled: true,

                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _phoneController,

                    keyboardType: TextInputType.phone,

                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_outlined),

                      hintText: 'Phone Number',

                      filled: true,

                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _dobController,

                    readOnly: true,

                    onTap: _selectDate,

                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month),

                      hintText: 'Date of Birth',

                      filled: true,

                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,

                    height: 50,

                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/application-step-2');
                        // NEXT SCREEN

                        /*
                        NEXT:
                        ApplicationStep2Screen
                        */
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text('Next', style: TextStyle(color: Colors.white)),

                          SizedBox(width: 8),

                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Your home away from home',

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),

            const SizedBox(height: 10),
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
              fontSize: 10,

              color: active ? Colors.white : Colors.black,
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
