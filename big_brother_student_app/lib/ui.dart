import 'package:flutter/material.dart';

const kOrange = Color(0xFFFF8C00);
const kOrangeTop = Color(0xFFFF9800);
const kPeach = Color(0xFFFAE6CD);
const kSand = Color(0xFFFFE8C8);
const kMaroon = Color(0xFF9B2D30);
const kGrey = Color(0xFFF1F1F1);
const kGreenBg = Color(0xFFB9F6CA);
const kGreen = Color(0xFF1B7F3B);

final tabNotifier = ValueNotifier<int>(0);
void goTab(BuildContext c, int i) {
  tabNotifier.value = i;
  Navigator.of(c).popUntil((r) => r.isFirst);
}

void toast(BuildContext c, String m) => ScaffoldMessenger.of(c)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(m)));

const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _day = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _dayFull = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
String fmtLong(DateTime d) => '${_day[d.weekday - 1]}, ${d.day} ${_mon[d.month - 1]} ${d.year}';
String fmtShort(DateTime d) => '${_day[d.weekday - 1]}, ${d.day} ${_mon[d.month - 1]}';
String fmtFull(DateTime d) => '${_dayFull[d.weekday - 1]}, ${d.day} ${['January','February','March','April','May','June','July','August','September','October','November','December'][d.month - 1]} ${d.year}';
String fmtDMY(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year % 100}';
String fmtMd(DateTime d) => '${d.day}-${_mon[d.month - 1]}-${d.year % 100}';
String ymd(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String money(num n) =>
    'R${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

const cardShadow = [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))];

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path()..lineTo(0, s.height - 30);
    p.quadraticBezierTo(s.width * .25, s.height + 10, s.width * .55, s.height - 22);
    p.quadraticBezierTo(s.width * .82, s.height - 48, s.width, s.height - 80);
    p.lineTo(s.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}

class Logo extends StatelessWidget {
  final double w;
  final bool onOrange;
  const Logo({super.key, this.w = 260, this.onOrange = false});
  @override
  Widget build(BuildContext context) => Image.asset('assets/logo.png',
      width: w,
      errorBuilder: (_, __, ___) => Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.home_work_rounded, size: w * .3, color: onOrange ? Colors.black87 : kOrange),
            Text('BIG BROTHER STUDENT',
                style: TextStyle(color: kMaroon, fontWeight: FontWeight.w900, fontSize: w * .072, letterSpacing: 1)),
            Text('A C C O M M O D A T I O N S',
                style: TextStyle(color: const Color(0xFFD9893F), fontSize: w * .045)),
          ]));
}

class WaveHeader extends StatelessWidget {
  final double height;
  final bool back;
  final Widget? child;
  const WaveHeader({super.key, this.height = 200, this.back = false, this.child});
  @override
  Widget build(BuildContext context) => ClipPath(
        clipper: WaveClipper(),
        child: Container(
          height: height,
          width: double.infinity,
          color: kOrangeTop,
          child: SafeArea(
            bottom: false,
            child: Stack(children: [
              if (back)
                Positioned(
                    left: 6,
                    top: 4,
                    child: IconButton(
                        icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context))),
              Align(
                  alignment: const Alignment(0, -.1),
                  child: child ?? Logo(w: height < 190 ? 220 : 270, onOrange: true)),
            ]),
          ),
        ),
      );
}

class Tagline extends StatelessWidget {
  const Tagline({super.key});
  @override
  Widget build(BuildContext context) => Container(
        height: 90,
        width: double.infinity,
        decoration: const BoxDecoration(
            color: kGrey, borderRadius: BorderRadius.vertical(top: Radius.elliptical(500, 40))),
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Your home away from home',
              style: TextStyle(fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, fontSize: 15)),
          const SizedBox(height: 4),
          Container(width: 140, height: 2, color: kOrange),
        ])),
      );
}

