import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/error_message.dart';
import '../../widgets/otp_input.dart';
import '../home/main_shell.dart';
import 'reset_password_screen.dart';

/// Used for both signup verification and password-recovery codes.
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.email, required this.type});
  final String email;
  final OtpType type;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _auth = AuthService();
  String _code = '';
  bool _loading = false;
  String? _error;
  String? _info;

  Future<void> _verify() async {
    if (_loading) return;
    if (_code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.verifyOtp(email: widget.email, code: _code, type: widget.type);
      if (!mounted) return;
      if (widget.type == OtpType.recovery) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
      }
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() { _error = null; _info = null; });
    try {
      if (widget.type == OtpType.recovery) {
        await _auth.sendRecoveryCode(widget.email);
      } else {
        await _auth.resendSignupCode(widget.email);
      }
      if (mounted) setState(() => _info = 'A new code has been sent.');
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: widget.type == OtpType.recovery ? 'Enter reset code' : 'Verify your email address',
      subtitle: 'Enter the 6-digit verification code sent to ${widget.email}',
      child: Column(
        children: [
          OtpInput(onChanged: (c) => _code = c),
          const SizedBox(height: 20),
          ErrorMessage(_error),
          if (_info != null)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_info!, style: const TextStyle(fontSize: 13))),
          AppButton(label: 'Verify', onPressed: _verify, loading: _loading),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Did not receive code? ', style: TextStyle(fontSize: 12, color: AppColors.muted)),
              GestureDetector(
                onTap: _resend,
                child: const Text('Resend code', style: TextStyle(fontSize: 12, color: AppColors.orange)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
