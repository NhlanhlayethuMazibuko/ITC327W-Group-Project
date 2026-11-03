import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/error_message.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.updatePassword(_password.text);
      await _auth.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated. Please log in.')));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset Password',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(controller: _password, hint: 'Enter new password', icon: Icons.lock_outline,
                isPassword: true, validator: Validators.password),
            AppTextField(controller: _confirm, hint: 'Confirm new password', icon: Icons.lock_outline,
                isPassword: true, textInputAction: TextInputAction.done,
                validator: (v) => Validators.confirm(v, _password.text)),
            ErrorMessage(_error),
            AppButton(label: 'Continue', onPressed: _save, loading: _loading),
          ],
        ),
      ),
    );
  }
}