/// Wave header + scrolling body + tagline (auth screens)
class AuthShell extends StatelessWidget {
  final Widget child;
  final bool back;
  final double headerHeight;
  const AuthShell({super.key, required this.child, this.back = false, this.headerHeight = 200});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          WaveHeader(height: headerHeight, back: back),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 28), child: child)),
          const Tagline(),
        ]),
      );
}

/// Wave header + body + bottom nav (in-app pages)
class PageShell extends StatelessWidget {
  final Widget child;
  final int navIndex;
  final Widget? fab;
  final bool back;
  const PageShell({super.key, required this.child, this.navIndex = 0, this.fab, this.back = true});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: fab,
        bottomNavigationBar: AppNav(selected: navIndex),
        body: Column(children: [
          WaveHeader(height: 170, back: back),
          Expanded(child: child),
        ]),
      );
}

/// Solid orange title bar with white rounded sheet (rooms screens)
class SheetPage extends StatelessWidget {
  final String title;
  final Widget child;
  final int navIndex;
  final bool back;
  const SheetPage({super.key, required this.title, required this.child, this.navIndex = 1, this.back = true});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kOrangeTop,
        bottomNavigationBar: AppNav(selected: navIndex, onTap: back ? null : (i) => tabNotifier.value = i),
        body: Column(children: [
          SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                child: Row(children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => back ? Navigator.maybePop(context) : tabNotifier.value = 0),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                ]),
              )),
          Expanded(
              child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                  child: child)),
        ]),
      );
}

class AppNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int>? onTap;
  const AppNav({super.key, required this.selected, this.onTap});
  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.bed, 'Rooms\nAvailable'),
    (Icons.description_outlined, 'Application'),
    (Icons.person_outline, 'Profile'),
  ];
  @override
  Widget build(BuildContext context) => Container(
        color: kGrey,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              for (var i = 0; i < 4; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => (onTap ?? (v) => goTab(context, v))(i),
                  child: SizedBox(
                    width: 80,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(_items[i].$1, size: 30, color: i == selected ? kOrange : Colors.black87),
                      Text(_items[i].$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: i == selected ? kOrange : Colors.black87)),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      );
}

class OBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool outline;
  final bool loading;
  final IconData? icon;
  final bool dark;
  const OBtn(this.text, {super.key, this.onTap, this.outline = false, this.loading = false, this.icon, this.dark = false});
  @override
  Widget build(BuildContext context) {
    final label = loading
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            if (icon != null) ...[const SizedBox(width: 10), Icon(icon, size: 22)],
          ]);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: outline
          ? OutlinedButton(
              onPressed: loading ? null : onTap,
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kOrange, width: 2),
                  shape: const StadiumBorder(),
                  foregroundColor: dark ? Colors.black : kOrange),
              child: label)
          : ElevatedButton(
              onPressed: loading ? null : onTap,
              style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: dark ? Colors.black : Colors.white,
                  elevation: 3,
                  shape: const StadiumBorder()),
              child: label),
    );
  }
}

class Field extends StatefulWidget {
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscure;
  final String? label;
  final String? error;
  final TextInputType? keyboard;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;
  const Field(this.hint, this.icon,
      {super.key, this.controller, this.obscure = false, this.label, this.error, this.keyboard, this.readOnly = false, this.onTap, this.maxLines = 1, this.onSubmitted});
  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  bool hide = true;
  @override
  Widget build(BuildContext context) {
    final err = widget.error != null;
    final bc = err ? Colors.red : Colors.black26;
    OutlineInputBorder b(Color c) => OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c));
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscure && hide,
      keyboardType: widget.keyboard,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      onSubmitted: widget.onSubmitted,
      style: TextStyle(color: err ? Colors.red : Colors.black87),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: widget.label != null ? FloatingLabelBehavior.always : null,
        hintText: widget.hint,
        errorText: widget.error,
        prefixIcon: Icon(widget.icon, color: err ? Colors.red : Colors.black87, size: 30),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: err ? Colors.red : Colors.black87),
                onPressed: () => setState(() => hide = !hide))
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        border: b(bc),
        enabledBorder: b(bc),
        focusedBorder: b(kOrange),
        errorBorder: b(Colors.red),
        focusedErrorBorder: b(Colors.red),
      ),
    );
  }
}

