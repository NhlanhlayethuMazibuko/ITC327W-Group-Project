import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_text.dart';
import '../../models/app_notification.dart';
import '../../models/room.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/room_service.dart';
import '../../services/student_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_message.dart';
import '../../widgets/room_widgets.dart';
import '../accommodation/unit_details_screen.dart';
import '../maintenance/maintenance_screens.dart';
import '../notifications/notifications_screen.dart';
import '../viewings/viewing_screens.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onSearch, required this.onSeeAll, required this.onOpenApplications});
  final ValueChanged<String> onSearch;
  final VoidCallback onSeeAll;
  final VoidCallback onOpenApplications;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _search = TextEditingController();
  bool _loading = true;
  String? _name, _error;
  List<Room> _featured = [];
  AppNotification? _latest;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final student = await StudentService().currentStudent();
    final note = student == null ? null : await NotificationService().latest(student.id);
    List<Room> rooms = [];
    String? error;
    try {
      rooms = await RoomService().fetchRooms(featuredOnly: true);
    } catch (e) {
      error = friendlyError(e);
    }
    if (!mounted) return;
    setState(() {
      _name = student?.fullName;
      _featured = rooms;
      _latest = note;
      _error = error;
      _loading = false;
    });
  }

  String get _firstName {
    final full = (_name?.isNotEmpty ?? false)
        ? _name!
        : (AuthService().currentUser?.userMetadata?['full_name'] as String? ?? 'Student');
    return full.trim().split(' ').first;
  }

  void _go(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  Widget _action(IconData icon, String label, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Column(children: [
              CircleAvatar(radius: 18, backgroundColor: const Color(0xFFFFE0B2), child: Icon(icon, size: 18, color: AppColors.orangeDark)),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9)),
            ]),
          ),
        ),
      );

  Widget _header() => SizedBox(
        height: 190,
        child: Stack(children: [
          ClipPath(clipper: WaveClipper(), child: Container(height: 160, color: AppColors.orange)),
          Positioned(
            top: 0, left: 16, right: 16,
            child: SafeArea(
              child: Row(children: [
                const Icon(Icons.account_circle_outlined, size: 26),
                const SizedBox(width: 8),
                Expanded(child: Text('Hello, $_firstName', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                const BrandLogo(height: 34, onOrange: true),
              ]),
            ),
          ),
          Positioned(
            left: 16, right: 16, bottom: 0,
            child: Material(
              elevation: 2, borderRadius: BorderRadius.circular(24),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSearch,
                decoration: InputDecoration(
                  hintText: 'Search for rooms',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ]),
      );

  Widget _featuredSection() {
    if (_loading) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppColors.orange)));
    if (_error != null) {
      return Column(children: [ErrorMessage(_error), SizedBox(width: 160, child: AppButton(label: 'Try again', onPressed: _load))]);
    }
    if (_featured.isEmpty) return const EmptyState(icon: Icons.bed_outlined, message: 'No featured units right now.');
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _featured.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => FeaturedRoomCard(
          room: _featured[i],
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => UnitDetailsScreen(room: _featured[i]))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.orange,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Row(children: [
                _action(Icons.build_outlined, 'Maintenance\nRequests', () => _go(const MaintenanceListScreen())),
                _action(Icons.description_outlined, 'My\nApplications', widget.onOpenApplications),
                _action(Icons.event_outlined, 'Scheduled\nViewings', () => _go(const ViewingsScreen())),
              ]),
              const SizedBox(height: 18),
              Row(children: [
                const Text('Featured units', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const Spacer(),
                GestureDetector(onTap: widget.onSeeAll, child: const Text('See All', style: TextStyle(color: AppColors.orange, fontSize: 11))),
              ]),
              const SizedBox(height: 8),
              _featuredSection(),
              const SizedBox(height: 18),
              Row(children: [
                const Text('Latest Notifications', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const Spacer(),
                GestureDetector(onTap: () => _go(const NotificationsScreen()), child: const Text('See All', style: TextStyle(color: AppColors.orange, fontSize: 11))),
              ]),
              const SizedBox(height: 8),
              if (_latest == null)
                const EmptyState(icon: Icons.notifications_none, message: 'No notifications yet.')
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(8)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_latest!.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(_latest!.message, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}
