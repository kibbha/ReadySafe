import 'package:flutter/material.dart';

import 'calculator_screen.dart';
import 'checklist_screen.dart';
import 'family_screen.dart';
import 'guide_list_screen.dart';
import 'placeholder_screen.dart';
import 'training_screen.dart';

class PrepareScreen extends StatelessWidget {
  const PrepareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final modules = <_PrepareModule>[
      _PrepareModule(
        en ? 'Family plan' : 'Plan familial',
        en ? 'Household, meeting point and needs' : 'Foyer, point de rassemblement et besoins',
        Icons.family_restroom_rounded,
        const FamilyScreen(),
      ),
      _PrepareModule(
        en ? '72-hour kit' : 'Kit 72 h',
        en ? 'Essential supplies and expiry checks' : 'Essentiels et dates à vérifier',
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
        en ? 'Emergency plans' : 'Plans d’urgence',
        en ? 'Fire, flood, storm and shelter guidance' : 'Incendie, inondation, tempête et confinement',
        Icons.route_rounded,
        const GuideListScreen(kind: GuideKind.disasters),
      ),
      _PrepareModule(
        en ? 'Water & food' : 'Eau & nourriture',
        en ? 'Estimate household needs' : 'Estimer les besoins du foyer',
        Icons.water_drop_rounded,
        const CalculatorScreen(),
      ),
      _PrepareModule(
        en ? 'Training' : 'Entraînement',
        en ? 'Short drills and first-aid revision' : 'Exercices courts et révision des secours',
        Icons.school_rounded,
        const TrainingScreen(),
      ),
      _PrepareModule(
        en ? 'Emergency documents' : 'Documents d’urgence',
        en ? 'Offline vault foundation' : 'Base du coffre hors ligne',
        Icons.folder_copy_outlined,
        PlaceholderScreen(
          title: en ? 'Emergency documents' : 'Documents d’urgence',
          icon: Icons.folder_copy_outlined,
          body: en
              ? 'The private offline vault is being integrated. First-aid and emergency functions remain available without an account.'
              : 'Le coffre privé hors ligne est en cours d’intégration. Les fonctions de secours et d’urgence restent accessibles sans compte.',
        ),
      ),
      _PrepareModule(
        en ? 'Personal contacts' : 'Contacts personnels',
        en ? 'People to reach quickly' : 'Proches à joindre rapidement',
        Icons.contact_phone_rounded,
        PlaceholderScreen(
          title: en ? 'Personal contacts' : 'Contacts personnels',
          icon: Icons.contact_phone_rounded,
          body: en
              ? 'Personal emergency contacts will be stored locally and kept separate from official emergency numbers.'
              : 'Les contacts personnels d’urgence seront stockés localement et séparés des numéros officiels.',
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(en ? 'Prepare' : 'Préparer')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final horizontal = wide ? 28.0 : 16.0;
          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 30),
            children: [
              Container(
                padding: EdgeInsets.all(wide ? 22 : 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffe1f2ee), Color(0xfffff2dd)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xff087f83),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 31),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            en ? 'Build your emergency readiness' : 'Construire votre préparation',
                            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            en
                                ? 'Complete the essentials progressively. ReadySafe stays useful even if everything is not configured.'
                                : 'Complétez les essentiels progressivement. ReadySafe reste utile même si tout n’est pas encore configuré.',
                            style: const TextStyle(color: Color(0xff5f7074), height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffdde7e5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.task_alt_rounded, color: Color(0xff087f83)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        en
                            ? 'Start with a family plan, a basic kit and emergency contacts.'
                            : 'Commencez par un plan familial, un kit de base et vos contacts d’urgence.',
                        style: const TextStyle(fontWeight: FontWeight.w800, height: 1.3),
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
                  crossAxisCount: wide ? 3 : 2,
                  mainAxisExtent: wide ? 164 : 148,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) => _PrepareCard(module: modules[index]),
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
  const _PrepareCard({required this.module});
  final _PrepareModule module;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xffe5f3f1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(module.icon, color: const Color(0xff087f83)),
                ),
                const Spacer(),
                Text(
                  module.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, height: 1.08),
                ),
                const SizedBox(height: 5),
                Text(
                  module.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xff65747a), height: 1.2),
                ),
              ],
            ),
          ),
        ),
      );
}
