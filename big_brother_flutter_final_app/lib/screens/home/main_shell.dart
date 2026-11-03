import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../accommodation/rooms_tab.dart';
import '../applications/application_tab.dart';
import '../profile/profile_tab.dart';
import 'home_tab.dart';

/// Signed-in container with the 4-tab bottom navigation from the Figma design.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;
  final _query = ValueNotifier<String>('');

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: [
        HomeTab(
          onSearch: (q) { _query.value = q; setState(() => _index = 1); },
          onSeeAll: () { _query.value = ''; setState(() => _index = 1); },
          onOpenApplications: () => setState(() => _index = 2),
        ),
        RoomsTab(query: _query),
        const ApplicationTab(),
        const ProfileTab(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.text,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bed_outlined), label: 'Rooms Available'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Application'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Replaces the whole stack with the signed-in shell (optionally on a given tab).
void openShell(BuildContext context, {int tab = 0}) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => MainShell(initialIndex: tab)), (_) => false);
}
