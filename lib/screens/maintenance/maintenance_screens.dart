import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../home/main_shell.dart';

// ASSUMPTION: category list. Edit to match what management handles.
const _categories = [
  'Plumbing',
  'Electrical',
  'Furniture',
  'Appliances',
  'Cleaning',
  'Security',
  'Other'
];

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  Key _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Maintenance Requests',
      child: LoadView<List<MaintenanceRequest>>(
        key: _key,
        loader: MaintenanceService().list,
        builder: (context, list, _) => Column(children: [
          if (list.isEmpty)
            const EmptyState(
                icon: Icons.assignment_outlined,
                message: 'No current maintenance requests'),
          for (final r in list)
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MaintenanceDetailScreen(request: r))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF0D5),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(r.category,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13))),
                        StatusChip(r.status)
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Text('Request ${r.reference}',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.muted)),
                        const Spacer(),
                        Text(r.createdAt == null ? '' : fmtDate(r.createdAt!),
                            style: const TextStyle(fontSize: 10)),
                      ]),
                    ]),
              ),
            ),
          const SizedBox(height: 8),
          AppButton(
            label: 'New Request',
            icon: Icons.add,
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NewMaintenanceScreen()));
              if (mounted) setState(() => _key = UniqueKey());
            },
          ),
        ]),
      ),
    );
  }
}

class NewMaintenanceScreen extends StatefulWidget {
  const NewMaintenanceScreen({super.key});

  @override
  State<NewMaintenanceScreen> createState() => _NewMaintenanceScreenState();
}

class _NewMaintenanceScreenState extends State<NewMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _desc = TextEditingController();
  String? _category, _priority, _type, _error;
  UploadFile? _photo;
  bool _busy = false;

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final f = await StorageService().pick(imagesOnly: true);
      if (f != null) setState(() => _photo = f);
    } catch (e) {
      setState(() => _error = friendlyError(e));
    }
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ref = await MaintenanceService().create(
          category: _category!,
          priority: _priority!,
          type: _type!,
          description: _desc.text.trim(),
          photo: _photo);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => MaintenanceSubmittedScreen(reference: ref)));
    } catch (e) {
      if (mounted)
        setState(() {
          _error = friendlyError(e);
          _busy = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'New Maintenance Request',
      child: Form(
        key: _formKey,
        child: Column(children: [
          AppDropdown(
              hint: 'Select category',
              icon: Icons.category_outlined,
              items: _categories,
              value: _category,
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Select a category' : null),
          Row(children: [
            Expanded(
                child: AppDropdown(
                    hint: 'Priority',
                    icon: Icons.flag_outlined,
                    items: const ['Low', 'Medium', 'High'],
                    value: _priority,
                    onChanged: (v) => setState(() => _priority = v),
                    validator: (v) => v == null ? 'Required' : null)),
            const SizedBox(width: 8),
            Expanded(
                child: AppDropdown(
                    hint: 'Type',
                    icon: Icons.grid_view_outlined,
                    items: const ['Routine', 'Non-Routine'],
                    value: _type,
                    onChanged: (v) => setState(() => _type = v),
                    validator: (v) => v == null ? 'Required' : null)),
          ]),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _desc,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(fontSize: 14),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Please describe the issue (at least 10 characters)'
                  : null,
              decoration: const InputDecoration(
                  hintText: 'Provide a brief description of the issue...'),
            ),
          ),
          UploadTile(
              label: 'Photo (Optional)',
              hint: 'JPG or PNG, up to 5 MB',
              file: _photo,
              onPick: _pickPhoto),
          ErrorMessage(_error),
          Row(children: [
            Expanded(
                child: AppButton(
                    label: 'Cancel',
                    outlined: true,
                    onPressed: () => Navigator.of(context).pop())),
            const SizedBox(width: 10),
            Expanded(
                child: AppButton(
                    label: 'Submit', loading: _busy, onPressed: _submit)),
          ]),
        ]),
      ),
    );
  }
}

class MaintenanceSubmittedScreen extends StatelessWidget {
  const MaintenanceSubmittedScreen({super.key, required this.reference});
  final String reference;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Maintenance Request Submitted',
      showBack: false,
      child: SuccessView(
        message: 'Keep this reference to follow up on your request.',
        reference: reference,
        warning: null,
        primaryLabel: 'Back to Home',
        onPrimary: () => openShell(context),
        secondaryLabel: 'View Requests',
        onSecondary: () {
          final nav = Navigator.of(context);
          nav.popUntil((r) => r.isFirst);
          nav.push(
              MaterialPageRoute(builder: (_) => const MaintenanceListScreen()));
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF0D5),
              borderRadius: BorderRadius.circular(6)),
          child: const Text(
              'Management will review the issue and contact you if they need to arrange access. For urgent safety issues, contact management directly.',
              style: TextStyle(fontSize: 10)),
        ),
      ),
    );
  }
}

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({super.key, required this.request});
  final MaintenanceRequest request;

  @override
  Widget build(BuildContext context) {
    final r = request;
    return AuthScaffold(
      title: 'Maintenance Report',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(r.reference,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13))),
            StatusChip(r.status)
          ]),
          if (r.createdAt != null)
            Text('Submitted on ${fmtDate(r.createdAt!)}',
                style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          const Divider(height: 22),
          Text('Category: ${r.category}', style: const TextStyle(fontSize: 12)),
          Text('Priority: ${r.priority}', style: const TextStyle(fontSize: 12)),
          Text('Type: ${r.type}', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          const Text('Description',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          Text(r.description, style: const TextStyle(fontSize: 11)),
          if (r.photoPath != null && r.photoPath!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('Photo',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 6),
            FutureBuilder<String>(
              future: MaintenanceService().photoUrl(r.photoPath!),
              builder: (context, snap) => snap.hasData
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(snap.data!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Text('Photo unavailable.')))
                  : const SizedBox(
                      height: 40,
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange))),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF0D5),
                borderRadius: BorderRadius.circular(6)),
            child: Text(
                r.status.toLowerCase() == 'pending'
                    ? 'Your request has been received and is under review.'
                    : 'Current status: ${r.status}.',
                style: const TextStyle(fontSize: 10)),
          ),
        ]),
      ),
    );
  }
}