class Drop extends StatelessWidget {
  final String label, hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const Drop(this.label, this.hint, this.icon, this.value, this.items, this.onChanged, {super.key});
  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c));
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black87, size: 28),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: b(Colors.black26),
        enabledBorder: b(Colors.black26),
        focusedBorder: b(kOrange),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color fg, bg;
  const Pill(this.text, this.fg, this.bg, {super.key});
  factory Pill.status(String s) {
    final t = s.toLowerCase();
    if (t.contains('approv') || t.contains('confirm') || t.contains('complete') || t == 'available') return Pill(s, Colors.white, const Color(0xFF3F8F3F));
    if (t.contains('reject') || t.contains('declin') || t.contains('occupied')) return Pill(s, Colors.white, Colors.red);
    return Pill(s, Colors.white, kOrange);
  }
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 13)),
      );
}

class AvailPill extends StatelessWidget {
  final bool available;
  const AvailPill(this.available, {super.key});
  @override
  Widget build(BuildContext context) => available
      ? const Pill('Available', kGreen, kGreenBg)
      : const Pill('Occupied', Color(0xFFB71C1C), Color(0xFFFFCDD2));
}

class SuccessCheck extends StatelessWidget {
  const SuccessCheck({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 200, height: 200,
        decoration: const BoxDecoration(color: Color(0xFFFAE6CD), shape: BoxShape.circle),
        child: Center(
            child: Container(
                width: 150, height: 150,
                decoration: const BoxDecoration(color: kOrangeTop, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Color(0xFFFAE6CD), size: 100))),
      );
}

class RefBox extends StatelessWidget {
  final String code;
  final String note;
  const RefBox(this.code, this.note, {super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        const Text('Your Reference Code:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: kPeach,
            child: Text(code, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800))),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(child: Text(note, style: const TextStyle(color: Colors.grey))),
        ]),
      ]);
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, value;
  const InfoCard(this.icon, this.title, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Icon(icon, size: 34),
          const SizedBox(width: 22),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            Text(value, style: const TextStyle(fontSize: 15)),
          ])),
        ]),
      );
}

class Stars extends StatelessWidget {
  final int value;
  final double size;
  final ValueChanged<int>? onChanged;
  const Stars(this.value, {super.key, this.size = 30, this.onChanged});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
              onTap: onChanged == null ? null : () => onChanged!(i),
              child: Icon(Icons.star_rounded, size: size, color: i <= value ? kOrange : const Color(0xFFD9D9D9))),
      ]);
}

class UploadBox extends StatelessWidget {
  final String text;
  final String? fileName;
  final VoidCallback onTap;
  final bool dashed;
  const UploadBox(this.text, this.fileName, this.onTap, {super.key, this.dashed = false});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
          decoration: BoxDecoration(
              color: dashed ? kSand : Colors.white,
              border: Border.all(color: dashed ? Colors.black87 : Colors.black26, width: dashed ? 1.2 : 2),
              borderRadius: BorderRadius.circular(14)),
          child: fileName != null
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.insert_drive_file_outlined),
                  const SizedBox(width: 8),
                  Flexible(child: Text(fileName!, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: kGreen),
                ])
              : Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
}

class RoomImg extends StatelessWidget {
  final Map<String, dynamic> room;
  final double w, h, r;
  const RoomImg(this.room, {super.key, this.w = 100, this.h = 120, this.r = 14});
  @override
  Widget build(BuildContext context) {
    final imgs = (room['images'] as List?) ?? [];
    return ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: imgs.isEmpty
            ? Container(width: w, height: h, color: const Color(0xFFD9D9D9))
            : Image.network(imgs.first as String, width: w, height: h, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: w, height: h, color: const Color(0xFFD9D9D9))));
  }
}
