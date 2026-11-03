import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../home/main_shell.dart';

final _slots = [for (var h = 8; h <= 16; h++) '${two(h)}:00'];
const _roomTypes = ['Singles', 'Sharing', 'Bachelors'];
const _genders = ['Male', 'Female'];

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({super.key});

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

class _ViewingsScreenState extends State<ViewingsScreen> {
  Key _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Scheduled Viewings',
      fab: FloatingActionButton(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookViewingScreen()));
          if (mounted) setState(() => _key = UniqueKey());
        },
        child: const Icon(Icons.add),
      ),
      child: LoadView<List<Viewing>>(
        key: _key,
        loader: ViewingService().list,
        builder: (context, list, _) {
          if (list.isEmpty) return const EmptyState(icon: Icons.event_outlined, message: 'No viewings currently scheduled');
          return Column(children: [
            for (final v in list)
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewingDetailsScreen(viewing: v))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFFF0D5), borderRadius: BorderRadius.circular(10)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text('${v.roomType} Room (${v.gender})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      StatusChip(v.status),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 13),
                      const SizedBox(width: 4),
                      Text(v.date == null ? '-' : fmtDate(v.date!), style: const TextStyle(fontSize: 10)),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 13),
                      const SizedBox(width: 4),
                      Text('${v.preferred} / ${v.alternative}', style: const TextStyle(fontSize: 10)),
                    ]),
                  ]),
                ),
              ),
          ]);
        },
      ),
    );
  }
}

class BookViewingScreen extends StatefulWidget {
  const BookViewingScreen({super.key});

  @override
  State<BookViewingScreen> createState() => _BookViewingScreenState();
}

class _BookViewingScreenState extends State<BookViewingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateText = TextEditingController();
  DateTime? _date;
  String? _preferred, _alternative, _gender, _roomType;

  @override
  void dispose() {
    _dateText.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: _date ?? now.add(const Duration(days: 1)), firstDate: now.add(const Duration(days: 1)), lastDate: now.add(const Duration(days: 120)));
    if (d != null) setState(() { _date = d; _dateText.text = fmtDate(d); });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final draft = ViewingDraft(date: _date!, preferred: _preferred!, alternative: _alternative!, gender: _gender!, roomType: _roomType!);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailsScreen(draft: draft)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Book a Viewing',
      subtitle: 'Choose a preferred date and time.',
      child: Form(
        key: _formKey,
        child: Column(children: [
          AppPickerField(controller: _dateText, hint: 'Select date', icon: Icons.calendar_today_outlined, onTap: _pickDate, validator: (v) => Validators.required(v, 'Date')),
          Row(children: [
            Expanded(child: AppDropdown(hint: 'Preferred time', icon: Icons.access_time, items: _slots, value: _preferred, onChanged: (v) => setState(() => _preferred = v), validator: (v) => v == null ? 'Required' : null)),
            const SizedBox(width: 8),
            Expanded(child: AppDropdown(hint: 'Alternative time', icon: Icons.access_time, items: _slots, value: _alternative, onChanged: (v) => setState(() => _alternative = v), validator: (v) => v == null ? 'Required' : (v == _preferred ? 'Pick a different time' : null))),
          ]),
          AppDropdown(hint: 'Select gender', icon: Icons.person_outline, items: _genders, value: _gender, onChanged: (v) => setState(() => _gender = v), validator: (v) => v == null ? 'Select gender' : null),
          AppDropdown(hint: 'Select room type (Singles, Sharing, Bachelors)', icon: Icons.bed_outlined, items: _roomTypes, value: _roomType, onChanged: (v) => setState(() => _roomType = v), validator: (v) => v == null ? 'Select room type' : null),
          const SizedBox(height: 8),
          AppButton(label: 'Submit', onPressed: _submit),
        ]),
      ),
    );
  }
}

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key, required this.draft});
  final ViewingDraft draft;

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      final ref = await ViewingService().create(widget.draft);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ViewingSubmittedScreen(reference: ref)));
    } catch (e) {
      if (mounted) setState(() { _error = friendlyError(e); _busy = false; });
    }
  }

  Widget _row(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Text(k, style: const TextStyle(fontSize: 11, color: AppColors.muted)), const Spacer(), Text(v, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]));

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    final email = AuthService().currentUser?.email ?? '';
    return AuthScaffold(
      title: 'Booking Details',
      subtitle: 'Review your details before confirming.',
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            const Align(alignment: Alignment.centerLeft, child: Text('Viewing Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            _row('Date', fmtDate(d.date)),
            _row('Preferred time', d.preferred),
            _row('Alternative time', d.alternative),
            _row('Room type', '${d.roomType} (${d.gender})'),
          ]),
        ),
        const SizedBox(height: 10),
        LoadView<Student>(
          loader: StudentService().requireStudent,
          builder: (context, s, _) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              const Align(alignment: Alignment.centerLeft, child: Text('Your Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              _row('Full name', s.fullName),
              _row('Contact number', s.phone.isEmpty ? '-' : s.phone),
              _row('Email Address', email),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Your viewing has not been booked yet. Confirm below to submit your request.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.muted)),
        const SizedBox(height: 12),
        ErrorMessage(_error),
        AppButton(label: 'Confirm', loading: _busy, onPressed: _confirm),
        const SizedBox(height: 8),
        AppButton(label: 'Edit Viewing Details', outlined: true, onPressed: () => Navigator.of(context).pop()),
      ]),
    );
  }
}

class ViewingSubmittedScreen extends StatelessWidget {
  const ViewingSubmittedScreen({super.key, required this.reference});
  final String reference;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Viewing Request Submitted',
      showBack: false,
      child: SuccessView(
        message: 'Keep this code for your records. We will notify you when the residence confirms your viewing.',
        reference: reference,
        primaryLabel: 'Back to Home',
        onPrimary: () => openShell(context),
        secondaryLabel: 'Go to Viewings',
        onSecondary: () {
          final nav = Navigator.of(context);
          nav.popUntil((r) => r.isFirst);
          nav.push(MaterialPageRoute(builder: (_) => const ViewingsScreen()));
        },
      ),
    );
  }
}

class ViewingDetailsScreen extends StatelessWidget {
  const ViewingDetailsScreen({super.key, required this.viewing});
  final Viewing viewing;

  @override
  Widget build(BuildContext context) {
    final v = viewing;
    final pending = ['pending', 'requested'].contains(v.status.toLowerCase());
    return AuthScaffold(
      title: 'Viewing Details',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [StatusChip(v.status), const Spacer(), Text(v.reference, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 8),
          Text('${v.roomType} Room (${v.gender})', style: const TextStyle(fontWeight: FontWeight.w700)),
          const Text('Universitas, Bloemfontein', style: TextStyle(fontSize: 10, color: AppColors.muted)),
          const Divider(height: 24),
          Row(children: [const Icon(Icons.calendar_today_outlined, size: 15), const SizedBox(width: 6), Text(v.date == null ? '-' : fmtDate(v.date!), style: const TextStyle(fontSize: 12))]),
          const SizedBox(height: 6),
          Row(children: [const Icon(Icons.access_time, size: 15), const SizedBox(width: 6), Text('${v.preferred} / ${v.alternative}', style: const TextStyle(fontSize: 12))]),
          if (pending) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFFF0D5), borderRadius: BorderRadius.circular(6)),
              child: const Text('Awaiting Confirmation: your viewing request has been submitted. We will notify you when the residence confirms.', style: TextStyle(fontSize: 10)),
            ),
          ],
        ]),
      ),
    );
  }
}
