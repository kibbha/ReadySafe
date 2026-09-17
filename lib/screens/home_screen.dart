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
    final primary = Theme.of(context).colorScheme.primary;
    final items = <_DashboardItem>[
      _DashboardItem(t.get('firstAid'), Icons.health_and_safety_rounded, const FirstAidScreen(), const Color(0xffd92d36)),
      _DashboardItem(t.get('emergencies'), Icons.phone_in_talk_rounded, const EmergencyScreen(), const Color(0xffe04b45)),
      _DashboardItem(t.get('maps'), Icons.map_rounded, const OnlineMapsScreen(), const Color(0xff087f83)),
      _DashboardItem(t.get('kit'), Icons.backpack_rounded, const ChecklistScreen(kit: true), const Color(0xffb37b31)),
      _DashboardItem(t.get('checklists'), Icons.checklist_rounded, const ChecklistScreen(kit: false), const Color(0xff178a66)),
      _DashboardItem(t.get('disasters'), Icons.warning_amber_rounded, const GuideListScreen(kind: GuideKind.disasters), const Color(0xffe67e35)),
      _DashboardItem(t.get('waterFood'), Icons.water_drop_rounded, const CalculatorScreen(), const Color(0xff3186c7)),
      _DashboardItem(t.get('family'), Icons.family_restroom_rounded, const FamilyScreen(), const Color(0xff8c6bc1)),
      _DashboardItem(t.get('contacts'), Icons.contact_phone_rounded, PlaceholderScreen(title: t.get('contacts'), icon: Icons.contact_phone_outlined, body: t.get('offline')), primary),
      _DashboardItem(t.get('information'), Icons.menu_book_rounded, PlaceholderScreen(title: t.get('information'), icon: Icons.info_outline, body: t.get('medicalNotice')), primary),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff6f9f9),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            final horizontal = wide ? 32.0 : 18.0;
            final maxWidth = wide ? 1050.0 : 620.0;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Header(
                              title: t.get('title'),
                              onSettings: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                            ),
                            const SizedBox(height: 18),
                            _HeroCard(
                              country: t.get(country.nameKey),
                              flag: _flag(country.isoCode),
                              travelMode: app.travelMode,
                              subtitle: t.get('subtitle'),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                            ),
                            const SizedBox(height: 22),
                            Text('Se préparer, protéger, agir', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xff172126))),
                            const SizedBox(height: 6),
                            Text('Tout ce dont vous avez besoin pour votre sécurité, en un coup d’œil.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xff617075))),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 26),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 210,
                            mainAxisExtent: 132,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) => _DashboardTile(item: items[index]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: const Color(0xff087f83), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: .2))),
          IconButton.filledTonal(onPressed: onSettings, tooltip: 'Paramètres', icon: const Icon(Icons.settings_outlined)),
        ],
      );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.country, required this.flag, required this.travelMode, required this.subtitle, required this.onTap});
  final String country;
  final String flag;
  final bool travelMode;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(colors: [Color(0xffe6f4f1), Color(0xfffff6e8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: const Color(0xffd7e7e4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PETITS GESTES, GRANDS IMPACTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: Color(0xff087f83))),
                    const SizedBox(height: 10),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, height: 1.15, fontWeight: FontWeight.w900, color: Color(0xff172126))),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .8), borderRadius: BorderRadius.circular(14)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [Text(flag, style: const TextStyle(fontSize: 21)), const SizedBox(width: 8), Flexible(child: Text(country, style: const TextStyle(fontWeight: FontWeight.w800))), if (travelMode) ...[const SizedBox(width: 6), const Icon(Icons.flight_rounded, size: 17)]]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 92,
                height: 112,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .72), borderRadius: BorderRadius.circular(24)),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(bottom: 18, child: Icon(Icons.landscape_rounded, size: 66, color: Color(0xff9bc9b7))),
                    Positioned(top: 17, right: 16, child: Icon(Icons.wb_sunny_rounded, size: 25, color: Color(0xffffb64c))),
                    Positioned(bottom: 20, child: Icon(Icons.family_restroom_rounded, size: 38, color: Color(0xff087f83))),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _DashboardItem {
  const _DashboardItem(this.label, this.icon, this.page, this.color);
  final String label;
  final IconData icon;
  final Widget page;
  final Color color;
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({required this.item});
  final _DashboardItem item;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => item.page)),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xffe2e9ea))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 45, height: 45, decoration: BoxDecoration(color: item.color.withValues(alpha: .11), borderRadius: BorderRadius.circular(14)), child: Icon(item.icon, color: item.color, size: 27)),
                const Spacer(),
                Text(item.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, height: 1.1, fontWeight: FontWeight.w800, color: Color(0xff172126))),
              ],
            ),
          ),
        ),
      );
}
