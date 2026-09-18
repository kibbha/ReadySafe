import 'package:flutter/material.dart';
import '../app/localizations.dart';
import 'first_aid_screen.dart';
import 'guided_emergency_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'prepare_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    GuidedEmergencyScreen(),
    PrepareScreen(),
    FirstAidScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';
    final destinations = [
      (Icons.home_outlined, Icons.home, t.get('home')),
      (Icons.sos_outlined, Icons.sos_rounded, en ? 'Emergency' : 'Urgence'),
      (Icons.shield_outlined, Icons.shield_rounded, en ? 'Prepare' : 'Préparer'),
      (Icons.health_and_safety_outlined, Icons.health_and_safety, t.get('firstAid')),
      (Icons.more_horiz, Icons.more_horiz, t.get('more')),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = IndexedStack(index: index, children: pages);
        final useRail = constraints.maxWidth >= 700;
        final extendedRail = constraints.maxWidth >= 980;

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
                  extended: extendedRail,
                  minWidth: 76,
                  minExtendedWidth: 205,
                  labelType: extendedRail ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                  groupAlignment: -0.72,
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 18, 10, 22),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xff087f83),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        if (extendedRail) ...[
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ReadySafe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                              Text('ÊTRE PRÊT. AGIR.', style: TextStyle(fontSize: 9.5, letterSpacing: 1.1, color: Color(0xff718084), fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  destinations: [
                    for (final item in destinations)
                      NavigationRailDestination(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        icon: Icon(item.$1),
                        selectedIcon: Icon(item.$2),
                        label: Text(item.$3, style: const TextStyle(fontWeight: FontWeight.w800)),
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
