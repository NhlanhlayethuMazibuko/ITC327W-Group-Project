import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewMaintenanceRequestScreen extends StatefulWidget {
  const NewMaintenanceRequestScreen({super.key});

  @override
  State<NewMaintenanceRequestScreen> createState() =>
      _NewMaintenanceRequestScreenState();
}

class _NewMaintenanceRequestScreenState
    extends State<NewMaintenanceRequestScreen> {
  String? attachment;

  String? category;
  String? priority;
  String? type;

  final TextEditingController descriptionController = TextEditingController();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        attachment = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                            context.pop('/maintenance-requests');
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
                'New Maintenance Request',

                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category'),

                      items: const [
                        DropdownMenuItem(
                          value: 'Plumbing',
                          child: Text('Plumbing'),
                        ),

                        DropdownMenuItem(
                          value: 'Electrical',
                          child: Text('Electrical'),
                        ),
                      ],

                      onChanged: (value) {
                        category = value;
                      },
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: descriptionController,

                      maxLines: 4,

                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    OutlinedButton(
                      onPressed: _pickFile,

                      child: Text(attachment ?? 'Upload Photo'),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              context.pop();
                            },

                            child: const Text('Cancel'),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              /*
                              FUTURE SUPABASE

                              Save request

                              */

                              context.pop();
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
