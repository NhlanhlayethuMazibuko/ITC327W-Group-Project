import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/room.dart';
import '../services/room_service.dart';

class RoomImage extends StatelessWidget {
  const RoomImage({
    super.key,
    required this.room,
    this.width,
    this.height,
    this.radius = 8,
  });

  final Room room;
  final double? width, height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // Local asset fallback images
    final assetImage = room.type.toLowerCase().contains('single')
        ? 'assets/rooms/bedroom6.jpg'
            'assets/rooms/'
        : 'assets/rooms/bedroom3.jpg';

    if (room.imagePaths.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          RoomService.imageUrl(room.imagePaths.first),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            assetImage,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        assetImage,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}

class AvailabilityChip extends StatelessWidget {
  const AvailabilityChip({super.key, required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: available ? const Color(0xFFC8F7D0) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          available ? 'Available' : 'Unavailable',
          style: TextStyle(
            fontSize: 9,
            color: available ? const Color(0xFF1B7F3A) : AppColors.muted,
          ),
        ),
      );
}

class RoomListCard extends StatelessWidget {
  const RoomListCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  final Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          RoomImage(
            room: room,
            width: 72,
            height: 84,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  room.type,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  room.priceLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AvailabilityChip(
                      available: room.available,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 26,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(fontSize: 10),
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
    );
  }
}

class FeaturedRoomCard extends StatelessWidget {
  const FeaturedRoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  final Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoomImage(
              room: room,
              width: double.infinity,
              height: 80,
            ),
            const SizedBox(height: 6),
            Text(
              room.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            Text(
              room.type,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.muted,
              ),
            ),
            Text(
              room.priceLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            const Spacer(),
            AvailabilityChip(
              available: room.available,
            ),
          ],
        ),
      ),
    );
  }
}
