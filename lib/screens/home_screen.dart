import 'package:flutter/material.dart';
import '../app/localizations.dart';
import '../widgets/section_card.dart';
import 'guide_list_screen.dart';
import 'checklist_screen.dart';
import 'calculator_screen.dart';
import 'family_screen.dart';
import 'placeholder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final items = [
      (
        t.get('emergencies'),
        Icons.warning_amber_rounded,
        const GuideListScreen(kind: GuideKind.emergencies),
      ),
      (
        t.get('firstAid'),
        Icons.health_and_safety_outlined,
        const GuideListScreen(kind: GuideKind.firstAid),
      ),
      (
        t.get('disasters'),
        Icons.thunderstorm_outlined,
        const GuideListScreen(kind: GuideKind.disasters),
      ),
      (t.get('kit'), Icons.backpack_outlined, const ChecklistScreen(kit: true)),
      (
        t.get('checklists'),
        Icons.checklist_rounded,
        const ChecklistScreen(kit: false),
      ),
      (t.get('waterFood'), Icons.water_drop_outlined, const CalculatorScreen()),
      (t.get('family'), Icons.family_restroom_outlined, const FamilyScreen()),
      (
        t.get('contacts'),
        Icons.contact_phone_outlined,
        const PlaceholderScreen(
          title: 'Contacts d’urgence',
          icon: Icons.contact_phone_outlined,
          body:
              'Enregistrez ici les numéros locaux des secours, police, pompiers, ambulance et vos contacts familiaux. Cette base locale pourra être adaptée par pays dans une prochaine version.',
        ),
      ),
      (
        t.get('maps'),
        Icons.map_outlined,
        const PlaceholderScreen(
          title: 'Cartes hors-ligne',
          icon: Icons.map_outlined,
          body:
              'ReadySafe prépare l’intégration de cartes téléchargeables par zone. Aucune carte lourde n’est téléchargée automatiquement dans cette version.',
        ),
      ),
      (
        t.get('information'),
        Icons.info_outline,
        const PlaceholderScreen(
          title: 'Informations',
          icon: Icons.info_outline,
          body:
              'ReadySafe fonctionne hors ligne pour les données enregistrées et les guides inclus. Vérifiez toujours les consignes des autorités locales.',
        ),
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
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.offline_bolt),
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
            Text(t.get('offline')),
            const SizedBox(height: 16),
            ...items.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SectionCard(
                  title: i.$1,
                  icon: i.$2,
                  color: Theme.of(context).colorScheme.primary,
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
}
