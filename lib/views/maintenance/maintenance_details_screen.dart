import 'package:flutter/material.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Request')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Category',

              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const Text('Plumbing'),

            const SizedBox(height: 20),

            const Text(
              'Priority',

              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const Text('High'),

            const SizedBox(height: 20),

            const Text(
              'Description',

              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const Text('Bathroom tap leaking continuously.'),

            const SizedBox(height: 20),

            Chip(
              backgroundColor: Colors.orange.shade100,

              label: const Text('Pending'),
            ),
          ],
        ),
      ),
    );
  }
}
