import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import 'checklist_screen.dart';
import 'emergency_screen.dart';
import 'first_aid_screen.dart';
import 'guided_emergency_screen.dart';
import 'prepare_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final country = app.activeCountry!;
    final en = Localizations.localeOf(context).languageCode == 'en';

    final actions = <_HomeAction>[
      _HomeAction(
        t.get('firstAid'),
        en ? '10 essential visual guides' : '10 fiches visuelles essentielles',
        Icons.health_and_safety_rounded,
        const FirstAidScreen(),
        const Color(0xffd92d36),
      ),
      _HomeAction(
        en ? 'Prepare' : 'Préparer',
        en ? 'Plans, kit and checklists' : 'Plans, kit et check-lists',
        Icons.shield_rounded,
        const PrepareScreen(),
        const Color(0xff087f83),
      ),
      _HomeAction(
        t.get('kit'),
        en ? 'Check the essentials' : 'Vérifier les essentiels',
        Icons.backpack_rounded,
        const ChecklistScreen(kit: true),
        const Color(0xffb7833f),
      ),
      _HomeAction(
        en ? 'SOS contacts' : 'Contacts SOS',
        en ? 'Official emergency numbers' : 'Numéros officiels du pays',
        Icons.phone_in_talk_rounded,
        const EmergencyScreen(),
        const Color(0xffd92d36),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final horizontal = wide ? 28.0 : 16.0;
            final maxWidth = 1080.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 30),
                  children: [
                    _Header(
                      title: t.get('title'),
                      country: t.get(country.nameKey),
                      flag: _flag(country.isoCode),
                      travelMode: app.travelMode,
                      onSettings: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _EmergencyHero(
                      en: en,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GuidedEmergencyScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          en ? 'Essentials' : 'Essentiels',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xffe7f3f1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.offline_bolt_rounded, size: 16, color: Color(0xff087f83)),
                              const SizedBox(width: 5),
                              Text(
                                en ? 'Offline ready' : 'Hors ligne',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xff075e68)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actions.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: wide ? 2 : 2,
                        mainAxisExtent: wide ? 166 : 146,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) => _ActionCard(action: actions[index]),
                    ),
                    const SizedBox(height: 18),
                    _PreparednessCard(
                      en: en,
                      onPrepare: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrepareScreen()),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      en ? 'Quick access' : 'Accès rapide',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        _QuickChip(
                          label: en ? 'Adult CPR' : 'RCP adulte',
                          icon: Icons.favorite_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen())),
                        ),
                        _QuickChip(
                          label: 'DAE',
                          icon: Icons.electric_bolt_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen())),
                        ),
                        _QuickChip(
                          label: en ? 'Severe bleeding' : 'Hémorragie',
                          icon: Icons.bloodtype_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen())),
                        ),
                        _QuickChip(
                          label: en ? 'Guide me' : 'Guidez-moi',
                          icon: Icons.sos_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidedEmergencyScreen())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _flag(String code) =>
      String.fromCharCodes(code.codeUnits.map((c) => c + 127397));
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.country,
    required this.flag,
    required this.travelMode,
    required this.onSettings,
  });

  final String title;
  final String country;
  final String flag;
  final bool travelMode;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xff087f83),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        country,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xff65747a), fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (travelMode) const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.flight_rounded, size: 15, color: Color(0xff087f83)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onSettings,
            tooltip: 'Paramètres',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      );
}

class _EmergencyHero extends StatelessWidget {
  const _EmergencyHero({required this.en, required this.onTap});
  final bool en;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(Icons.sos_rounded, color: Colors.white, size: 31),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en ? 'EMERGENCY — GUIDE ME' : 'URGENCE — GUIDEZ-MOI',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        en ? 'One clear path according to what you observe.' : 'Un parcours clair selon ce que vous observez.',
                        style: TextStyle(color: Colors.white.withValues(alpha: .91), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      );
}

class _PreparednessCard extends StatelessWidget {
  const _PreparednessCard({required this.en, required this.onPrepare});
  final bool en;
  final VoidCallback onPrepare;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPrepare,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xffe4f2f0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.fact_check_outlined, color: Color(0xff087f83)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en ? 'My preparation' : 'Ma préparation',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        en
                            ? 'Family plan · 72 h kit · checklists · training'
                            : 'Plan familial · kit 72 h · check-lists · entraînement',
                        style: const TextStyle(color: Color(0xff65747a), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      );
}

class _HomeAction {
  const _HomeAction(this.label, this.subtitle, this.icon, this.page, this.color);
  final String label;
  final String subtitle;
  final IconData icon;
  final Widget page;
  final Color color;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});
  final _HomeAction action;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action.page)),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffdde7e5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(action.icon, color: action.color, size: 27),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xff65747a), height: 1.2),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xff87969a)),
              ],
            ),
          ),
        ),
      );
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        avatar: Icon(icon, size: 18, color: const Color(0xff087f83)),
        label: Text(label),
        onPressed: onTap,
      );
}
