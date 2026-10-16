import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'payment.dart';
import 'state.dart';
import 'ui.dart';

Future<PlatformFile?> pickFile({List<String>? ext}) async {
  final r = await FilePicker.platform.pickFiles(withData: true, type: ext == null ? FileType.any : FileType.custom, allowedExtensions: ext);
  return r?.files.first;
}

/// "Application" tab: status tracker (or a prompt to apply)
class ApplicationPage extends StatelessWidget {
  const ApplicationPage({super.key});

  Widget _node(String label, int idx, int reached, {bool last = false, bool check = false}) {
    final done = idx < reached;
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
              radius: 17,
              backgroundColor: done ? kOrange : const Color(0xFFD9D9D9),
              child: check && done ? const Icon(Icons.check, color: Colors.white, size: 20) : Text('${idx < 4 ? idx + 1 : idx == 4 ? 5 : 6}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          if (!last) Expanded(child: Container(height: 3, color: idx + 1 < reached ? kOrange : const Color(0xFFD9D9D9))),
        ]),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: done ? kOrange : kOrange.withOpacity(.55), fontSize: 15, fontWeight: idx == 6 ? FontWeight.w800 : FontWeight.w400)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) {
          final a = app.application;
          final reached = app.applicationStage;
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(children: [
              const WaveHeader(height: 170, back: false),
              Expanded(
                child: a == null
                    ? Center(
                        child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text('You have not submitted an application yet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)),
                              const SizedBox(height: 20),
                              OBtn('Start Application', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationFormScreen()))),
                            ])))
                    : ListView(padding: const EdgeInsets.fromLTRB(22, 4, 22, 20), children: [
                        const Center(child: Text('Application Status Tracker', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800))),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 330,
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(40)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Application Number', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Row(children: [const Icon(Icons.circle_outlined, size: 18), const SizedBox(width: 14), Text('${a['application_number']}', style: const TextStyle(fontSize: 24))]),
                              const SizedBox(height: 16),
                              const Text('Pending Documents :', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              if (app.pendingDocs.isEmpty) const Text('None - all documents received', style: TextStyle(fontSize: 17)),
                              for (final d in app.pendingDocs) Padding(padding: const EdgeInsets.only(left: 2, top: 6), child: Row(children: [const Icon(Icons.circle_outlined, size: 16), const SizedBox(width: 14), Expanded(child: Text(d, style: const TextStyle(fontSize: 18)))])),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text('Status time line', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        Row(children: [
                          _node('Personal\ndetails', 0, reached),
                          _node('Academic\ndetails', 1, reached),
                          _node('Family\ninformation', 2, reached),
                          _node('Upload\ndocuments', 3, reached, last: true),
                        ]),
                        const SizedBox(height: 18),
                        Row(children: [
                          _node('Submitted', 4, reached),
                          _node('Under\nReview', 5, reached, check: true),
                          _node('Approved', 6, reached, last: true),
                          const Expanded(child: SizedBox()),
                        ]),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(spacing: 10, children: [
                            if (reached >= 7) ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen())), style: _pillStyle, child: const Text('Make Payment', style: TextStyle(fontWeight: FontWeight.w700))),
                            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewScreen())), style: _pillStyle, child: const Text('submit Review', style: TextStyle(fontWeight: FontWeight.w700))),
                          ]),
                        ),
                      ]),
              ),
            ]),
          );
        },
      );
}

final _pillStyle = ElevatedButton.styleFrom(backgroundColor: kOrange, foregroundColor: Colors.white, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14));

class ApplicationFormScreen extends StatefulWidget {
  final M? room;
  const ApplicationFormScreen({super.key, this.room});
  @override
  State<ApplicationFormScreen> createState() => _AppFormState();
}

class _AppFormState extends State<ApplicationFormScreen> {
  int step = 0;
  bool busy = false;
  late final name = TextEditingController(text: '${app.user['name'] ?? ''}');
  late final email = TextEditingController(text: '${app.user['email'] ?? ''}');
  late final phone = TextEditingController(text: '${app.user['phone'] ?? ''}');
  late final sn = TextEditingController(text: '${app.user['student_number'] ?? ''}');
  final gName = TextEditingController(), gEmail = TextEditingController(), gPhone = TextEditingController();
  DateTime? dob;
  String? inst, year, rel;
  bool? nsfas;
  final docs = <String, PlatformFile>{};

