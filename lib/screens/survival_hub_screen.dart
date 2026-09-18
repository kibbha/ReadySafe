import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/local_storage_service.dart';
import 'avalanche_safety_screen.dart';
import 'calculator_screen.dart';
import 'communication_plan_screen.dart';
import 'emergency_food_safety_screen.dart';
import 'carbon_monoxide_screen.dart';
import 'checklist_screen.dart';
import 'guide_list_screen.dart';
import 'home_safety_screen.dart';
import 'maintenance_screen.dart';
import 'medical_continuity_screen.dart';
import 'leave_now_screen.dart';
import 'offline_readiness_screen.dart';
import 'official_sources_screen.dart';
import 'pet_emergency_screen.dart';
import 'power_outage_screen.dart';
import 'preparedness_review_screen.dart';
import 'recovery_screen.dart';
import 'safety_tools_screen.dart';
import 'sanitation_hygiene_screen.dart';
import 'secure_vault_screen.dart';
import 'smoke_air_quality_screen.dart';
import 'special_kits_screen.dart';
import 'support_needs_screen.dart';
import 'training_screen.dart';
import 'water_safety_screen.dart';

class SurvivalHubScreen extends StatefulWidget {
  const SurvivalHubScreen({super.key});

  @override
  State<SurvivalHubScreen> createState() => _SurvivalHubScreenState();
}

