import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/room_viewmodel.dart';
//import '../../views/rooms/available_rooms_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),

        ChangeNotifierProvider(create: (_) => HomeViewModel()),

        ChangeNotifierProvider(create: (_) => RoomViewModel()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,

        title: 'Big Brother Student Accommodation',

        routerConfig: AppRouter.router,
      ),
    );
  }
}
