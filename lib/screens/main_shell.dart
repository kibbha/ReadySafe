import 'package:flutter/material.dart';
import '../app/localizations.dart';
import 'emergency_screen.dart';
import 'first_aid_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'offline_maps_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [
    HomeScreen(),
    EmergencyScreen(),
    OfflineMapsScreen(),
    FirstAidScreen(),
    MoreScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t.get('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.phone_in_talk_outlined),
            selectedIcon: const Icon(Icons.phone_in_talk),
            label: t.get('emergencies'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: t.get('maps'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.health_and_safety_outlined),
            selectedIcon: const Icon(Icons.health_and_safety),
            label: t.get('firstAid'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: t.get('more'),
          ),
        ],
      ),
    );
  }
}
