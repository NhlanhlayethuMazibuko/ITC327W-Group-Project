import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/routes/app_router.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;

      case 1:
        context.go(RouteNames.rooms);
        break;

      case 2:
        context.go(RouteNames.application);
        break;

      case 3:
        context.go(RouteNames.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,

      type: BottomNavigationBarType.fixed,

      selectedItemColor: const Color(0xFFFF9800),

      unselectedItemColor: Colors.grey,

      onTap: (index) {
        _navigate(context, index);
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

        BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Rooms'),

        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Application',
        ),

        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