class _SurvivalHubScreenState extends State<SurvivalHubScreen> {
  final _storage = LocalStorageService();
  int _ready = 0;
  int _total = kitItems.length;
  String _section = 'prepare';

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
    final en = Localizations.localeOf(context).languageCode == 'en';
    final progress = _total == 0 ? 0.0 : _ready / _total;
    final modules = [
      _Module(
        en ? 'Home kit' : 'Kit domicile',
        en ? 'Several days of water, food, radio, light and health supplies' : 'Réserves pour plusieurs jours : eau, nourriture, radio, lumière et santé',
        Icons.backpack_rounded,
        const Color(0xff087f83),
        const ChecklistScreen(kit: true),
        'prepare',
      ),
      _Module(
        en ? 'Specialized kits' : 'Kits spécialisés',
        en ? 'Evacuation, vehicle, travel, child, pets and outdoors' : 'Évacuation, voiture, voyage, enfant, animaux et extérieur',
        Icons.inventory_2_rounded,
        const Color(0xff147343),
        const SpecialKitsScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Checklists' : 'Check-lists',
        en ? 'Evacuation, fire, outage, travel, vehicle and family' : 'Évacuation, incendie, panne, voyage, voiture et famille',
        Icons.fact_check_rounded,
        const Color(0xffb7833f),
        const ChecklistScreen(kit: false),
        'prepare',
      ),
      _Module(
        en ? 'Water & food' : 'Eau & nourriture',
        en ? 'Estimate household needs and autonomy' : 'Estimer les besoins de votre foyer et votre autonomie',
        Icons.water_drop_rounded,
        const Color(0xff2087c7),
        const CalculatorScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Safe water in an emergency' : 'Eau sûre en urgence',
        en ? 'Boiling, treatment, filters and contamination' : 'Ébullition, traitement, filtres et contamination',
        Icons.local_drink_rounded,
        const Color(0xff237fc7),
        const WaterSafetyScreen(),
        'act',
      ),
      _Module(
        en ? 'Hygiene & sanitation' : 'Hygiène & assainissement',
        en ? 'Hands, waste, dirty water and infection prevention' : 'Mains, déchets, eaux souillées et prévention des infections',
        Icons.sanitizer_rounded,
        const Color(0xff087f83),
        const SanitationHygieneScreen(),
        'act',
      ),
      _Module(
        en ? 'Food safety' : 'Sécurité alimentaire',
        en ? 'Outages, cold chain, thawing and flood contamination' : 'Panne, froid, aliments décongelés et contamination par les eaux',
        Icons.restaurant_rounded,
        const Color(0xffb7833f),
        const EmergencyFoodSafetyScreen(),
        'act',
      ),
      _Module(
        en ? 'Smoke & air quality' : 'Fumée & qualité de l’air',
        en ? 'Cleaner-air room, filtration and smoke exposure' : 'Pièce à air plus propre, filtration et exposition à la fumée',
        Icons.air_rounded,
        const Color(0xffd16a32),
        const SmokeAirQualityScreen(),
        'act',
      ),
      _Module(
        en ? 'Power outage' : 'Panne électrique',
        en ? 'Power, food refrigeration, communication and CO safety' : 'Énergie, froid alimentaire, communication et sécurité CO',
        Icons.power_off_rounded,
        const Color(0xffb7833f),
        const PowerOutageScreen(),
        'act',
      ),
      _Module(
        en ? 'Carbon monoxide' : 'Monoxyde de carbone',
        en ? 'Generators, fuel-burning devices, detectors and poisoning signs' : 'Groupes électrogènes, combustion, détecteurs et signes d’intoxication',
        Icons.warning_amber_rounded,
        const Color(0xffd92d36),
        const CarbonMonoxideScreen(),
        'act',
      ),
      _Module(
        en ? 'Avalanche safety' : 'Sécurité avalanche',
        en ? 'Official bulletin, burial response and Swiss rescue context' : 'Bulletin officiel, ensevelissement et secours en Suisse',
        Icons.landscape_rounded,
        const Color(0xff237fc7),
        const AvalancheSafetyScreen(),
        'act',
      ),
      _Module(
        en ? 'Risks & disasters' : 'Risques & catastrophes',
        en ? 'Before, during and after fire, flood, storm and more' : 'Avant, pendant et après : incendie, inondation, tempête…',
        Icons.thunderstorm_rounded,
        const Color(0xffd16a32),
        const GuideListScreen(kind: GuideKind.disasters),
        'act',
      ),
      _Module(
        en ? 'Survival guidance' : 'Conseils de survie',
        en ? 'Outage, evacuation, sheltering and essential actions' : 'Panne, évacuation, confinement et réflexes essentiels',
        Icons.menu_book_rounded,
        const Color(0xff4c6d72),
        const GuideListScreen(kind: GuideKind.emergencies),
        'act',
      ),
      _Module(
        en ? 'Family communication' : 'Communication familiale',
        en ? 'Out-of-area contact, reconnection and safe message' : 'Contact extérieur, reconnexion et message « Je suis en sécurité »',
        Icons.connect_without_contact_rounded,
        const Color(0xff0f7c7f),
        const CommunicationPlanScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Secure vault' : 'Coffre sécurisé',
        en ? 'Encrypted sensitive references stored locally' : 'Références sensibles chiffrées et disponibles localement',
        Icons.lock_rounded,
        const Color(0xff6750a4),
        const SecureVaultScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Home safety' : 'Sécurité du domicile',
        en ? 'Exits, utilities, alarms and safe indoor area' : 'Sorties, coupures techniques, détecteurs et zone sûre',
        Icons.home_work_rounded,
        const Color(0xff4c6d72),
        const HomeSafetyScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Support needs' : 'Besoins spécifiques',
        en ? 'Mobility, hearing, vision, assistance, power and communication' : 'Mobilité, audition, vision, aide, énergie et communication',
        Icons.accessibility_new_rounded,
        const Color(0xff6750a4),
        const SupportNeedsScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Medical continuity' : 'Continuité médicale',
        en ? 'Medicines, devices, refrigeration, consumables and backup care' : 'Traitements, appareils, froid, consommables et solution de secours',
        Icons.medical_services_rounded,
        const Color(0xffd92d36),
        const MedicalContinuityScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Pets' : 'Animaux',
        en ? 'Evacuation, identification, shelter and backup helper' : 'Évacuation, identification, hébergement et personne relais',
        Icons.pets_rounded,
        const Color(0xff147343),
        const PetEmergencyScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Offline readiness' : 'Préparation hors ligne',
        en ? 'Check what remains available without network or Internet' : 'Vérifier ce qui reste disponible sans réseau ni Internet',
        Icons.offline_bolt_rounded,
        const Color(0xff087f83),
        const OfflineReadinessScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Emergency tools' : 'Outils d’urgence',
        en ? 'SOS signal, numbers, messages and quick landmark access' : 'Signal SOS, numéros, messages et accès rapide aux repères',
        Icons.handyman_rounded,
        const Color(0xffd92d36),
        const SafetyToolsScreen(),
        'act',
      ),
      _Module(
        en ? 'Official alerts' : 'Alertes officielles',
        en ? 'Open government and weather channels for the active country' : 'Accéder aux canaux gouvernementaux et météo du pays actif',
        Icons.campaign_rounded,
        const Color(0xffd16a32),
        const OfficialSourcesScreen(),
        'act',
      ),
      _Module(
        en ? 'After the emergency' : 'Après l’urgence',
        en ? 'Safe return, household, home and recovery steps' : 'Sécuriser le retour, les proches, le logement et les démarches',
        Icons.restore_rounded,
        const Color(0xff147343),
        const RecoveryScreen(),
        'recover',
      ),
      _Module(
        en ? 'Maintenance & reminders' : 'Entretien & rappels',
        en ? 'Expiry dates, stock rotation and periodic checks' : 'Péremptions, rotation des stocks et vérifications périodiques',
        Icons.event_repeat_rounded,
        const Color(0xffb7833f),
        const MaintenanceScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Preparedness review' : 'Revue de préparation',
        en ? 'Review contacts, supplies, alerts and household needs each year' : 'Vérifier chaque année contacts, réserves, alertes et besoins du foyer',
        Icons.fact_check_rounded,
        const Color(0xff087f83),
        const PreparednessReviewScreen(),
        'prepare',
      ),
      _Module(
        en ? 'Training & drills' : 'Formation & exercices',
        en ? 'Refresh skills and test your preparedness' : 'Réviser les gestes et tester votre préparation',
        Icons.school_rounded,
        const Color(0xff6750a4),
        const TrainingScreen(),
        'learn',
      ),
    ];
    final visibleModules = modules.where((module) => module.group == _section).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(en ? 'Kits & preparedness' : 'Kits & survie'),
        actions: [
          IconButton(
            tooltip: en ? 'Refresh' : 'Actualiser',
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
                          Text(
                            en ? 'Your preparedness center' : 'Votre centre de préparation',
                            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            en ? '$_ready / $_total core items ready' : '$_ready / $_total éléments de base prêts',
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
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        const CircleAvatar(backgroundColor: Color(0x22ffffff), child: Icon(Icons.directions_run_rounded, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(en ? 'I MUST LEAVE NOW' : 'JE DOIS PARTIR MAINTENANT', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(en ? 'Immediate evacuation checklist' : 'Checklist d’évacuation immédiate', style: const TextStyle(color: Colors.white)),
                        ])),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _sectionChip('prepare', en ? 'Prepare' : 'Préparer', Icons.backpack_outlined),
                    _sectionChip('act', en ? 'Act' : 'Agir', Icons.flash_on_rounded),
                    _sectionChip('recover', en ? 'After' : 'Après', Icons.restore_rounded),
                    _sectionChip('learn', en ? 'Learn' : 'Apprendre', Icons.school_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _sectionTitle(en),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xffe8f4f2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.grid_view_rounded, size: 16, color: Color(0xff087f83)),
                        const SizedBox(width: 4),
                        Text(
                          '${visibleModules.length}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
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
                itemCount: visibleModules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: wide ? 166 : 154,
                  crossAxisSpacing: 11,
                  mainAxisSpacing: 11,
                ),
                itemBuilder: (context, index) => _ModuleCard(module: visibleModules[index]),
              ),
              const SizedBox(height: 18),
              Text(en ? 'Quick reminders' : 'Réflexes rapides', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              _tip(
                Icons.water_drop_outlined,
                en ? 'Water' : 'Eau',
                en ? 'Keep a household-appropriate reserve and treat water whenever its safety is uncertain.' : 'Stockez une réserve adaptée au foyer et traitez toute eau dont la potabilité est incertaine.',
              ),
              _tip(
                Icons.bolt_outlined,
                en ? 'Power' : 'Énergie',
                en ? 'Keep lights, batteries, power banks and radio where everyone can find them.' : 'Gardez lampes, piles, batterie externe et radio dans un endroit connu de toute la famille.',
              ),
              _tip(
                Icons.directions_run_rounded,
                en ? 'Evacuation' : 'Évacuation',
                en ? 'People, medicines, phone, water, kit, pets and meeting point: keep the sequence simple.' : 'Documents, médicaments, téléphone, eau, kit, animaux et point de rassemblement : gardez l’ordre simple.',
              ),
              _tip(
                Icons.forum_outlined,
                en ? 'Communication' : 'Communication',
                en ? 'Plan an out-of-area contact, a reconnection point and a paper copy of key numbers.' : 'Prévoyez un contact extérieur, un point de reconnexion et une copie papier des numéros importants.',
              ),
            ],
          );
        },
      ),
    );
  }

  String _sectionTitle(bool en) {
    switch (_section) {
      case 'act':
        return en ? 'Act during an emergency' : 'Agir pendant une urgence';
      case 'recover':
        return en ? 'After the emergency' : 'Après l’urgence';
      case 'learn':
        return en ? 'Training & drills' : 'Formation & exercices';
      default:
        return en ? 'Prepare the household' : 'Préparer le foyer';
    }
  }

  Widget _sectionChip(String id, String label, IconData icon) => Padding(
        padding: const EdgeInsets.only(right: 7),
        child: ChoiceChip(
          selected: _section == id,
          showCheckmark: false,
          avatar: Icon(icon, size: 17),
          label: Text(label),
          onSelected: (_) => setState(() => _section = id),
        ),
      );

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
  const _Module(this.title, this.subtitle, this.icon, this.color, this.page, this.group);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
  final String group;
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
