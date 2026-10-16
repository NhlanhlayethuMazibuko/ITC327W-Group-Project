import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart';
import 'state.dart';
import 'ui.dart';

void _toShell(BuildContext c) {
  tabNotifier.value = 0;
  Navigator.pushAndRemoveUntil(c, MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
}

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.wait([app.restore(), Future.delayed(const Duration(seconds: 2))]).then((_) {
      if (!mounted) return;
      if (app.hasSession) {
        _toShell(context);
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Column(children: [
          WaveHeader(height: 200, child: SizedBox.shrink()),
          Expanded(child: Center(child: Logo(w: 310))),
          Tagline(),
        ]),
      );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  Widget _q(IconData i, String t, VoidCallback f) => Expanded(
        child: GestureDetector(
          onTap: f,
          child: Column(children: [
            CircleAvatar(radius: 34, backgroundColor: const Color(0xFFFBB75D), child: Icon(i, size: 34, color: Colors.black87)),
            const SizedBox(height: 6),
            Text(t, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ),
      );
  @override
  Widget build(BuildContext context) {
    void login() => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    return AuthShell(
      child: Column(children: [
        const SizedBox(height: 28),
        const Text('Welcome to Big Brother Student Accommodation', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 28),
        const Text('Find safe , affordable and convenient student accommodation with ease', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Color(0xFF374151))),
        const SizedBox(height: 26),
        OBtn('Log In', icon: Icons.arrow_forward, onTap: login),
        const SizedBox(height: 16),
        OBtn('Create New Account', outline: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()))),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _q(Icons.home_outlined, 'Find\naccommodation', login),
          _q(Icons.description_outlined, 'Submit\nApplications', login),
          _q(Icons.assignment_turned_in_outlined, 'Track Your\nApplication', login),
        ]),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final email = TextEditingController(), pw = TextEditingController();
  String? err;
  bool busy = false;

  Future<void> go() async {
    if (!_emailRe.hasMatch(email.text.trim()) || pw.text.isEmpty) {
      setState(() => err = 'Enter a valid email and password.');
      return;
    }
    setState(() { busy = true; err = null; });
    final e = await app.login(email.text.trim(), pw.text);
    if (!mounted) return;
    if (e == null) {
      _toShell(context);
    } else {
      setState(() { busy = false; err = e.startsWith('Incorrect') ? '*$e' : e; });
    }
  }

  @override
  Widget build(BuildContext context) => AuthShell(
        back: true,
        child: Column(children: [
          const SizedBox(height: 34),
          const Text('Welcome  Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Field('Email Address', Icons.mail_outline, controller: email, keyboard: TextInputType.emailAddress, error: err != null ? '' : null),
          const SizedBox(height: 16),
          Field('Password', Icons.lock_outline, controller: pw, obscure: true, error: err != null ? '' : null, onSubmitted: (_) => go()),
          if (err != null) Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 12, top: 4), child: Text(err!, style: const TextStyle(color: Colors.red)))),
          const SizedBox(height: 28),
          OBtn('Log In', loading: busy, onTap: go),
          const SizedBox(height: 16),
          GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotScreen())),
              child: const Text('Forgot  Password?', style: TextStyle(color: kOrange, fontWeight: FontWeight.w700, fontSize: 18))),
          const SizedBox(height: 56),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Don’t have an account? ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Register', style: TextStyle(color: kOrange, fontWeight: FontWeight.w700, fontSize: 16))),
          ]),
          const SizedBox(height: 16),
        ]),
      );
}

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});
  @override
  State<ForgotScreen> createState() => _ForgotState();
}

class _ForgotState extends State<ForgotScreen> {
  final email = TextEditingController();
  bool busy = false;
  Future<void> go() async {
    if (!_emailRe.hasMatch(email.text.trim())) return toast(context, 'Please enter a valid email address.');
    setState(() => busy = true);
    final e = await app.sendReset(email.text.trim());
    if (!mounted) return;
    setState(() => busy = false);
    if (e != null) return toast(context, e);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyScreen(recovery: true)));
  }

  @override
  Widget build(BuildContext context) => AuthShell(
        back: true,
        headerHeight: 210,
        child: Column(children: [
          const SizedBox(height: 40),
          const Text('Forgot Your Password?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          Field('Enter email address', Icons.mail_outline, controller: email, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 28),
          OBtn('Continue', loading: busy, onTap: go),
          const SizedBox(height: 28),
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.arrow_back), SizedBox(width: 8), Text('Back to log in', style: TextStyle(fontSize: 18))])),
        ]),
      );
}

