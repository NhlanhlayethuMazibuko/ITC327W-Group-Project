import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'application.dart' show pickFile;
import 'state.dart';
import 'ui.dart';

DateTime _dt(dynamic v) => DateTime.tryParse('$v')?.toLocal() ?? DateTime.now();

class MaintenanceListScreen extends StatelessWidget {
  const MaintenanceListScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => PageShell(
          navIndex: 3,
          child: Column(children: [
            const Text('Maintenance Requests', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            Expanded(
              child: app.maint.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.assignment_outlined, size: 56, color: Colors.grey),
                      const SizedBox(height: 14),
                      const Text('No current maintenance requests', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ]))
                  : ListView(padding: const EdgeInsets.all(18), children: [
                      for (final m in app.maint)
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MaintenanceReportScreen(m: m))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: kSand, borderRadius: BorderRadius.circular(20), boxShadow: cardShadow),
                            child: Column(children: [
                              Row(children: [
                                Expanded(child: Text('${m['category']}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
                                Pill.status('${m['status']}'),
                                const Icon(Icons.chevron_right, color: Colors.black54),
                              ]),
                              const SizedBox(height: 18),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text.rich(TextSpan(text: 'Request ', style: const TextStyle(color: Colors.black54, fontSize: 16), children: [TextSpan(text: '${m['reference_code']}', style: const TextStyle(fontWeight: FontWeight.w800))])),
                                Text(fmtMd(_dt(m['created_at'])), style: const TextStyle(fontSize: 16)),
                              ]),
                            ]),
                          ),
                        ),
                    ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 8, 60, 24),
              child: OBtn('New Request', dark: true, icon: Icons.add, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewMaintenanceScreen()))),
            ),
          ]),
        ),
      );
}

class NewMaintenanceScreen extends StatefulWidget {
  const NewMaintenanceScreen({super.key});
  @override
  State<NewMaintenanceScreen> createState() => _NewMaintState();
}

class _NewMaintState extends State<NewMaintenanceScreen> {
  String? cat, pri, type;
  final desc = TextEditingController();
  PlatformFile? photo;
  bool busy = false;
  static const cats = ['Plumbing', 'Electrical', 'Furniture', 'Appliances', 'Security / Locks', 'Internet / Wi-Fi', 'Other'];

  Widget _lbl(String t) => Padding(padding: const EdgeInsets.only(top: 14, bottom: 6), child: Text(t, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)));

  Widget _dd(String hint, String? v, List<String> items, ValueChanged<String?> f) => DropdownButtonFormField<String>(
        value: v,
        isExpanded: true,
        hint: Text(hint, style: const TextStyle(color: Colors.black54)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: f,
        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black87))),
      );

  Future<void> submit() async {
    if (cat == null || pri == null || type == null) return toast(context, 'Please select a category, priority and type.');
    if (desc.text.trim().length < 5) return toast(context, 'Please describe the issue.');
    setState(() => busy = true);
    final ref = await app.submitMaintenance({'category': cat, 'priority': pri, 'type': type, 'description': desc.text.trim()}, photo);
    if (!mounted) return;
    setState(() => busy = false);
    if (ref == null) return toast(context, 'Could not submit your request. Please try again.');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MaintenanceSubmittedScreen(ref: ref)));
  }

  @override
  Widget build(BuildContext context) => PageShell(
        navIndex: 3,
        child: ListView(padding: const EdgeInsets.fromLTRB(22, 0, 22, 20), children: [
          const Center(child: Text('New Maintenance Request', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800))),
          Center(child: _lbl('Category')),
          _dd('Select Category', cat, cats, (v) => setState(() => cat = v)),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Priority'), _dd('Select Priority', pri, const ['Low', 'Medium', 'High'], (v) => setState(() => pri = v))])),
            const SizedBox(width: 18),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Type'), _dd('Routine/Non-Routine', type, const ['Routine', 'Non-Routine'], (v) => setState(() => type = v))])),
          ]),
          Center(child: _lbl('Descripiton')),
          TextField(controller: desc, maxLines: 5, decoration: InputDecoration(hintText: 'Provide a brief description of the issue...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black87)))),
          Center(child: _lbl('Photo (Optional)')),
          InkWell(
            onTap: () async { final f = await pickFile(ext: ['jpg', 'jpeg', 'png']); if (f != null) setState(() => photo = f); },
            child: Container(
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: Colors.black87), borderRadius: BorderRadius.circular(10)),
              child: photo != null
                  ? Text(photo!.name, style: const TextStyle(fontWeight: FontWeight.w700))
                  : const Column(mainAxisSize: MainAxisSize.min, children: [
                      Text.rich(TextSpan(children: [TextSpan(text: 'Tap to upload ', style: TextStyle(fontWeight: FontWeight.w800, decoration: TextDecoration.underline)), TextSpan(text: 'or drag and drop file')]), style: TextStyle(fontSize: 17)),
                      SizedBox(height: 6),
                      Text('(JPG,PNG,JPEG)'),
                    ]),
            ),
          ),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: OBtn('Cancel', outline: true, dark: true, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 16),
            Expanded(child: OBtn('Submit', dark: true, loading: busy, onTap: submit)),
          ]),
        ]),
      );
}

