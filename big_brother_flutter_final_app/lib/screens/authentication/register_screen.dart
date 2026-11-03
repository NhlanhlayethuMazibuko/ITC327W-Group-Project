import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/error_message.dart';
import '../home/main_shell.dart';
import 'login_screen.dart';
import 'verify_otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _studentNumber = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _studentNumber, _password, _confirm]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _auth.signUp(
        email: _email.text,
        password: _password.text,
        fullName: _name.text,
        studentNumber: _studentNumber.text,
      );
      if (!mounted) return;
      // Supabase hides duplicate emails by returning a user with no identities.
      if (res.user != null && (res.user!.identities?.isEmpty ?? false)) {
        setState(() => _error = 'An account with this email already exists.');
        return;
      }
      if (res.session != null) {
        // Email confirmation is switched off in the shared project.
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VerifyOtpScreen(email: _email.text.trim(), type: OtpType.signup)));
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
      title: 'Create Account',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(controller: _name, hint: 'Full Name', icon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'Full name')),
            AppTextField(controller: _email, hint: 'Email Address', icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress, validator: Validators.email),
            AppTextField(controller: _studentNumber, hint: 'Student Number', icon: Icons.school_outlined,
                keyboardType: TextInputType.number, validator: (v) => Validators.required(v, 'Student number')),
            AppTextField(controller: _password, hint: 'Password', icon: Icons.lock_outline,
                isPassword: true, validator: Validators.password),
            AppTextField(controller: _confirm, hint: 'Confirm Password', icon: Icons.lock_outline,
                isPassword: true, textInputAction: TextInputAction.done,
                validator: (v) => Validators.confirm(v, _password.text)),
            ErrorMessage(_error),
            AppButton(label: 'Register', onPressed: _register, loading: _loading),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? ', style: TextStyle(fontSize: 12)),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Log In', style: TextStyle(color: AppColors.orange, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
