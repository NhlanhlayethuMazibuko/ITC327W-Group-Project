import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApplicationStep4Screen extends StatefulWidget {
  const ApplicationStep4Screen({super.key});

  @override
  State<ApplicationStep4Screen> createState() => _ApplicationStep4ScreenState();
}

class _ApplicationStep4ScreenState extends State<ApplicationStep4Screen> {
  String? idDocument;
  String? registrationProof;
  String? incomeDocument;

  Future<void> _pickIdDocument() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        idDocument = result.files.single.name;
      });
    }
  }

  Future<void> _pickRegistrationProof() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        registrationProof = result.files.single.name;
      });
    }
  }

  Future<void> _pickIncomeDocument() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        incomeDocument = result.files.single.name;
      });
    }
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

  Widget _uploadCard({
    required String title,
    required String? fileName,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          Text(
            fileName ?? 'No file selected',

            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: onPressed,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
            ),

            child: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(backgroundColor: const Color(0xFFFF9800)),

      body: SingleChildScrollView(
        child: Column(
          children: [
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
              'Complete your application - Step 4 of 4',

              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  _buildStep('1', true, 'Personal\nDetails'),

                  _buildStep('2', true, 'Academic\nDetails'),

                  _buildStep('3', true, 'Family\nInformation'),

                  _buildStep('4', true, 'Upload\nDocument'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                children: [
                  _uploadCard(
                    title: 'ID Document',

                    fileName: idDocument,

                    onPressed: _pickIdDocument,
                  ),

                  const SizedBox(height: 15),

                  _uploadCard(
                    title: 'Proof of Registration',

                    fileName: registrationProof,

                    onPressed: _pickRegistrationProof,
                  ),

                  const SizedBox(height: 15),

                  _uploadCard(
                    title: 'Proof of Income',

                    fileName: incomeDocument,

                    onPressed: _pickIncomeDocument,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,

                    height: 50,

                    child: ElevatedButton(
                      onPressed: () {
                        /*
                        FUTURE SUPABASE

                        1. Upload files to
                           Supabase Storage

                        2. Save document
                           records

                        3. Save application

                        4. Create
                           application status

                        5. Navigate
                           to submitted screen
                        */

                        context.go('/application-submitted-screen');
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                      ),

                      child: const Text(
                        'Submit Application',

                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Your home away from home',

                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
