import '../../models/room_model.dart';
import 'room_repository.dart';

class MockRoomRepository implements RoomRepository {
  @override
  Future<List<RoomModel>> getRooms() async {
    return [
      RoomModel(
        roomId: '1',
        roomName: 'Single Room',
        roomType: 'Single',
        price: 4500,
        capacity: 1,
        availabilityStatus: true,
        wifi: true,
        laundry: true,
        security: true,
        shuttle: true,
        furniture: true,
        description: 'Fully furnished single room.',
      ),
      RoomModel(
        roomId: '2',
        roomName: 'Sharing Room',
        roomType: 'Sharing',
        price: 3500,
        capacity: 2,
        availabilityStatus: true,
        wifi: true,
        laundry: true,
        security: true,
        shuttle: false,
        furniture: true,
        description: 'Affordable sharing room.',
      ),
    ];
  }

  @override
  Future<RoomModel?> getRoomById(String roomId) async {
    final rooms = await getRooms();

    try {
      return rooms.firstWhere((room) => room.roomId == roomId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RoomModel>> getFeaturedRooms() async {
    return await getRooms();
  }

  @override
  Future<List<RoomModel>> searchRooms(String query) async {
    final rooms = await getRooms();

    return rooms
        .where(
          (room) => room.roomName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
