import 'package:flutter/material.dart';
import '../app/localizations.dart';
import 'emergency_screen.dart';
import 'first_aid_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'online_maps_screen.dart';

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
    OnlineMapsScreen(),
    FirstAidScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';
    final destinations = [
      (Icons.home_outlined, Icons.home, t.get('home')),
      (Icons.phone_in_talk_outlined, Icons.phone_in_talk, t.get('emergencies')),
      (Icons.map_outlined, Icons.map, en ? 'Maps' : 'Cartes'),
      (Icons.health_and_safety_outlined, Icons.health_and_safety, t.get('firstAid')),
      (Icons.more_horiz, Icons.more_horiz, t.get('more')),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 700;
        final content = IndexedStack(index: index, children: pages);

        if (!useRail) {
          return Scaffold(
            body: content,
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: [
                for (final item in destinations)
                  NavigationDestination(
                    icon: Icon(item.$1),
                    selectedIcon: Icon(item.$2),
                    label: item.$3,
                  ),
              ],
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            top: false,
            bottom: false,
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (value) => setState(() => index = value),
                  labelType: constraints.maxWidth >= 1000
                      ? NavigationRailLabelType.all
                      : NavigationRailLabelType.selected,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.health_and_safety_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  destinations: [
                    for (final item in destinations)
                      NavigationRailDestination(
                        icon: Icon(item.$1),
                        selectedIcon: Icon(item.$2),
                        label: Text(item.$3),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            ),
          ),
        );
      },
    );
  }
}