  static const insts = ['University of the Free State', 'Central University of Technology', 'Motheo TVET College', 'Other'];
  static const years = ['1st year', '2nd year', '3rd year', '4th year', 'Postgraduate'];
  static const rels = ['Mother', 'Father', 'Guardian', 'Sibling', 'Other'];
  static final _em = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? validate() {
    switch (step) {
      case 0:
        if (name.text.trim().isEmpty) return 'Please enter your full name.';
        if (!_em.hasMatch(email.text.trim())) return 'Please enter a valid email address.';
        if (phone.text.replaceAll(RegExp(r'\D'), '').length < 10) return 'Please enter a valid phone number.';
        if (dob == null) return 'Please select your date of birth.';
        return null;
      case 1:
        if (inst == null) return 'Please select your institution.';
        if (sn.text.trim().isEmpty) return 'Please enter your student number.';
        if (year == null) return 'Please select your year of study.';
        if (nsfas == null) return 'Please indicate whether you are NSFAS funded.';
        return null;
      case 2:
        if (gName.text.trim().isEmpty) return 'Please enter the parent/guardian name.';
        if (!_em.hasMatch(gEmail.text.trim())) return 'Please enter a valid guardian email.';
        if (gPhone.text.replaceAll(RegExp(r'\D'), '').length < 10) return 'Please enter a valid contact number.';
        if (rel == null) return 'Please select the relationship.';
        return null;
      default:
        for (final k in ['id', 'registration', 'funding']) {
          if (!docs.containsKey(k)) return 'Please upload: ${AppState.requiredDocs[k]}.';
        }
        return null;
    }
  }

  Future<void> next() async {
    final e = validate();
    if (e != null) return toast(context, e);
    if (step < 3) return setState(() => step++);
    setState(() => busy = true);
    final err = await app.submitApplication({
      'name': name.text.trim(), 'email': email.text.trim(), 'phone': phone.text.trim(), 'dob': ymd(dob!), 'institution': inst, 'year': year, 'nsfas': nsfas,
      'g_name': gName.text.trim(), 'g_email': gEmail.text.trim(), 'g_phone': gPhone.text.trim(), 'g_rel': rel,
    }, docs, widget.room);
    if (!mounted) return;
    setState(() => busy = false);
    if (err != null) return toast(context, err);
    toast(context, 'Application submitted successfully.');
    goTab(context, 2);
  }

  Widget _stepper() {
    const labels = ['Personal\ndetails', 'Academic\ndetails', 'Family\ninformation', 'Upload\ndocuments'];
    return Row(children: [
      for (var i = 0; i < 4; i++)
        Expanded(
          child: Column(children: [
            Row(children: [
              Expanded(child: i == 0 ? const SizedBox() : Container(height: 3, color: const Color(0xFFD9D9D9))),
              CircleAvatar(
                  radius: 17,
                  backgroundColor: i == step ? kOrange : i < step ? const Color(0xFFFFE0B8) : const Color(0xFFD9D9D9),
                  child: Text('${i + 1}', style: TextStyle(color: i < step ? kOrange : Colors.white, fontWeight: FontWeight.bold))),
              Expanded(child: i == 3 ? const SizedBox() : Container(height: 3, color: const Color(0xFFD9D9D9))),
            ]),
            const SizedBox(height: 6),
            Text(labels[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: i == step ? kOrange : Colors.black54)),
          ]),
        ),
    ]);
  }

