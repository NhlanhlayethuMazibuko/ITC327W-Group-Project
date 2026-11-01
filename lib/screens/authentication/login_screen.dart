import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/error_message.dart';
import '../home/main_shell.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'verify_otp_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType, AuthException;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.signIn(_email.text, _password.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.message.toLowerCase().contains('not confirmed')) {
        await _auth.resendSignupCode(_email.text);
        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VerifyOtpScreen(email: _email.text.trim(), type: OtpType.signup)));
      } else {
        setState(() => _error = AuthService.friendlyMessage(e));
      }
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome Back',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(controller: _email, hint: 'Email Address', icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress, validator: Validators.email),
            AppTextField(controller: _password, hint: 'Password', icon: Icons.lock_outline,
                isPassword: true, textInputAction: TextInputAction.done,
                validator: (v) => Validators.required(v, 'Password')),
            const SizedBox(height: 4),
            ErrorMessage(_error),
            AppButton(label: 'Log In', onPressed: _login, loading: _loading),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
              child: const Text('Forgot Password?', style: TextStyle(color: AppColors.orange, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? ", style: TextStyle(fontSize: 12)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Register', style: TextStyle(color: AppColors.orange, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
