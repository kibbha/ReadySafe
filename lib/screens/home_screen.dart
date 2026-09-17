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
      _HomeAction(t.get('firstAid'), en ? 'Offline essential guides' : 'Fiches essentielles hors ligne', Icons.health_and_safety_rounded, const FirstAidScreen(), const Color(0xffd92d36)),
      _HomeAction(en ? 'Prepare' : 'Préparer', en ? 'Plans, kit, checklists' : 'Plans, kit, check-lists', Icons.shield_rounded, const PrepareScreen(), const Color(0xff087f83)),
      _HomeAction(t.get('kit'), en ? 'Check your essentials' : 'Vérifier les essentiels', Icons.backpack_rounded, const ChecklistScreen(kit: true), const Color(0xffb7833f)),
      _HomeAction(en ? 'SOS numbers' : 'Contacts SOS', en ? 'Official numbers for this country' : 'Numéros officiels du pays', Icons.phone_in_talk_rounded, const EmergencyScreen(), const Color(0xffd92d36)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final horizontal = wide ? 30.0 : 16.0;
            final maxWidth = wide ? 1060.0 : 640.0;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 28),
                  children: [
                    _Header(
                      title: t.get('title'),
                      country: t.get(country.nameKey),
                      flag: _flag(country.isoCode),
                      travelMode: app.travelMode,
                      onSettings: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                    const SizedBox(height: 16),
                    _StatusCard(en: en, travelMode: app.travelMode, country: t.get(country.nameKey)),
                    const SizedBox(height: 14),
                    _EmergencyHero(
                      en: en,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidedEmergencyScreen())),
                    ),
                    const SizedBox(height: 20),
                    Text(en ? 'Essentials' : 'Essentiels', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actions.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: wide ? 4 : 2,
                        childAspectRatio: wide ? 1.2 : 1.02,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) => _ActionCard(action: actions[index]),
                    ),
                    const SizedBox(height: 18),
                    _PreparednessCard(en: en),
                    const SizedBox(height: 18),
                    Text(en ? 'Quick access' : 'Accès rapide', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        _QuickChip(label: en ? 'Adult CPR' : 'RCP adulte', icon: Icons.favorite_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen()))),
                        _QuickChip(label: 'DAE', icon: Icons.electric_bolt_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen()))),
                        _QuickChip(label: en ? 'Severe bleeding' : 'Hémorragie', icon: Icons.bloodtype_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen()))),
                        _QuickChip(label: en ? 'Guide me' : 'Guidez-moi', icon: Icons.sos_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidedEmergencyScreen()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(Icons.offline_bolt_rounded, size: 18, color: Color(0xff087f83)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(en ? 'Essential first-aid content remains available offline.' : 'Les contenus essentiels de premiers secours restent disponibles hors ligne.', style: const TextStyle(fontSize: 12, color: Color(0xff65747a)))),
                    ]),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _flag(String code) => String.fromCharCodes(code.codeUnits.map((c) => c + 127397));
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.country, required this.flag, required this.travelMode, required this.onSettings});
  final String title;
  final String country;
  final String flag;
  final bool travelMode;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xff087f83), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 27)),
    const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      Text('$flag $country${travelMode ? ' · ✈' : ''}', style: const TextStyle(fontSize: 12, color: Color(0xff65747a), fontWeight: FontWeight.w700)),
    ])),
    IconButton.filledTonal(onPressed: onSettings, tooltip: 'Paramètres', icon: const Icon(Icons.settings_outlined)),
  ]);
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.en, required this.travelMode, required this.country});
  final bool en;
  final bool travelMode;
  final String country;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: const Color(0xffeaf5f2), borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      const Icon(Icons.verified_outlined, color: Color(0xff087f83)),
      const SizedBox(width: 10),
      Expanded(child: Text(
        travelMode
          ? (en ? 'Travel mode active — $country' : 'Mode voyage actif — $country')
          : (en ? 'ReadySafe essential mode ready' : 'Mode essentiel ReadySafe prêt'),
        style: const TextStyle(fontWeight: FontWeight.w800),
      )),
    ]),
  );
}

class _EmergencyHero extends StatelessWidget {
  const _EmergencyHero({required this.en, required this.onTap});
  final bool en;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.error,
    borderRadius: BorderRadius.circular(26),
    child: InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.sos_rounded, color: Colors.white, size: 34)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(en ? 'EMERGENCY — GUIDE ME' : 'URGENCE — GUIDEZ-MOI', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(en ? 'Choose what you see and open the right guidance.' : 'Choisissez ce que vous observez et ouvrez le bon guidage.', style: TextStyle(color: Colors.white.withValues(alpha: .9), height: 1.3)),
          ])),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ]),
      ),
    ),
  );
}

class _PreparednessCard extends StatelessWidget {
  const _PreparednessCard({required this.en});
  final bool en;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.fact_check_outlined, color: Color(0xff087f83)),
          const SizedBox(width: 8),
          Text(en ? 'My preparation' : 'Ma préparation', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 12),
        _PrepLine(icon: Icons.family_restroom_rounded, text: en ? 'Family profile available offline' : 'Profil familial disponible hors ligne'),
        _PrepLine(icon: Icons.backpack_rounded, text: en ? '72-hour kit can be checked item by item' : 'Kit 72 h vérifiable élément par élément'),
        _PrepLine(icon: Icons.offline_bolt_rounded, text: en ? 'First-aid guides available without network' : 'Fiches de secours disponibles sans réseau'),
      ]),
    ),
  );
}

class _PrepLine extends StatelessWidget {
  const _PrepLine({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Icon(icon, size: 19, color: const Color(0xff087f83)),
      const SizedBox(width: 9),
      Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700))),
    ]),
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
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action.page)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xffdde7e5))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 45, height: 45, decoration: BoxDecoration(color: action.color.withValues(alpha: .11), borderRadius: BorderRadius.circular(14)), child: Icon(action.icon, color: action.color)),
          const Spacer(),
          Text(action.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(action.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Color(0xff65747a), height: 1.2)),
        ]),
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
