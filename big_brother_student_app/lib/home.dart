import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show UserAttributes;
import 'application.dart';
import 'auth.dart';
import 'maintenance.dart';
import 'notifications.dart';
import 'payment.dart';
import 'state.dart';
import 'ui.dart';
import 'viewings.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: tabNotifier,
        builder: (_, i, __) => Scaffold(
          body: IndexedStack(index: i, children: const [HomePage(), RoomsPage(), ApplicationPage(), ProfilePage()]),
          bottomNavigationBar: AppNav(selected: i, onTap: (v) => tabNotifier.value = v),
        ),
      );
}

void openRoom(BuildContext c, M room) => Navigator.push(c, MaterialPageRoute(builder: (_) => RoomDetailsScreen(room: room)));

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  Widget _quick(IconData i, String t, VoidCallback f) => Expanded(
        child: GestureDetector(
          onTap: f,
          child: Container(
            height: 112,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: cardShadow),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 28, backgroundColor: const Color(0xFFFBB75D), child: Icon(i, size: 30, color: Colors.black87)),
              const SizedBox(height: 8),
              Text(t, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final search = TextEditingController();
          return Scaffold(
            backgroundColor: Colors.white,
            body: ListView(padding: EdgeInsets.zero, children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 175,
                  color: kOrangeTop,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 14, 0),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        GestureDetector(onTap: () => tabNotifier.value = 3, child: const Icon(Icons.account_circle_outlined, size: 44)),
                        const SizedBox(width: 10),
                        Expanded(child: Padding(padding: const EdgeInsets.only(top: 2), child: Text('Hello, ${app.firstName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)))),
                        const Logo(w: 120, onOrange: true),
                      ]),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) { app.roomQuery = v.trim(); app.refresh(); tabNotifier.value = 1; },
                    decoration: InputDecoration(
                      hintText: 'Search for rooms',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: const BorderSide(color: Colors.black26)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(40), borderSide: const BorderSide(color: Colors.black26)),
                    ),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 12), child: Text('Quick Actions', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  _quick(Icons.home_outlined, 'View\nAccommodation', () => tabNotifier.value = 1),
                  _quick(Icons.description_outlined, 'My\nApplications', () => tabNotifier.value = 2),
                  _quick(Icons.assignment_turned_in_outlined, 'Scheduled\nViewings', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewingsScreen()))),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Featured units', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  GestureDetector(onTap: () { app.roomQuery = ''; tabNotifier.value = 1; }, child: const Text('See All', style: TextStyle(color: kOrange, fontWeight: FontWeight.w800, fontSize: 20))),
                ]),
              ),
              SizedBox(
                height: 215,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: [
                    for (final r in app.rooms.take(6))
                      GestureDetector(
                        onTap: () => openRoom(context, r),
                        child: Container(
                          width: 270,
                          margin: const EdgeInsets.fromLTRB(6, 4, 6, 10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: cardShadow),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)), child: RoomImg(r, w: 270, h: 78, r: 0)),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('${r['room_name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                                Text('${r['room_type']}', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                                Text('${money(r['price'])}/Month', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                const SizedBox(height: 6),
                                AvailPill(r['availability_status'] == true),
                              ]),
                            ),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(20, 14, 20, 10), child: Text('Latest Announcements', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
              for (final a in app.announcements.take(3))
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFFFFBC4), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.campaign, color: kOrange, size: 44),
                      const SizedBox(width: 12),
                      Expanded(child: Text.rich(TextSpan(children: [
                        TextSpan(text: '${a['title']}\n', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                        TextSpan(text: '${a['message'] ?? ''}', style: const TextStyle(fontSize: 18)),
                      ]))),
                    ]),
                  ),
                ),
              const SizedBox(height: 16),
            ]),
          );
        },
      );
}

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final q = app.roomQuery.toLowerCase();
          final list = app.rooms.where((r) => q.isEmpty || '${r['room_name']} ${r['room_type']} ${r['price']}'.toLowerCase().contains(q)).toList();
          return SheetPage(
            title: 'Available Rooms',
            back: false,
            child: ListView(padding: const EdgeInsets.all(18), children: [
              const Text('Choose the Perfect  room to suit your lifestyle and budget', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              if (q.isNotEmpty)
                Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(top: 8), child: InputChip(label: Text('Search: ${app.roomQuery}'), onDeleted: () { app.roomQuery = ''; app.refresh(); }))),
              const SizedBox(height: 22),
              if (list.isEmpty) const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No rooms match your search.', style: TextStyle(color: Colors.grey)))),
              for (final r in list)
                Container(
                  margin: const EdgeInsets.only(bottom: 22),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: cardShadow),
                  child: Row(children: [
                    RoomImg(r, w: 96, h: 112),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r['room_name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        Text('${r['room_type']}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                        Text('${money(r['price'])}/Month', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                        const SizedBox(height: 4),
                        AvailPill(r['availability_status'] == true),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => openRoom(context, r),
                            style: ElevatedButton.styleFrom(backgroundColor: kOrange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
            ]),
          );
        },
      );
}

class RoomDetailsScreen extends StatefulWidget {
  final M room;
  const RoomDetailsScreen({super.key, required this.room});
  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetailsScreen> {
  final pc = PageController();
  int page = 0;
  @override
  Widget build(BuildContext context) {
    final r = widget.room;
    final imgs = (r['images'] as List?) ?? [];
    final n = imgs.isEmpty ? 5 : imgs.length;
    Widget amen(String label, IconData i, String key) => (r[key] == false)
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Column(children: [
              CircleAvatar(radius: 28, backgroundColor: const Color(0xFFD9D9D9), child: Icon(i, size: 30, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ]));
    return SheetPage(
      title: 'Unit details',
      child: ListView(padding: const EdgeInsets.all(18), children: [
        SizedBox(
          height: 220,
          child: Stack(alignment: Alignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: PageView.builder(
                controller: pc,
                itemCount: n,
                onPageChanged: (i) => setState(() => page = i),
                itemBuilder: (_, i) => imgs.isEmpty ? Container(color: const Color(0xFFD9D9D9)) : Image.network(imgs[i] as String, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Positioned(left: 8, child: _arrow(Icons.chevron_left, () => pc.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut))),
            Positioned(right: 8, child: _arrow(Icons.chevron_right, () => pc.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut))),
            Positioned(bottom: 14, child: Row(children: [for (var i = 0; i < n; i++) Container(width: 10, height: 10, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(shape: BoxShape.circle, color: i == page ? Colors.white : Colors.white54))])),
          ]),
        ),
        const SizedBox(height: 28),
        Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${r['room_name']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            Text('${r['room_type']}', style: const TextStyle(color: Colors.grey, fontSize: 17)),
            const SizedBox(height: 4),
            Text('${money(r['price'])}/Month', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          ]),
          AvailPill(r['availability_status'] == true),
        ]),
        const SizedBox(height: 18),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          amen('Wi-fi', Icons.wifi, 'wifi'),
          amen('Laundry', Icons.local_laundry_service_outlined, 'laundry'),
          amen('Security', Icons.verified_user_outlined, 'security'),
          amen('Shuttle', Icons.directions_bus, 'shuttle'),
          amen('Furniture', Icons.chair_outlined, 'furniture'),
        ])),
        const SizedBox(height: 26),
        const Text('Description', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('${r['description'] ?? ''}', style: const TextStyle(fontSize: 17)),
        const SizedBox(height: 26),
        OBtn('Apply Now', onTap: r['availability_status'] == true
            ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicationFormScreen(room: r)))
            : null),
        const SizedBox(height: 12),
        OBtn('Book a Viewing', outline: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookViewingScreen(roomType: '${r['room_type']}')))),
      ]),
    );
  }

  Widget _arrow(IconData i, VoidCallback f) => GestureDetector(onTap: f, child: CircleAvatar(radius: 26, backgroundColor: const Color(0xFF444444), child: Icon(i, color: Colors.white, size: 32)));
}


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _changePw(BuildContext c) {
    final a = TextEditingController();
    showDialog(
        context: c,
        builder: (d) => AlertDialog(
              title: const Text('Change password'),
              content: TextField(controller: a, obscureText: true, decoration: const InputDecoration(hintText: 'New password (min 8 characters)')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      if (a.text.length < 8) return toast(c, 'Password must be at least 8 characters.');
                      Navigator.pop(d);
                      try { await app.sb?.auth.updateUser(UserAttributes(password: a.text)); if (c.mounted) toast(c, 'Password updated.'); } catch (_) { if (c.mounted) toast(c, 'Could not update password.'); }
                    },
                    child: const Text('Save')),
              ],
            ));
  }

  Widget _link(IconData i, String t, VoidCallback f) => ListTile(leading: Icon(i, size: 30), title: Text(t), onTap: f, contentPadding: const EdgeInsets.symmetric(horizontal: 0));

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            WaveHeader(height: 170, back: true, child: const Logo(w: 220, onOrange: true)),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: [
                Row(children: [
                  const CircleAvatar(radius: 46, backgroundColor: Color(0xFF222222), child: Icon(Icons.person, size: 54, color: Colors.white)),
                  const SizedBox(width: 20),
                  Expanded(child: Text('${app.user['name'] ?? ''}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 40),
                InfoCard(Icons.mail_outline, 'Email Address', '${app.user['email'] ?? ''}'),
                InfoCard(Icons.phone_outlined, 'Phone Number', '${(app.user['phone'] ?? '').toString().isEmpty ? '—' : app.user['phone']}'),
                InfoCard(Icons.school_outlined, 'Student number', '${app.user['student_number'] ?? ''}'),
                const SizedBox(height: 8),
                _link(Icons.lock_outline, 'Change password', () => _changePw(context)),
                _link(Icons.notifications_none, 'Notifications', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                _link(Icons.build_outlined, 'Maintenance requests', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceListScreen()))),
                _link(Icons.payments_outlined, 'Payment', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()))),
                _link(Icons.logout, 'Log out', () async {
                  await app.logout();
                  if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
                }),
              ]),
            ),
          ]),
        ),
      );
}
