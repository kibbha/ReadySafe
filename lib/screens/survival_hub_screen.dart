import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/local_storage_service.dart';
import 'calculator_screen.dart';
import 'communication_plan_screen.dart';
import 'checklist_screen.dart';
import 'guide_list_screen.dart';
import 'leave_now_screen.dart';
import 'safety_tools_screen.dart';
import 'training_screen.dart';

class SurvivalHubScreen extends StatefulWidget {
  const SurvivalHubScreen({super.key});

  @override
  State<SurvivalHubScreen> createState() => _SurvivalHubScreenState();
}

class _SurvivalHubScreenState extends State<SurvivalHubScreen> {
  final _storage = LocalStorageService();
  int _ready = 0;
  int _total = kitItems.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stock = await _storage.kitStock();
    var ready = 0;
    for (final item in kitItems) {
      final entry = stock[item.id];
      if (entry == null || entry.isExpired) continue;
      final target = item.recommendedQuantity;
      if (target == null) {
        if (entry.quantityOwned > 0) ready++;
      } else if (entry.quantityOwned >= target) {
        ready++;
      }
    }
    if (!mounted) return;
    setState(() {
      _ready = ready;
      _total = kitItems.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total == 0 ? 0.0 : _ready / _total;
    final modules = [
      _Module(
        'Kit domicile 72 h',
        'Eau, nourriture, radio, lumière, santé et protection',
        Icons.backpack_rounded,
        const Color(0xff087f83),
        const ChecklistScreen(kit: true),
      ),
      _Module(
        'Check-lists',
        'Évacuation, incendie, panne, voyage, voiture et famille',
        Icons.fact_check_rounded,
        const Color(0xffb7833f),
        const ChecklistScreen(kit: false),
      ),
      _Module(
        'Eau & nourriture',
        'Estimer les besoins de votre foyer et votre autonomie',
        Icons.water_drop_rounded,
        const Color(0xff2087c7),
        const CalculatorScreen(),
      ),
      _Module(
        'Risques & catastrophes',
        'Avant, pendant et après : incendie, inondation, tempête…',
        Icons.thunderstorm_rounded,
        const Color(0xffd16a32),
        const GuideListScreen(kind: GuideKind.disasters),
      ),
      _Module(
        'Conseils de survie',
        'Panne, évacuation, confinement et réflexes essentiels',
        Icons.menu_book_rounded,
        const Color(0xff4c6d72),
        const GuideListScreen(kind: GuideKind.emergencies),
      ),
      _Module(
        'Communication familiale',
        'Contact extérieur, reconnexion et message « Je suis en sécurité »',
        Icons.connect_without_contact_rounded,
        const Color(0xff0f7c7f),
        const CommunicationPlanScreen(),
      ),
      _Module(
        'Outils d’urgence',
        'Signal SOS, numéros, messages et accès rapide aux repères',
        Icons.handyman_rounded,
        const Color(0xffd92d36),
        const SafetyToolsScreen(),
      ),
      _Module(
        'Formation & exercices',
        'Réviser les gestes et tester votre préparation',
        Icons.school_rounded,
        const Color(0xff6750a4),
        const TrainingScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kits & survie'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final columns = wide ? 3 : 2;
          return ListView(
            padding: EdgeInsets.fromLTRB(wide ? 24 : 14, 4, wide ? 24 : 14, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffdff2ef), Color(0xfffff1df)],
                  ),
                  borderRadius: BorderRadius.circular(24),
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
                      child: const Icon(Icons.backpack_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Votre centre de préparation',
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_ready / $_total éléments de base prêts',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xff52666b)),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: progress,
                              backgroundColor: Colors.white,
                              color: const Color(0xff087f83),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Material(
                color: const Color(0xffd92d36),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveNowScreen())),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: Color(0x22ffffff), child: Icon(Icons.directions_run_rounded, color: Colors.white)),
                        SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('JE DOIS PARTIR MAINTENANT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                          SizedBox(height: 2),
                          Text('Checklist d’évacuation immédiate', style: TextStyle(color: Colors.white)),
                        ])),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text('Essentiels', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xffe8f4f2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.offline_bolt_rounded, size: 16, color: Color(0xff087f83)),
                        SizedBox(width: 4),
                        Text('disponible hors ligne', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: wide ? 166 : 154,
                  crossAxisSpacing: 11,
                  mainAxisSpacing: 11,
                ),
                itemBuilder: (context, index) => _ModuleCard(module: modules[index]),
              ),
              const SizedBox(height: 18),
              const Text('Réflexes rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              _tip(
                Icons.water_drop_outlined,
                'Eau',
                'Stockez une réserve adaptée au foyer et traitez toute eau dont la potabilité est incertaine.',
              ),
              _tip(
                Icons.bolt_outlined,
                'Énergie',
                'Gardez lampes, piles, batterie externe et radio dans un endroit connu de toute la famille.',
              ),
              _tip(
                Icons.directions_run_rounded,
                'Évacuation',
                'Documents, médicaments, téléphone, eau, kit, animaux et point de rassemblement : gardez l’ordre simple.',
              ),
              _tip(
                Icons.forum_outlined,
                'Communication',
                'Prévoyez un contact extérieur, un point de reconnexion et une copie papier des numéros importants.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tip(IconData icon, String title, String body) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xffe7f3f1),
            child: Icon(icon, color: const Color(0xff087f83)),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(body),
        ),
      );
}

class _Module {
  const _Module(this.title, this.subtitle, this.icon, this.color, this.page);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});
  final _Module module;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => module.page),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffdbe6e7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: module.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(module.icon, color: module.color),
                ),
                const Spacer(),
                Text(
                  module.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, height: 1.05),
                ),
                const SizedBox(height: 4),
                Text(
                  module.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xff65747a), height: 1.22),
                ),
              ],
            ),
          ),
        ),
      );
}
