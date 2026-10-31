import 'package:flutter/material.dart';

import '../models/room_model.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),

      child: ListTile(
        title: Text(room.roomName),

        subtitle: Text('R ${room.price}'),

        trailing: Icon(
          room.availabilityStatus ? Icons.check_circle : Icons.cancel,

          color: room.availabilityStatus ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