class MaintenanceSubmittedScreen extends StatelessWidget {
  final String ref;
  const MaintenanceSubmittedScreen({super.key, required this.ref});
  @override
  Widget build(BuildContext context) => PageShell(
        navIndex: 3,
        child: ListView(padding: const EdgeInsets.fromLTRB(28, 0, 28, 20), children: [
          const Center(child: Text('Maintenance Request\nSubmitted', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800))),
          const SizedBox(height: 26),
          const Center(child: SuccessCheck()),
          const SizedBox(height: 34),
          RefBox(ref, 'Keep this reference to follow up on your request'),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: kPeach, borderRadius: BorderRadius.circular(16)),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info, color: kOrange, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: 'Management will review the issue and contact you if they need to arrange access. '), TextSpan(text: 'For urgent safety issues, contact management directly.', style: TextStyle(fontWeight: FontWeight.w800))]), style: TextStyle(color: Colors.black54, fontSize: 16))),
            ]),
          ),
          const SizedBox(height: 24),
          Center(child: SizedBox(width: 280, child: OBtn('Back to Home', dark: true, onTap: () => goTab(context, 0)))),
          const SizedBox(height: 12),
          Center(child: SizedBox(width: 280, child: OBtn('View Requests', outline: true, dark: true, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MaintenanceListScreen()))))),
        ]),
      );
}

class MaintenanceReportScreen extends StatelessWidget {
  final M m;
  const MaintenanceReportScreen({super.key, required this.m});
  Widget _kv(String k, Widget v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k, style: const TextStyle(fontSize: 17)), v]);
  @override
  Widget build(BuildContext context) {
    final high = '${m['priority']}'.toLowerCase() == 'high';
    return PageShell(
      navIndex: 3,
      child: ListView(padding: const EdgeInsets.fromLTRB(22, 0, 22, 20), children: [
        const Center(child: Text('Maintenance Report', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(26)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: kSand, borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Request ID'),
                  Text('${m['reference_code']}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                  Text('Submitted on ${_dt(m['created_at']).day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][_dt(m['created_at']).month - 1]} ${_dt(m['created_at']).year}', style: const TextStyle(color: Colors.black54)),
                ]),
              )),
              const SizedBox(width: 8),
              Pill.status('${m['status']}'),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _kv('Category', Text('${m['category']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)))),
              const CircleAvatar(radius: 18, backgroundColor: Color(0xFFF08E00), child: Icon(Icons.priority_high, color: Colors.white)),
              const SizedBox(width: 10),
              Expanded(child: _kv('Priority', Text('${m['priority']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: high ? Colors.red : Colors.black87)))),
            ]),
            const SizedBox(height: 18),
            _kv('Type', Text('${m['request_type']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            const SizedBox(height: 18),
            _kv('Description', Text('${m['description']}', style: const TextStyle(fontSize: 16, color: Colors.black54))),
            const SizedBox(height: 18),
            const Center(child: Text('Photo', style: TextStyle(fontSize: 17))),
            const SizedBox(height: 8),
            Center(child: Container(width: 160, height: 80, decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(20)), child: m['photo_path'] == null ? null : const Icon(Icons.image_outlined, size: 34, color: Colors.black45))),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: kPeach, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [const Icon(Icons.info, color: kOrange, size: 18), const SizedBox(width: 8), Expanded(child: Text('${m['status']}'.toLowerCase().contains('pend') ? 'Your request has been received and is under review' : 'Status: ${m['status']}', style: const TextStyle(color: Colors.black54, fontSize: 16)))]),
            ),
          ]),
        ),
      ]),
    );
  }
}
