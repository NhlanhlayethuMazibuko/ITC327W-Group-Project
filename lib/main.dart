import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BigBrotherApp());
}

class BigBrotherApp extends StatelessWidget {
  const BigBrotherApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Big Brother Student Accommodation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      );
}
