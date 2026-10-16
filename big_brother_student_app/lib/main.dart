import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth.dart';
import 'config.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Config.configured) {
    await Supabase.initialize(url: Config.url, anonKey: Config.anonKey);
  }
  runApp(const BigBrotherApp());
}

class BigBrotherApp extends StatelessWidget {
  const BigBrotherApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Big Brother Student Accommodation',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kOrange, primary: kOrange),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
      );
}
