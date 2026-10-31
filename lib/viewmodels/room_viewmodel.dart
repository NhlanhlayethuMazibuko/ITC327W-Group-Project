import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import 'package:bigbrother/repositories/mock_room_repository.dart';

class RoomViewModel extends ChangeNotifier {
  final MockRoomRepository _repository = MockRoomRepository();

  List<RoomModel> rooms = [];

  bool isLoading = false;

  Future<void> loadRooms() async {
    isLoading = true;
    notifyListeners();

    rooms = await _repository.getRooms();

    isLoading = false;
    notifyListeners();
  }
}
