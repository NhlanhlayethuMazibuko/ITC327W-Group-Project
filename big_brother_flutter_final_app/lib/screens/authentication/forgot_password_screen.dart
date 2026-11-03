import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/error_message.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.sendRecoveryCode(_email.text);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(email: _email.text.trim(), type: OtpType.recovery)));
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Forgot Your Password?',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(controller: _email, hint: 'Enter email address', icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.done,
                validator: Validators.email),
            ErrorMessage(_error),
            AppButton(label: 'Continue', onPressed: _send, loading: _loading),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, size: 14, color: AppColors.orange),
              label: const Text('Back to Login', style: TextStyle(color: AppColors.orange, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
