class RoomModel {
  final String roomId;

  final String roomName;

  final String roomType;

  final double price;

  final int capacity;

  final bool availabilityStatus;

  final bool wifi;

  final bool laundry;

  final bool security;

  final bool shuttle;

  final bool furniture;

  final String description;

  RoomModel({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.price,
    required this.capacity,
    required this.availabilityStatus,
    required this.wifi,
    required this.laundry,
    required this.security,
    required this.shuttle,
    required this.furniture,
    required this.description,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId'],
      roomName: json['roomName'],
      roomType: json['roomType'],
      price: json['price'],
      capacity: json['capacity'],
      availabilityStatus: json['availabilityStatus'],
      wifi: json['wifi'],
      laundry: json['laundry'],
      security: json['security'],
      shuttle: json['shuttle'],
      furniture: json['furniture'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'roomType': roomType,
      'price': price,
      'capacity': capacity,
      'availabilityStatus': availabilityStatus,
      'wifi': wifi,
      'laundry': laundry,
      'security': security,
      'shuttle': shuttle,
      'furniture': furniture,
      'description': description,
    };
  }

  RoomModel copyWith({
    String? roomId,
    String? roomName,
    String? roomType,
    double? price,
    int? capacity,
    bool? availabilityStatus,
    bool? wifi,
    bool? laundry,
    bool? security,
    bool? shuttle,
    bool? furniture,
    String? description,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      roomType: roomType ?? this.roomType,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      wifi: wifi ?? this.wifi,
      laundry: laundry ?? this.laundry,
      security: security ?? this.security,
      shuttle: shuttle ?? this.shuttle,
      furniture: furniture ?? this.furniture,
      description: description ?? this.description,
    );
  }
}
