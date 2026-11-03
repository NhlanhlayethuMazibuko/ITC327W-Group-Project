import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../payments/payment_screens.dart';
import 'application_form_screen.dart';

class _TabData {
  const _TabData(this.app, this.docs);
  final Application? app;
  final List<DocumentItem> docs;
}

class ApplicationTab extends StatefulWidget {
  const ApplicationTab({super.key});

  @override
  State<ApplicationTab> createState() => _ApplicationTabState();
}

class _ApplicationTabState extends State<ApplicationTab> {
  Key _key = UniqueKey();

  Future<_TabData> _load() async {
    final app = await ApplicationService().latest();
    if (app == null) return const _TabData(null, []);
    return _TabData(app, await ApplicationService().documents(app.id));
  }

  Future<void> _upload(Application app, String type) async {
    try {
      final f = await StorageService().pick();
      if (f == null) return;
      await ApplicationService().uploadDocument(app.id, type, f);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$type uploaded.')));
      setState(() => _key = UniqueKey());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  Future<void> _edit(Application app) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ApplicationFormScreen(editing: app)));
    if (saved == true && mounted) setState(() => _key = UniqueKey());
  }

  Future<void> _delete(Application app) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete application?'),
        content: Text('Application ${app.number} and its documents will be removed. You can apply again afterwards.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep it')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApplicationService().delete(app);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application deleted.')));
      setState(() => _key = UniqueKey());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  void _pendingSheet(Application app, List<String> pending) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Upload a document', style: TextStyle(fontWeight: FontWeight.w700))),
          for (final t in pending)
            ListTile(
              leading: const Icon(Icons.upload_file, color: AppColors.orange),
              title: Text(t, style: const TextStyle(fontSize: 13)),
              onTap: () { Navigator.pop(ctx); _upload(app, t); },
            ),
        ]),
      ),
    );
  }

  Widget _timeline(String status) {
    const steps = ['Submitted', 'Under Review', 'Approved'];
    final rejected = status == 'Rejected';
    // A tenant who moved out went through every step
    final current = status == 'Moved Out' ? 2 : rejected ? 1 : steps.indexOf(status).clamp(0, 2);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < 3; i++) ...[
        if (i > 0) Expanded(child: Padding(padding: const EdgeInsets.only(top: 10), child: Container(height: 2, color: i <= current ? AppColors.orange : AppColors.border))),
        SizedBox(
          width: 70,
          child: Column(children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: (rejected && i == 2) ? AppColors.danger : (i <= current ? AppColors.orange : AppColors.border),
              child: Icon((rejected && i == 2) ? Icons.close : (i <= current ? Icons.check : Icons.circle), size: 12, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text((rejected && i == 2) ? 'Rejected' : steps[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: i <= current ? AppColors.text : AppColors.muted)),
          ]),
        ),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return InnerScaffold(
      title: 'Application',
      showBack: false,
      child: LoadView<_TabData>(
        key: _key,
        loader: _load,
        builder: (context, data, reload) {
          final app = data.app;
          if (app == null) {
            return const EmptyState(icon: Icons.description_outlined, message: 'You have not applied yet.\nOpen Rooms Available, choose a unit and tap Apply Now.');
          }
          final uploaded = data.docs.map((d) => d.type).toSet();
          final pending = kDocTypes.where((t) => !uploaded.contains(t)).toList();
          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: reload,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Application Status Tracker', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFFFF0D5), borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Application Number', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(app.number, style: const TextStyle(fontSize: 12)),
                    if (app.roomName.isNotEmpty) Text('Unit: ${app.roomName}', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 10),
                    if (pending.isNotEmpty) ...[
                      const Text('Pending Documents :', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      for (final t in pending) Padding(padding: const EdgeInsets.only(top: 4), child: Text('- $t', style: const TextStyle(fontSize: 12))),
                      const SizedBox(height: 10),
                      SizedBox(height: 30, child: ElevatedButton(
                        onPressed: () => _pendingSheet(app, pending),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, elevation: 0),
                        child: const Text('Upload Documents', style: TextStyle(fontSize: 11)),
                      )),
                    ] else
                      const Text('All documents received.', style: TextStyle(fontSize: 12)),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(children: [const Text('Status time line', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), const Spacer(), StatusChip(app.statusName)]),
                const SizedBox(height: 14),
                _timeline(app.statusName),
                if (app.statusId == kStatusMovedOut || app.statusId == kStatusRejected) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      app.statusId == kStatusMovedOut
                          ? "You've moved out of ${app.roomName.isEmpty ? 'your room' : app.roomName}. ${app.staffNote ?? ''}\nYou're welcome to apply again or book a viewing from Rooms Available."
                          : "This application was declined. ${app.staffNote ?? ''}\nYou can apply for another available room from Rooms Available.",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                if (ApplicationService.canChange(app)) ...[
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: AppButton(label: 'Edit', icon: Icons.edit_outlined, outlined: true, onPressed: () => _edit(app))),
                    const SizedBox(width: 10),
                    Expanded(child: AppButton(label: 'Delete', icon: Icons.delete_outline, outlined: true, onPressed: () => _delete(app))),
                  ]),
                  const SizedBox(height: 6),
                  const Text('You can change or withdraw your application until management starts reviewing it.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.muted)),
                ],
                if (app.statusName == 'Approved') ...[
                  const SizedBox(height: 24),
                  AppButton(label: 'View Payment', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentScreen()))),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
