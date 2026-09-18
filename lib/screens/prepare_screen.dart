import 'package:flutter/material.dart';

import 'calculator_screen.dart';
import 'checklist_screen.dart';
import 'communication_plan_screen.dart';
import 'family_documents_screen.dart';
import 'guide_list_screen.dart';
import 'maintenance_screen.dart';
import 'offline_readiness_screen.dart';
import 'secure_vault_screen.dart';
import 'training_screen.dart';
import 'travel_emergency_screen.dart';

class PrepareScreen extends StatelessWidget {
  const PrepareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    final modules = <_PrepareModule>[
      _PrepareModule(
        en ? 'Family & emergency plan' : 'Famille & plan d’urgence',
        en
            ? 'Household, contacts, meeting points and documents'
            : 'Foyer, contacts, rendez-vous et documents',
        Icons.family_restroom_rounded,
        const FamilyDocumentsScreen(),
      ),
      _PrepareModule(
        en ? '72-hour kit' : 'Kit 72 h',
        en ? 'Essential supplies, quantities and expiry dates' : 'Essentiels, quantités et dates à vérifier',
        Icons.backpack_rounded,
        const ChecklistScreen(kit: true),
      ),
      _PrepareModule(
        en ? 'Checklists' : 'Check-lists',
        en ? 'Evacuation, home, travel and more' : 'Évacuation, maison, voyage et plus',
        Icons.fact_check_rounded,
        const ChecklistScreen(kit: false),
      ),
      _PrepareModule(
        en ? 'Risks & emergency plans' : 'Risques & plans d’urgence',
        en ? 'Fire, flood, storm, earthquake and shelter guidance' : 'Incendie, inondation, tempête, séisme et confinement',
        Icons.route_rounded,
        const GuideListScreen(kind: GuideKind.disasters),
      ),
      _PrepareModule(
        en ? 'Water & food' : 'Eau & nourriture',
        en ? 'Estimate household reserves and autonomy' : 'Estimer les réserves et l’autonomie du foyer',
        Icons.water_drop_rounded,
        const CalculatorScreen(),
      ),
      _PrepareModule(
        en ? 'Communication plan' : 'Plan de communication',
        en ? 'Out-of-area contact and reconnection plan' : 'Contact extérieur et plan de reconnexion',
        Icons.connect_without_contact_rounded,
        const CommunicationPlanScreen(),
      ),
      _PrepareModule(
        en ? 'Secure vault' : 'Coffre sécurisé',
        en ? 'Encrypted emergency references stored on the device' : 'Références d’urgence chiffrées sur l’appareil',
        Icons.lock_rounded,
        const SecureVaultScreen(),
      ),
      _PrepareModule(
        en ? 'Travel readiness' : 'Préparation voyage',
        en ? 'Country-aware emergency and consular references' : 'Urgences locales et références consulaires',
        Icons.luggage_rounded,
        const TravelEmergencyScreen(),
      ),
      _PrepareModule(
        en ? 'Offline readiness' : 'Préparation hors ligne',
        en ? 'Check what remains usable without connectivity' : 'Vérifier ce qui reste utilisable sans connexion',
        Icons.offline_bolt_rounded,
        const OfflineReadinessScreen(),
      ),
      _PrepareModule(
        en ? 'Maintenance' : 'Entretien',
        en ? 'Expiry dates, batteries and periodic checks' : 'Péremptions, batteries et vérifications périodiques',
        Icons.event_repeat_rounded,
        const MaintenanceScreen(),
      ),
      _PrepareModule(
        en ? 'Training & drills' : 'Formation & exercices',
        en ? 'Short drills and essential-skill refreshers' : 'Exercices courts et révision des gestes essentiels',
        Icons.school_rounded,
        const TrainingScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(en ? 'Prepare' : 'Préparer')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1050
              ? 4
              : width >= 760
                  ? 3
                  : width >= 520
                      ? 2
                      : 1;
          final horizontal = width >= 760 ? 24.0 : 14.0;

          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 30),
            children: [
              Container(
                padding: EdgeInsets.all(width >= 760 ? 22 : 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffe1f2ee), Color(0xfffff2dd)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xff087f83),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 31,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            en
                                ? 'Build practical emergency readiness'
                                : 'Construire une préparation réellement utile',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            en
                                ? 'Start with people, contacts, water, a basic kit and a way to reconnect. Add the rest progressively.'
                                : 'Commencez par les personnes, les contacts, l’eau, un kit de base et un moyen de vous retrouver. Complétez ensuite progressivement.',
                            style: const TextStyle(
                              color: Color(0xff5f7074),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffdde7e5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.offline_bolt_rounded, color: Color(0xff087f83)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        en
                            ? 'Core plans, checklists and stored household information remain available locally even when connectivity is poor.'
                            : 'Les plans, checklists et informations essentielles du foyer restent disponibles localement même lorsque la connexion est mauvaise.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: columns == 1 ? 104 : 156,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) => _PrepareCard(
                  module: modules[index],
                  compact: columns == 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PrepareModule {
  const _PrepareModule(this.title, this.subtitle, this.icon, this.page);

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}

class _PrepareCard extends StatelessWidget {
  const _PrepareCard({
    required this.module,
    required this.compact,
  });

  final _PrepareModule module;
  final bool compact;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => module.page),
          ),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xffdde7e5)),
            ),
            child: compact
                ? Row(
                    children: [
                      _icon(),
                      const SizedBox(width: 12),
                      Expanded(child: _text()),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xff87969a),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _icon(),
                      const Spacer(),
                      _text(),
                    ],
                  ),
          ),
        ),
      );

  Widget _icon() => Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xffe5f3f1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(module.icon, color: const Color(0xff087f83)),
      );

  Widget _text() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            module.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            module.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xff65747a),
              height: 1.2,
            ),
          ),
        ],
      );
}
