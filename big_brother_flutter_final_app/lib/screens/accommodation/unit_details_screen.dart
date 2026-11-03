import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/room.dart';
import '../../widgets/app_button.dart';
import '../../widgets/inner_scaffold.dart';
import '../../widgets/room_widgets.dart';
import '../../widgets/local_room_images.dart';
import '../applications/application_form_screen.dart';

class UnitDetailsScreen extends StatefulWidget {
  const UnitDetailsScreen({super.key, required this.room});
  final Room room;

  @override
  State<UnitDetailsScreen> createState() => _UnitDetailsScreenState();
}

class _UnitDetailsScreenState extends State<UnitDetailsScreen> {
  int _page = 0;

  Widget _amenity(IconData icon, String label, bool on) => Column(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: on ? const Color(0xFFE3EAFB) : AppColors.background,
          child: Icon(icon, size: 18, color: on ? const Color(0xFF3F51B5) : AppColors.border),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: on ? AppColors.text : AppColors.muted)),
      ]);

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final paths = room.imagePaths;
    return InnerScaffold(
      title: 'Unit details',
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: AppButton(
          label: 'Apply Now',
          onPressed: room.available
              ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ApplicationFormScreen(room: room)))
              : null,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Builder(builder: (context) {
            // Slideshow of this unit's photos (bedroom first, then kitchen,
            // bathroom and outside views). Falls back to a bundled bedroom
            // photo if the room has no images at all.
            final List<String> gallery =
                paths.isNotEmpty ? paths : <String>[LocalRoomImages.pick(room.id)];
            final int count = gallery.length;
            return SizedBox(
              height: 160,
              child: Stack(alignment: Alignment.bottomCenter, children: [
                PageView.builder(
                  itemCount: count,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LocalRoomImages.smart(
                        gallery[i], width: double.infinity, height: 160,
                        fallbackAsset: LocalRoomImages.pick(room.id)),
                  ),
                ),
                if (count > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(count, (i) => Container(
                      width: 6, height: 6, margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: i == _page ? Colors.white : Colors.white54),
                    ))),
                  ),
              ]),
            );
          }),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
            AvailabilityChip(available: room.available),
          ]),
          Text(room.type, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text(room.priceLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _amenity(Icons.wifi, 'Wi-fi', room.wifi),
            _amenity(Icons.local_laundry_service_outlined, 'Laundry', room.laundry),
            _amenity(Icons.shield_outlined, 'Security', room.security),
            _amenity(Icons.directions_bus_outlined, 'Shuttle', room.shuttle),
            _amenity(Icons.chair_outlined, 'Furniture', room.furniture),
          ]),
          const SizedBox(height: 18),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text(room.description.isEmpty ? 'No description provided.' : room.description, style: const TextStyle(fontSize: 11)),
        ]),
      ),
    );
  }
}
