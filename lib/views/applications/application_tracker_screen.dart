import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_bottom_nav.dart';

class ApplicationTrackerScreen extends StatefulWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  State<ApplicationTrackerScreen> createState() =>
      _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> {
  String? uploadedIdCopy;
  String? uploadedRegistration;

  Future<void> _uploadDocument(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        if (type == 'id') {
          uploadedIdCopy = result.files.single.name;
        }

        if (type == 'registration') {
          uploadedRegistration = result.files.single.name;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const applicationNumber = 'A16';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      body: SafeArea(
        child: ListView(
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
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
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

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Application Status Tracker',

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // APPLICATION CARD
            Center(
              child: Container(
                width: 300,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFFF3DFC2),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Application Number',

                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.circle_outlined, size: 16),

                        const SizedBox(width: 8),

                        Text(applicationNumber),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Pending Documents',

                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.circle_outlined, size: 16),

                        const SizedBox(width: 8),

                        Expanded(child: Text(uploadedIdCopy ?? 'ID Copy')),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.circle_outlined, size: 16),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            uploadedRegistration ?? 'Proof of Registration',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // UPLOAD BUTTONS
            Wrap(
              alignment: WrapAlignment.center,

              spacing: 10,

              runSpacing: 10,

              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _uploadDocument('id');
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                  ),

                  child: const Text(
                    'Upload ID Copy',

                    style: TextStyle(color: Colors.white),
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                    await _uploadDocument('registration');
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                  ),

                  child: const Text(
                    'Upload Registration',

                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  'Status Timeline',

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Row(
                  children: [
                    _timelineStep('1', 'Personal\nDetails', true),

                    const SizedBox(width: 20),

                    _timelineStep('2', 'Academic\nDetails', true),

                    const SizedBox(width: 20),

                    _timelineStep('3', 'Family\nInformation', true),

                    const SizedBox(width: 20),

                    _timelineStep('4', 'Upload\nDocuments', true),

                    const SizedBox(width: 20),

                    _timelineStep('5', 'Submitted', true),

                    const SizedBox(width: 20),

                    _timelineStep('6', 'Under\nReview', true),

                    const SizedBox(width: 20),

                    _timelineStep('7', 'Approved', false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _timelineStep(String number, String title, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,

          backgroundColor: active ? Colors.orange : Colors.grey.shade300,

          child: Text(
            number,

            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,

          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
