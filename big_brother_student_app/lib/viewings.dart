import 'package:flutter/material.dart';
import 'home.dart';
import 'state.dart';
import 'ui.dart';

DateTime _d(dynamic v) => v is DateTime ? v : DateTime.tryParse('$v') ?? DateTime.now();

class ViewingsScreen extends StatelessWidget {
  const ViewingsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => PageShell(
          navIndex: 0,
          fab: FloatingActionButton(
              backgroundColor: const Color(0xFFF08E00),
              shape: const CircleBorder(),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookViewingScreen())),
              child: const Icon(Icons.add, size: 34, color: Colors.black87)),
          child: ListView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 90), children: [
            const Center(child: Text('Scheduled Viewings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
            const SizedBox(height: 22),
            if (app.viewings.isEmpty) const Padding(padding: EdgeInsets.only(top: 160), child: Center(child: Text('No viewings currently scheduled', style: TextStyle(fontSize: 18, color: Colors.grey)))),
            for (final v in app.viewings)
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewingDetailsScreen(v: v))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: kSand, borderRadius: BorderRadius.circular(20), boxShadow: cardShadow),
                  child: Column(children: [
                    Row(children: [
                      Expanded(child: Text('${v['room_type']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                      Pill.status('${v['booking_status']}'),
                      const Icon(Icons.chevron_right, color: Colors.black54),
                    ]),
                    const SizedBox(height: 18),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [const Icon(Icons.event, color: Colors.black54), const SizedBox(width: 10), Text(fmtShort(_d(v['booking_date'])), style: const TextStyle(fontSize: 17))]),
                      Row(children: [const Icon(Icons.schedule, color: Colors.black54), const SizedBox(width: 10), Text('${v['preferred_time']} / ${v['alternative_time']}', style: const TextStyle(fontSize: 17))]),
                    ]),
                  ]),
                ),
              ),
          ]),
        ),
      );
}

class BookViewingScreen extends StatefulWidget {
  final String? roomType;
  const BookViewingScreen({super.key, this.roomType});
  @override
  State<BookViewingScreen> createState() => _BookViewingState();
}

class _BookViewingState extends State<BookViewingScreen> {
  DateTime date = DateTime.now().add(const Duration(days: 1));
  String? pref, alt, type;
  static const times = ['08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM'];
  static const types = ['Single room (Females)', 'Single room (Males)', '1-Bedroom Apartment', '2-Bedroom Apartment', 'Single with Balcony'];
  @override
  void initState() {
    super.initState();
    type = widget.roomType != null && types.contains(widget.roomType) ? widget.roomType : null;
  }

  @override
  Widget build(BuildContext context) => PageShell(
        navIndex: 0,
        child: ListView(padding: const EdgeInsets.fromLTRB(22, 0, 22, 20), children: [
          const Center(child: Text('Book a Viewing', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
          const Center(child: Padding(padding: EdgeInsets.only(top: 6), child: Text('Choose a preferred date and time.', style: TextStyle(fontSize: 17, color: Colors.black54)))),
          const SizedBox(height: 8),
          CalendarDatePicker(
              initialDate: date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 120)),
              onDateChanged: (d) => date = d),
          Drop('Preferred time', 'Select time', Icons.schedule, pref, times, (v) => setState(() => pref = v)),
          const SizedBox(height: 16),
          Drop('Alternative time', 'Select time', Icons.schedule, alt, times, (v) => setState(() => alt = v)),
          const SizedBox(height: 16),
          Drop('Room type', 'Select room type', Icons.bed_outlined, type, types, (v) => setState(() => type = v)),
          const SizedBox(height: 26),
          OBtn('Submit', dark: true, onTap: () {
            if (pref == null || alt == null || type == null) return toast(context, 'Please choose both times and a room type.');
            if (pref == alt) return toast(context, 'Alternative time must differ from the preferred time.');
            Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailsScreen(v: {'date': date, 'preferred_time': pref, 'alternative_time': alt, 'room_type': type})));
          }),
        ]),
      );
}