class VerifyScreen extends StatefulWidget {
  final bool recovery;
  const VerifyScreen({super.key, this.recovery = false});
  @override
  State<VerifyScreen> createState() => _VerifyState();
}

class _VerifyState extends State<VerifyScreen> {
  final cs = List.generate(6, (_) => TextEditingController());
  final fs = List.generate(6, (_) => FocusNode());
  bool busy = false;

  Future<void> go() async {
    setState(() => busy = true);
    final e = await app.verify(cs.map((c) => c.text).join(), recovery: widget.recovery);
    if (!mounted) return;
    setState(() => busy = false);
    if (e != null) return toast(context, e);
    if (widget.recovery) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResetScreen()));
    } else {
      _toShell(context);
    }
  }

  @override
  Widget build(BuildContext context) => AuthShell(
        back: true,
        headerHeight: 210,
        child: Column(children: [
          const SizedBox(height: 34),
          const Text('Verify your email address', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Enter the 6-digit verification code', style: TextStyle(fontSize: 17)),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (var i = 0; i < 6; i++)
              SizedBox(
                width: 46,
                height: 60,
                child: TextField(
                  controller: cs[i],
                  focusNode: fs[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(counterText: '', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kOrange, width: 2))),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) fs[i + 1].requestFocus();
                    if (v.isEmpty && i > 0) fs[i - 1].requestFocus();
                  },
                ),
              ),
          ]),
          const SizedBox(height: 28),
          OBtn('Verify', loading: busy, onTap: go),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Did not receive code? ', style: TextStyle(color: Colors.grey, fontSize: 16)),
            GestureDetector(
                onTap: () { app.resend(recovery: widget.recovery); toast(context, 'A new code has been sent.'); },
                child: const Text('Resend code', style: TextStyle(color: kOrange, fontSize: 16))),
          ]),
        ]),
      );
}

class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key});
  @override
  State<ResetScreen> createState() => _ResetState();
}

class _ResetState extends State<ResetScreen> {
  final a = TextEditingController(), b = TextEditingController();
  bool busy = false;
  Future<void> go() async {
    if (a.text.length < 8) return toast(context, 'Password must be at least 8 characters.');
    if (a.text != b.text) return toast(context, 'Passwords do not match.');
    setState(() => busy = true);
    final e = await app.setNewPassword(a.text);
    if (!mounted) return;
    setState(() => busy = false);
    if (e != null) return toast(context, e);
    toast(context, 'Password updated. Please log in.');
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) => AuthShell(
        child: Column(children: [
          const SizedBox(height: 34),
          const Text('Reset Password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 22),
          Field('Enter new password', Icons.lock_outline, controller: a, obscure: true),
          const SizedBox(height: 22),
          Field('Confirm new password', Icons.lock_outline, controller: b, obscure: true),
          const SizedBox(height: 28),
          OBtn('Continue', loading: busy, onTap: go),
        ]),
      );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  final n = TextEditingController(), e = TextEditingController(), s = TextEditingController(), p = TextEditingController(), c = TextEditingController();
  bool busy = false;
  Future<void> go() async {
    if (n.text.trim().isEmpty || s.text.trim().isEmpty) return toast(context, 'Please complete all fields.');
    if (!_emailRe.hasMatch(e.text.trim())) return toast(context, 'Please enter a valid email address.');
    if (p.text.length < 8) return toast(context, 'Password must be at least 8 characters.');
    if (p.text != c.text) return toast(context, 'Passwords do not match.');
    setState(() => busy = true);
    final err = await app.register(n.text.trim(), e.text.trim(), s.text.trim(), p.text);
    if (!mounted) return;
    setState(() => busy = false);
    if (err != null) return toast(context, err);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyScreen()));
  }

  @override
  Widget build(BuildContext context) => AuthShell(
        back: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 24),
          const Text('Create Account', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Field('Full Name', Icons.person_outline, controller: n),
          const SizedBox(height: 14),
          Field('Email Address', Icons.mail_outline, controller: e, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 14),
          Field('Student Number', Icons.school_outlined, controller: s, keyboard: TextInputType.number),
          const SizedBox(height: 14),
          Field('Password', Icons.lock_outline, controller: p, obscure: true),
          const SizedBox(height: 14),
          Field('Confirm Password', Icons.lock_outline, controller: c, obscure: true),
          const SizedBox(height: 24),
          OBtn('Register', loading: busy, onTap: go),
          const SizedBox(height: 14),
          Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('Already have  an account? ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Log In', style: TextStyle(color: kOrange, fontWeight: FontWeight.w700, fontSize: 16))),
          ])),
          const SizedBox(height: 16),
        ]),
      );
}
