import '../../models/room_model.dart';
//import 'application_repository.dart';
//import '../repositories/mock_room_repository.dart';

abstract class RoomRepository {
  Future<List<RoomModel>> getRooms();

  Future<RoomModel?> getRoomById(String roomId);

  Future<List<RoomModel>> getFeaturedRooms();

  Future<List<RoomModel>> searchRooms(String query);
}
