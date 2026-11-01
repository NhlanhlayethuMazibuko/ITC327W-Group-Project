import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../authentication/welcome_screen.dart';
import '../maintenance/maintenance_screens.dart';
import '../notifications/notifications_screen.dart';
import '../payments/payment_screens.dart';
import '../reviews/reviews_screen.dart';
import '../viewings/viewing_screens.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Key _key = UniqueKey();

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _editPhone(Student s) async {
    final c = TextEditingController(text: s.phone);
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Phone number'),
        content: TextField(controller: c, keyboardType: TextInputType.phone),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (value == null || value.isEmpty) return;
    try {
      await StudentService().update({'phone_number': value});
      if (mounted) setState(() => _key = UniqueKey());
    } catch (e) {
      if (mounted) _snack(friendlyError(e));
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
  }

  Widget _info(IconData icon, String label, String value, {VoidCallback? onEdit}) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ])),
          if (onEdit != null) IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: onEdit),
        ]),
      );

  Widget _link(IconData icon, String label, Widget screen) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 20, color: AppColors.orangeDark),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)),
      );

  @override
  Widget build(BuildContext context) {
    final email = AuthService().currentUser?.email ?? '';
    return InnerScaffold(
      title: 'Profile',
      showBack: false,
      child: LoadView<Student>(
        key: _key,
        loader: StudentService().requireStudent,
        builder: (context, s, reload) {
          final initials = s.fullName.trim().isEmpty ? '?' : s.fullName.trim().split(' ').take(2).map((p) => p[0].toUpperCase()).join();
          return ListView(padding: const EdgeInsets.all(20), children: [
            Row(children: [
              CircleAvatar(radius: 32, backgroundColor: AppColors.orange, child: Text(initials, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700))),
              const SizedBox(width: 16),
              Expanded(child: Text(s.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 20),
            _info(Icons.mail_outline, 'Email Address', email),
            _info(Icons.phone_outlined, 'Phone Number', s.phone, onEdit: () => _editPhone(s)),
            _info(Icons.school_outlined, 'Student number', s.studentNumber),
            const SizedBox(height: 6),
            _link(Icons.notifications_none, 'Notifications', const NotificationsScreen()),
            _link(Icons.event_outlined, 'Scheduled Viewings', const ViewingsScreen()),
            _link(Icons.build_outlined, 'Maintenance Requests', const MaintenanceListScreen()),
            _link(Icons.star_outline, 'Reviews & Feedback', const ReviewsScreen()),
            _link(Icons.payments_outlined, 'Payment', const PaymentScreen()),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline, size: 20),
              title: const Text('Change password', style: TextStyle(fontSize: 13)),
              onTap: () => showDialog(context: context, builder: (_) => const _PasswordDialog()),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, size: 20, color: AppColors.danger),
              title: const Text('Log out', style: TextStyle(fontSize: 13, color: AppColors.danger)),
              onTap: _logout,
            ),
          ]);
        },
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _p1 = TextEditingController(), _p2 = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final err = Validators.password(_p1.text) ?? Validators.confirm(_p2.text, _p1.text);
    if (err != null) { setState(() => _error = err); return; }
    setState(() { _busy = true; _error = null; });
    try {
      await AuthService().updatePassword(_p1.text);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated.')));
    } catch (e) {
      if (mounted) setState(() { _error = friendlyError(e); _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change password'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _p1, obscureText: true, decoration: const InputDecoration(hintText: 'New password')),
        const SizedBox(height: 10),
        TextField(controller: _p2, obscureText: true, decoration: const InputDecoration(hintText: 'Confirm new password')),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12))),
      ]),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: _busy ? null : _save, child: const Text('Save')),
      ],
    );
  }
}