  Widget _docRow(String key, String title, String sub) => Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.description_outlined, size: 34)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            Text(docs[key]?.name ?? sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: docs[key] != null ? kGreen : Colors.grey)),
          ])),
          GestureDetector(
            onTap: () async { final f = await pickFile(ext: ['pdf', 'jpg', 'jpeg', 'png']); if (f != null) setState(() => docs[key] = f); },
            child: Container(width: 96, height: 62, alignment: Alignment.center, decoration: const BoxDecoration(color: kOrangeTop, borderRadius: BorderRadius.horizontal(right: Radius.circular(16), left: Radius.circular(8))), child: const Text('Upload', style: TextStyle(color: Colors.white, fontSize: 18))),
          ),
        ]),
      );

  Widget _yn(String t, bool v) => GestureDetector(
        onTap: () => setState(() => nsfas = v),
        child: Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          decoration: BoxDecoration(color: nsfas == v ? kOrange : const Color(0xFFFFB04D), borderRadius: BorderRadius.circular(20), border: nsfas == v ? Border.all(color: Colors.black87, width: 2) : null),
          child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        ),
      );

  Widget _body() {
    const g = SizedBox(height: 20);
    switch (step) {
      case 0:
        return Column(children: [
          Field('Enter your full name', Icons.person_outline, label: 'Full Name', controller: name),
          g,
          Field('Enter your email', Icons.mail_outline, label: 'Email Address', controller: email, keyboard: TextInputType.emailAddress),
          g,
          Field('Enter your phone number', Icons.phone_outlined, label: 'Phone Number', controller: phone, keyboard: TextInputType.phone),
          g,
          Field(dob == null ? 'Select your date of birth' : fmtLong(dob!), Icons.calendar_today_outlined, label: 'Date of Birth', readOnly: true, onTap: () async {
            final d = await showDatePicker(context: context, initialDate: dob ?? DateTime(2006), firstDate: DateTime(1980), lastDate: DateTime.now());
            if (d != null) setState(() => dob = d);
          }),
        ]);
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Drop('Current institution', 'Select your institution', Icons.account_balance_outlined, inst, insts, (v) => setState(() => inst = v)),
          g,
          Field('Enter your student number', Icons.school_outlined, label: 'Student Number', controller: sn, keyboard: TextInputType.number),
          g,
          Drop('Year of Study', 'Select your year', Icons.calendar_today_outlined, year, years, (v) => setState(() => year = v)),
          g,
          Row(children: [const Expanded(child: Text('NSFAS Funded?', style: TextStyle(fontSize: 20))), _yn('Yes', true), _yn('No', false)]),
          if (nsfas == false) ...[
            const SizedBox(height: 12),
            const Text('If you are not NSFAS Funded please provide  parent payslip', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            UploadBox('Upload here', docs['funding']?.name, () async { final f = await pickFile(ext: ['pdf', 'jpg', 'jpeg', 'png']); if (f != null) setState(() => docs['funding'] = f); }),
          ],
        ]);
      case 2:
        return Column(children: [
          Field('Enter name', Icons.person_outline, label: 'Parent /Guardian Name', controller: gName),
          g,
          Field('Enter your email', Icons.mail_outline, label: 'Email Address', controller: gEmail, keyboard: TextInputType.emailAddress),
          g,
          Field('Enter contact number', Icons.phone_outlined, label: 'Contact Number', controller: gPhone, keyboard: TextInputType.phone),
          g,
          Drop('Relationship', 'Select relationship', Icons.people_outline, rel, rels, (v) => setState(() => rel = v)),
        ]);
      default:
        return Column(children: [
          _docRow('id', 'ID Document', 'Upload your ID'),
          _docRow('registration', 'Proof of Registraion', 'Upload registration proof'),
          _docRow('funding', 'Funding Approval/\nParent Payslip', 'Upload funding proof'),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          WaveHeader(height: 190, back: true, child: const Padding(padding: EdgeInsets.only(top: 30), child: Logo(w: 230, onOrange: true))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: Column(children: [
                const Text('Student Accommodation Application', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Complete your application -Step 1-4', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                _stepper(),
                const SizedBox(height: 28),
                _body(),
                const SizedBox(height: 28),
                OBtn(step == 3 ? 'Submit' : 'Next', icon: step == 3 ? null : Icons.arrow_forward, loading: busy, onTap: next),
                if (step > 0) TextButton(onPressed: () => setState(() => step--), child: const Text('Back', style: TextStyle(color: kOrange, fontSize: 16))),
              ]),
            ),
          ),
          const Tagline(),
        ]),
      );
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  @override
  State<ReviewScreen> createState() => _ReviewState();
}

class _ReviewState extends State<ReviewScreen> {
  int rating = 3;
  final c = TextEditingController();
  bool busy = false;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => PageShell(
          navIndex: 2,
          child: ListView(padding: const EdgeInsets.fromLTRB(22, 0, 22, 20), children: [
            const Center(child: Text('Review & Feed Back', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800))),
            const SizedBox(height: 22),
            const Text('Rate your experience', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Stars(rating, size: 54, onChanged: (v) => setState(() => rating = v)),
            const SizedBox(height: 22),
            const Text('Your comment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(controller: c, maxLines: 6, decoration: InputDecoration(hintText: 'Write your feed back here ...', filled: true, fillColor: const Color(0xFFF4F4F4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none))),
            const SizedBox(height: 14),
            Center(child: SizedBox(width: 220, child: OBtn('Submit Review', dark: true, loading: busy, onTap: () async {
              if (c.text.trim().isEmpty) return toast(context, 'Please write a short comment.');
              setState(() => busy = true);
              final ok = await app.submitReview(rating, c.text.trim());
              if (!mounted) return;
              setState(() => busy = false);
              if (ok) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReviewSubmittedScreen())); } else { toast(context, 'Could not submit review. Try again.'); }
            }))),
            const SizedBox(height: 18),
            const Text('Previous Reviews', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            for (final r in app.reviews)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const CircleAvatar(radius: 32, backgroundColor: Color(0xFFD9D9D9)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${r['student_name']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                    Stars((r['rating'] ?? 0) as int, size: 30),
                    if ('${r['comment'] ?? ''}'.isNotEmpty) Text('${r['comment']}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ])),
                ]),
              ),
          ]),
        ),
      );
}

class ReviewSubmittedScreen extends StatelessWidget {
  const ReviewSubmittedScreen({super.key});
  @override
  Widget build(BuildContext context) => PageShell(
        navIndex: 2,
        back: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(children: [
            const SizedBox(height: 10),
            const Text('Review submitted', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 54),
            const SuccessCheck(),
            const SizedBox(height: 40),
            const Text('Thank you!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text("We've received your review. Your feedback helps us make student living better.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black54)),
            const SizedBox(height: 28),
            SizedBox(width: 240, child: OBtn('Back to Reviews', dark: true, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReviewScreen())))),
          ]),
        ),
      );
}