class BookingDetailsScreen extends StatefulWidget {
  final M v;
  const BookingDetailsScreen({super.key, required this.v});
  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetailsScreen> {
  bool busy = false;
  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 17, color: Colors.black54)), Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))]));
  Widget _box(IconData i, String t, List<Widget> kids) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(i), const SizedBox(width: 10), Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))]),
          const Divider(),
          ...kids,
        ]),
      );
  @override
  Widget build(BuildContext context) {
    final v = widget.v;
    return PageShell(
      navIndex: 0,
      child: ListView(padding: const EdgeInsets.fromLTRB(22, 0, 22, 20), children: [
        const Center(child: Text('Booking Details', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
        const Center(child: Padding(padding: EdgeInsets.only(top: 4, bottom: 14), child: Text('Review your details before confirming.', style: TextStyle(fontSize: 17, color: Colors.black54)))),
        _box(Icons.event, 'Viewing Details', [
          _row('Date', fmtLong(v['date'] as DateTime)),
          _row('Preferred time', '${v['preferred_time']}'),
          _row('Alternative time', '${v['alternative_time']}'),
          _row('Room type', '${v['room_type']}'),
        ]),
        _box(Icons.person_outline, 'Your Details', [
          _row('Full name', '${app.user['name'] ?? ''}'),
          _row('Contact number', '${app.user['phone'] ?? ''}'),
          _row('Email Address', '${app.user['email'] ?? ''}'),
        ]),
        const Row(children: [Icon(Icons.info_outline, size: 18, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text('Your viewing has not been booked yet.\nConfirm below to submit your request.', style: TextStyle(color: Colors.grey)))]),
        const SizedBox(height: 14),
        Center(child: SizedBox(width: 280, child: OBtn('Confirm', dark: true, loading: busy, onTap: () async {
          setState(() => busy = true);
          final ref = await app.bookViewing(v);
          if (!mounted) return;
          setState(() => busy = false);
          if (ref == null) return toast(context, 'Could not submit your viewing request.');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ViewingSubmittedScreen(ref: ref)));
        }))),
        const SizedBox(height: 12),
        Center(child: SizedBox(width: 280, child: OBtn('Edit Viewing Details', outline: true, dark: true, icon: Icons.edit_outlined, onTap: () => Navigator.pop(context)))),
      ]),
    );
  }
}

class ViewingSubmittedScreen extends StatelessWidget {
  final String ref;
  const ViewingSubmittedScreen({super.key, required this.ref});
  @override
  Widget build(BuildContext context) => PageShell(
        navIndex: 0,
        child: ListView(padding: const EdgeInsets.fromLTRB(28, 0, 28, 20), children: [
          const Center(child: Text('Viewing Request\nSubmitted', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800))),
          const SizedBox(height: 30),
          const Center(child: SuccessCheck()),
          const SizedBox(height: 40),
          RefBox(ref, 'Keep this code for your records.'),
          const SizedBox(height: 60),
          Center(child: SizedBox(width: 280, child: OBtn('Back to Home', dark: true, onTap: () => goTab(context, 0)))),
          const SizedBox(height: 12),
          Center(child: SizedBox(width: 280, child: OBtn('Go to Viewings', outline: true, dark: true, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ViewingsScreen()))))),
        ]),
      );
}

class ViewingDetailsScreen extends StatelessWidget {
  final M v;
  const ViewingDetailsScreen({super.key, required this.v});
  @override
  Widget build(BuildContext context) {
    final status = '${v['booking_status']}';
    final ok = status.toLowerCase().contains('approv') || status.toLowerCase().contains('confirm');
    final room = app.rooms.firstWhere((r) => r['room_type'] == v['room_type'], orElse: () => {'images': [], 'price': 4500});
    return PageShell(
      navIndex: 0,
      child: ListView(padding: const EdgeInsets.fromLTRB(22, 0, 22, 20), children: [
        const Center(child: Text('Viewing Details', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(26)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ((room['images'] as List).isNotEmpty)
                ? RoomImg(room, w: double.infinity, h: 170, r: 16)
                : Container(height: 170, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFF8F7F5), border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(16)), child: const Text('Room image(s)', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 14),
            Pill(status, ok ? Colors.white : kOrange, ok ? const Color(0xFF3F8F3F) : kPeach),
            const SizedBox(height: 14),
            Row(children: [Text('${v['room_type']}', style: const TextStyle(fontSize: 19)), const SizedBox(width: 24), Text('${money(room['price'])} p/m', style: const TextStyle(fontSize: 19))]),
            const Padding(padding: EdgeInsets.fromLTRB(14, 8, 0, 0), child: Text('Universitas, Bloemfontein', style: TextStyle(color: Colors.grey, fontSize: 17))),
            const SizedBox(height: 24),
            Row(children: [const Icon(Icons.event, size: 30, color: Colors.black54), const SizedBox(width: 12), Text(fmtFull(_d(v['booking_date'])), style: const TextStyle(fontSize: 18))]),
            const SizedBox(height: 10),
            Row(children: [const Icon(Icons.schedule, size: 30, color: Colors.black54), const SizedBox(width: 12), Text('${v['preferred_time']} / ${v['alternative_time']}', style: const TextStyle(fontSize: 18))]),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kPeach, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ok ? 'Confirmed' : 'Awaiting Confirmation', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                Text(ok ? 'Management has confirmed your viewing. See you there!' : 'Your viewing request has been submitted. We will notify you when the residence confirms.', style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
