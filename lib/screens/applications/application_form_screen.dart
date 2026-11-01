import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../home/main_shell.dart';

// ASSUMPTION: institution list for Bloemfontein. Edit as needed.
const _institutions = ['University of the Free State', 'Central University of Technology', 'Motheo TVET College', 'Other'];
const _relationships = ['Mother', 'Father', 'Guardian', 'Other'];

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key, required this.room});
  final Room room;

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _keys = List.generate(3, (_) => GlobalKey<FormState>());
  final _name = TextEditingController(), _email = TextEditingController(), _phone = TextEditingController();
  final _dob = TextEditingController(), _studentNo = TextEditingController();
  final _gName = TextEditingController(), _gEmail = TextEditingController(), _gContact = TextEditingController();
  final _files = <String, UploadFile?>{for (final t in kDocTypes) t: null};
  DateTime? _dobValue;
  String? _institution, _year, _relationship, _error;
  bool? _nsfas;
  int _step = 0;
  bool _loading = true, _submitting = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _dob, _studentNo, _gName, _gEmail, _gContact]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _prefill() async {
    try {
      final s = await StudentService().requireStudent();
      if (!mounted) return;
      setState(() {
        _name.text = s.fullName;
        _email.text = AuthService().currentUser?.email ?? '';
        _phone.text = s.phone;
        _studentNo.text = s.studentNumber;
        _dobValue = s.dateOfBirth;
        _dob.text = s.dateOfBirth == null ? '' : fmtDate(s.dateOfBirth!);
        _institution = s.institution;
        _year = s.yearOfStudy?.toString();
        _nsfas = s.nsfasFunded;
        _gName.text = s.guardianName;
        _gEmail.text = s.guardianEmail;
        _gContact.text = s.guardianContact;
        _relationship = s.relationship;
      });
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _dobValue ?? DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 15),
    );
    if (d != null) setState(() { _dobValue = d; _dob.text = fmtDate(d); });
  }

  Future<void> _pickFile(String type) async {
    try {
      final f = await StorageService().pick();
      if (f != null) setState(() => _files[type] = f);
    } catch (e) {
      setState(() => _error = friendlyError(e));
    }
  }

  void _next() {
    setState(() => _error = null);
    if (!_keys[_step].currentState!.validate()) return;
    setState(() => _step++);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() { _submitting = true; _error = null; });
    try {
      final existing = await ApplicationService().latest();
      if (existing != null && existing.statusName != 'Rejected') {
        setState(() => _error = 'You already have an application (${existing.number}). Track it from the Application tab.');
        return;
      }
      final result = await ApplicationService().submit(
        roomId: widget.room.id,
        studentValues: {
          'phone_number': _phone.text.trim(),
          'date_of_birth': isoDate(_dobValue!),
          'institution': _institution,
          'year_of_study': int.parse(_year!),
          'nsfas_funded': _nsfas,
          'guardian_name': _gName.text.trim(),
          'guardian_email': _gEmail.text.trim(),
          'guardian_contact': _gContact.text.trim(),
          'relationship': _relationship,
        },
        files: _files,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ApplicationSubmittedScreen(number: result.number, failedDocs: result.failed)));
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _indicator() {
    const labels = ['Personal\ndetails', 'Academic\ndetails', 'Family\ninformation', 'Upload\ndocuments'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) Expanded(child: Padding(padding: const EdgeInsets.only(top: 10), child: Container(height: 2, color: i <= _step ? AppColors.orange : AppColors.border))),
          SizedBox(
            width: 58,
            child: Column(children: [
              CircleAvatar(radius: 11, backgroundColor: i <= _step ? AppColors.orange : AppColors.border, child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: Colors.white))),
              const SizedBox(height: 4),
              Text(labels[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: i <= _step ? AppColors.orangeDark : AppColors.muted)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return Form(key: _keys[0], child: Column(children: [
          AppTextField(controller: _name, hint: 'Full name', icon: Icons.person_outline, validator: (v) => Validators.required(v, 'Full name')),
          AppTextField(controller: _email, hint: 'Email address', icon: Icons.mail_outline, validator: Validators.email, keyboardType: TextInputType.emailAddress),
          AppTextField(controller: _phone, hint: 'Phone number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => Validators.required(v, 'Phone number')),
          AppPickerField(controller: _dob, hint: 'Date of birth', icon: Icons.calendar_today_outlined, onTap: _pickDob, validator: (v) => Validators.required(v, 'Date of birth')),
        ]));
      case 1:
        return Form(key: _keys[1], child: Column(children: [
          AppDropdown(hint: 'Select your institution', icon: Icons.account_balance_outlined, items: _institutions, value: _institution, onChanged: (v) => setState(() => _institution = v), validator: (v) => v == null ? 'Select your institution' : null),
          AppTextField(controller: _studentNo, hint: 'Student number', icon: Icons.school_outlined, keyboardType: TextInputType.number, validator: (v) => Validators.required(v, 'Student number')),
          AppDropdown(hint: 'Select your year', icon: Icons.event_note_outlined, items: const ['1', '2', '3', '4', '5'], value: _year, onChanged: (v) => setState(() => _year = v), validator: (v) => v == null ? 'Select your year of study' : null),
          FormField<bool>(
            initialValue: _nsfas,
            validator: (_) => _nsfas == null ? 'Please choose Yes or No' : null,
            builder: (state) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('NSFAS Funded?', style: TextStyle(fontSize: 12)),
                Radio<bool>(value: true, groupValue: _nsfas, onChanged: (v) { setState(() => _nsfas = v); state.didChange(v); }),
                const Text('Yes', style: TextStyle(fontSize: 11)),
                Radio<bool>(value: false, groupValue: _nsfas, onChanged: (v) { setState(() => _nsfas = v); state.didChange(v); }),
                const Text('No', style: TextStyle(fontSize: 11)),
              ]),
              if (state.hasError) Text(state.errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
              if (_nsfas == false)
                const Padding(padding: EdgeInsets.only(top: 6), child: Text('If you are not NSFAS funded, please provide a parent payslip in the last step.', style: TextStyle(fontSize: 10, color: AppColors.muted))),
            ]),
          ),
        ]));
      case 2:
        return Form(key: _keys[2], child: Column(children: [
          AppTextField(controller: _gName, hint: 'Parent / Guardian name', icon: Icons.person_outline, validator: (v) => Validators.required(v, 'Guardian name')),
          AppTextField(controller: _gEmail, hint: 'Email address', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, validator: Validators.email),
          AppTextField(controller: _gContact, hint: 'Contact number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => Validators.required(v, 'Contact number')),
          AppDropdown(hint: 'Select relationship', icon: Icons.people_outline, items: _relationships, value: _relationship, onChanged: (v) => setState(() => _relationship = v), validator: (v) => v == null ? 'Select a relationship' : null),
        ]));
      default:
        return Column(children: [
          for (final t in kDocTypes) UploadTile(label: t, hint: 'JPG, PNG or PDF, up to 5 MB', file: _files[t], onPick: () => _pickFile(t)),
          const Text('You can also add missing documents later from the Application tab.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.muted)),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Student Accommodation Application',
      subtitle: 'Applying for ${widget.room.name} (${widget.room.type}) - Step ${_step + 1} of 4',
      child: _loading
          ? const Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.orange))
          : Column(children: [
              _indicator(),
              _stepBody(),
              const SizedBox(height: 4),
              ErrorMessage(_error),
              if (_step < 3) AppButton(label: 'Next', icon: Icons.arrow_forward, onPressed: _next) else AppButton(label: 'Submit', loading: _submitting, onPressed: _submit),
              if (_step > 0) TextButton(onPressed: () => setState(() => _step--), child: const Text('Previous', style: TextStyle(color: AppColors.orange))),
            ]),
    );
  }
}

class ApplicationSubmittedScreen extends StatelessWidget {
  const ApplicationSubmittedScreen({super.key, required this.number, required this.failedDocs});
  final String number;
  final List<String> failedDocs;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Application Submitted',
      showBack: false,
      child: SuccessView(
        message: "We've received your application. Your application is under review by management.",
        reference: number,
        warning: failedDocs.isEmpty ? null : 'These documents did not upload: ${failedDocs.join(', ')}. You can upload them from the Application tab.',
        primaryLabel: 'Track Application',
        onPrimary: () => openShell(context, tab: 2),
      ),
    );
  }
}
