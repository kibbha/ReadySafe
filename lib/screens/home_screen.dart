import 'package:flutter/material.dart';
import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../widgets/section_card.dart';
import 'calculator_screen.dart';
import 'checklist_screen.dart';
import 'emergency_screen.dart';
import 'family_screen.dart';
import 'first_aid_screen.dart';
import 'guide_list_screen.dart';
import 'offline_maps_screen.dart';
import 'placeholder_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context),
        app = AppScope.of(context),
        country = app.activeCountry!;
    final items = [
      (
        t.get('emergencies'),
        Icons.phone_in_talk,
        const EmergencyScreen(),
        Colors.red.shade700,
      ),
      (
        t.get('firstAid'),
        Icons.health_and_safety_outlined,
        const FirstAidScreen(),
        Colors.red.shade700,
      ),
      (
        t.get('disasters'),
        Icons.thunderstorm_outlined,
        const GuideListScreen(kind: GuideKind.disasters),
        Theme.of(context).colorScheme.primary,
      ),
      (
        t.get('kit'),
        Icons.backpack_outlined,
        const ChecklistScreen(kit: true),
        Theme.of(context).colorScheme.primary,
      ),
      (
        t.get('checklists'),
        Icons.checklist_rounded,
        const ChecklistScreen(kit: false),
        Theme.of(context).colorScheme.primary,
      ),
      (
        t.get('waterFood'),
        Icons.water_drop_outlined,
        const CalculatorScreen(),
        Theme.of(context).colorScheme.primary,
      ),
      (
        t.get('family'),
        Icons.family_restroom_outlined,
        const FamilyScreen(),
        Theme.of(context).colorScheme.primary,
      ),
      (
        t.get('contacts'),
        Icons.contact_phone_outlined,
        PlaceholderScreen(
          title: t.get('contacts'),
          icon: Icons.contact_phone_outlined,
          body: t.get('offline'),
        ),
        Theme.of(context).colorScheme.primary,
      ),
      (
        t.get('maps'),
        Icons.map_outlined,
        const OfflineMapsScreen(),
        Theme.of(context).colorScheme.primary,
      ),
      (
        t.get('information'),
        Icons.info_outline,
        PlaceholderScreen(
          title: t.get('information'),
          icon: Icons.info_outline,
          body: t.get('medicalNotice'),
        ),
        Theme.of(context).colorScheme.primary,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.get('title'),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: t.get('settings'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              t.get('subtitle'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: app.travelMode
                  ? Theme.of(context).colorScheme.tertiaryContainer
                  : null,
              child: ListTile(
                leading: Text(
                  _flag(country.isoCode),
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(
                  t.get(country.nameKey),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  app.travelMode
                      ? t.get('travel_mode')
                      : t.get('residence_country'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(t.get('offline')),
            const SizedBox(height: 16),
            ...items.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SectionCard(
                  title: i.$1,
                  icon: i.$2,
                  color: i.$4,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => i.$3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _flag(String code) =>
      String.fromCharCodes(code.codeUnits.map((c) => c + 127397));
}
