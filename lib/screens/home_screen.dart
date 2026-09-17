import 'package:flutter/material.dart';
import '../app/app_scope.dart';
import '../app/localizations.dart';
import 'calculator_screen.dart';
import 'checklist_screen.dart';
import 'emergency_screen.dart';
import 'family_screen.dart';
import 'first_aid_screen.dart';
import 'guide_list_screen.dart';
import 'online_maps_screen.dart';
import 'placeholder_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final country = app.activeCountry!;
    final en = Localizations.localeOf(context).languageCode == 'en';
    final items = <_DashboardItem>[
      _DashboardItem(t.get('firstAid'), en ? 'Learn the essential actions' : 'Les gestes essentiels', Icons.health_and_safety_rounded, const FirstAidScreen(), const Color(0xffd92d36)),
      _DashboardItem(t.get('emergencies'), en ? 'Call the right service' : 'Appeler le bon service', Icons.phone_in_talk_rounded, const EmergencyScreen(), const Color(0xffd92d36)),
      _DashboardItem(en ? 'Maps' : 'Cartes', en ? 'Online safety map' : 'Carte de sécurité en ligne', Icons.map_rounded, const OnlineMapsScreen(), const Color(0xff087f83)),
      _DashboardItem(t.get('kit'), en ? 'Prepare the essentials' : 'Préparer l’essentiel', Icons.backpack_rounded, const ChecklistScreen(kit: true), const Color(0xffb7833f)),
      _DashboardItem(t.get('checklists'), en ? 'Stay ready' : 'Rester prêt', Icons.checklist_rounded, const ChecklistScreen(kit: false), const Color(0xff178a66)),
      _DashboardItem(t.get('disasters'), en ? 'Know how to react' : 'Savoir comment réagir', Icons.warning_amber_rounded, const GuideListScreen(kind: GuideKind.disasters), const Color(0xffdf7d43)),
      _DashboardItem(t.get('waterFood'), en ? 'Estimate your needs' : 'Estimer vos besoins', Icons.water_drop_rounded, const CalculatorScreen(), const Color(0xff3186c7)),
      _DashboardItem(t.get('family'), en ? 'Protect your household' : 'Protéger votre foyer', Icons.family_restroom_rounded, const FamilyScreen(), const Color(0xff8c6bc1)),
      _DashboardItem(t.get('contacts'), en ? 'People to reach quickly' : 'Vos proches à joindre', Icons.contact_phone_rounded, PlaceholderScreen(title: t.get('contacts'), icon: Icons.contact_phone_outlined, body: t.get('offline')), const Color(0xff087f83)),
      _DashboardItem(t.get('information'), en ? 'Reliable guidance' : 'Conseils fiables', Icons.menu_book_rounded, PlaceholderScreen(title: t.get('information'), icon: Icons.info_outline, body: t.get('medicalNotice')), const Color(0xff087f83)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 700;
          final horizontal = wide ? 32.0 : 18.0;
          final maxWidth = wide ? 1080.0 : 620.0;
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Header(title: t.get('title'), onSettings: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                const SizedBox(height: 18),
                _HeroCard(country: t.get(country.nameKey), flag: _flag(country.isoCode), travelMode: app.travelMode, subtitle: t.get('subtitle'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                const SizedBox(height: 24),
                Text(en ? 'Prepare. Protect. Act.' : 'Se préparer, protéger, agir', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xff172126), letterSpacing: -.5)),
                const SizedBox(height: 5),
                Text(en ? 'Everything useful for your safety, at a glance.' : 'Tout ce qui compte pour votre sécurité, en un coup d’œil.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xff617075), height: 1.35)),
                const SizedBox(height: 16),
              ]),
            )))),
            SliverPadding(padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 28), sliver: SliverToBoxAdapter(child: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: wide ? 3 : 2, childAspectRatio: wide ? 1.55 : 1.08, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemBuilder: (context, index) => _DashboardTile(item: items[index]),
            ))))),
          ]);
        }),
      ),
    );
  }

  String _flag(String code) => String.fromCharCodes(code.codeUnits.map((c) => c + 127397));
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onSettings});
  final String title;
  final VoidCallback onSettings;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xff087f83), borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Color(0x22087f83), blurRadius: 12, offset: Offset(0, 5))]), child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 27)),
    const SizedBox(width: 12),
    Expanded(child: Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: .5))),
    IconButton.filledTonal(onPressed: onSettings, tooltip: 'Paramètres', icon: const Icon(Icons.settings_outlined)),
  ]);
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.country, required this.flag, required this.travelMode, required this.subtitle, required this.onTap});
  final String country, flag, subtitle;
  final bool travelMode;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(28), child: Ink(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xffdff3ef), Color(0xfffff4df)], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: const Color(0xffcfe4df))),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PETITS GESTES, GRANDS IMPACTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.25, color: Color(0xff087f83))),
        const SizedBox(height: 10),
        Text(subtitle, maxLines: 2, style: const TextStyle(fontSize: 22, height: 1.12, fontWeight: FontWeight.w900, color: Color(0xff172126), letterSpacing: -.4)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .86), borderRadius: BorderRadius.circular(15)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(flag, style: const TextStyle(fontSize: 21)), const SizedBox(width: 8), Flexible(child: Text(country, style: const TextStyle(fontWeight: FontWeight.w800))), if (travelMode) ...[const SizedBox(width: 6), const Icon(Icons.flight_rounded, size: 17)]])),
      ])),
      const SizedBox(width: 14),
      Container(width: 104, height: 124, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .72), borderRadius: BorderRadius.circular(26)), child: const Stack(alignment: Alignment.center, children: [Positioned(bottom: 19, child: Icon(Icons.landscape_rounded, size: 76, color: Color(0xff9bc9b7))), Positioned(top: 16, right: 15, child: Icon(Icons.wb_sunny_rounded, size: 27, color: Color(0xffffb64c))), Positioned(bottom: 22, child: Icon(Icons.family_restroom_rounded, size: 43, color: Color(0xff087f83)))])),
    ]),
  ));
}

class _DashboardItem {
  const _DashboardItem(this.label, this.subtitle, this.icon, this.page, this.color);
  final String label, subtitle;
  final IconData icon;
  final Widget page;
  final Color color;
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({required this.item});
  final _DashboardItem item;
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(24), child: InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => item.page)),
    child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xffdfe8e8)), boxShadow: const [BoxShadow(color: Color(0x0d172126), blurRadius: 14, offset: Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: item.color.withValues(alpha: .11), borderRadius: BorderRadius.circular(15)), child: Icon(item.icon, color: item.color, size: 27)), const Spacer(), const Icon(Icons.arrow_outward_rounded, size: 18, color: Color(0xff9aa7aa))]),
      const Spacer(),
      Text(item.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, height: 1.08, fontWeight: FontWeight.w900, color: Color(0xff172126))),
      const SizedBox(height: 4),
      Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, height: 1.15, color: Color(0xff6c797d), fontWeight: FontWeight.w600)),
    ])),
  ));
}
