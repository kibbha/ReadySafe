import 'package:flutter/material.dart';

import '../app/localizations.dart';
import '../core/search_text.dart';
import '../data/content.dart';
import '../data/first_aid_repository.dart';
import 'avalanche_safety_screen.dart';
import 'carbon_monoxide_screen.dart';
import 'checklist_screen.dart';
import 'communication_plan_screen.dart';
import 'emergency_food_safety_screen.dart';
import 'emergency_plan_summary_screen.dart';
import 'family_documents_screen.dart';
import 'family_reunification_screen.dart';
import 'first_aid_screen.dart';
import 'guide_list_screen.dart';
import 'home_safety_screen.dart';
import 'lightning_safety_screen.dart';
import 'maintenance_screen.dart';
import 'medical_continuity_screen.dart';
import 'offline_readiness_screen.dart';
import 'official_sources_screen.dart';
import 'online_maps_screen.dart';
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
import 'survival_hub_screen.dart';
import 'travel_emergency_screen.dart';
import 'tsunami_safety_screen.dart';
import 'vehicle_emergency_screen.dart';
import 'volcano_safety_screen.dart';
import 'water_safety_screen.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({
    super.key,
    this.initialQuery = '',
  });

  final String initialQuery;

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _en =>
      Localizations.localeOf(context).languageCode == 'en';

  List<_SearchHit> _hits(String query) {
    final q = normalizeSearchText(query);

    if (q.isEmpty) return const [];

    final en = _en;
    final t = AppLocalizations.of(context);
    final hits = <_SearchHit>[];

    for (final guide in firstAidGuides) {
      final title = t.get(guide.titleKey);
      final summary = t.get(guide.summaryKey);
      final stepText = guide.steps
          .map((step) => t.get(step.textKey))
          .join(' ');

      final terms = [
        guide.id,
        guide.titleKey,
        guide.summaryKey,
        title,
        summary,
        stepText,
        ...(_firstAidAliases[guide.id] ?? const <String>[]),
      ].join(' ');
      final normalizedTerms = normalizeSearchText(terms);

      if (normalizedTerms.contains(q)) {
        hits.add(
          _SearchHit(
            en ? 'First aid' : 'Premiers secours',
            title,
            Icons.health_and_safety_rounded,
            FirstAidDetailScreen(guide: guide),
          ),
        );
      }
    }

    for (final guide in disasterGuides) {
      final localized = localizedGuide(guide, en);
      final terms = [
        guide.title,
        guide.immediate,
        ...guide.steps,
        localized.title,
        localized.immediate,
        ...localized.steps,
        ...(_hazardAliases[guide.id] ?? const <String>[]),
      ].join(' ');
      final normalizedTerms = normalizeSearchText(terms);

      if (normalizedTerms.contains(q)) {
        hits.add(
          _SearchHit(
            en ? 'Risks' : 'Risques',
            localized.title,
            Icons.warning_amber_rounded,
            GuideDetail(guide: localized),
          ),
        );
      }
    }

    for (final guide in emergencyGuides) {
      final localized = localizedGuide(guide, en);
      final terms = [
        guide.title,
        guide.immediate,
        ...guide.steps,
        localized.title,
        localized.immediate,
        ...localized.steps,
        ...(_hazardAliases[guide.id] ?? const <String>[]),
      ].join(' ');
      final normalizedTerms = normalizeSearchText(terms);

      if (normalizedTerms.contains(q)) {
        hits.add(
          _SearchHit(
            en ? 'Survival actions' : 'Réflexes de survie',
            localized.title,
            Icons.shield_outlined,
            GuideDetail(guide: localized),
          ),
        );
      }
    }

    for (final shortcut in _shortcuts(en)) {
      final matches = shortcut.terms.any((term) {
        final normalized = normalizeSearchText(term);
        return normalized.contains(q) || q.contains(normalized);
      });

      if (matches) hits.add(shortcut.hit);
    }

    final unique = <String, _SearchHit>{};

    for (final hit in hits) {
      unique['${hit.section}|${hit.title}'] = hit;
    }

    return unique.values.take(18).toList();
  }

  List<_Shortcut> _shortcuts(bool en) => [
        _Shortcut(
          const ['water', 'eau', 'water reserve', 'réserve eau'],
          _SearchHit(
            en ? 'Kits & preparedness' : 'Kits & survie',
            en ? 'Water & reserves' : 'Eau & réserves',
            Icons.water_drop_rounded,
            const SurvivalHubScreen(),
          ),
        ),
        _Shortcut(
          const [
            'safe water',
            'drinking water',
            'eau potable',
            'boil water',
            'faire bouillir',
            'water contamination',
            'contamination eau',
          ],
          _SearchHit(
            en ? 'Preparedness' : 'Kits & survie',
            en ? 'Safe water in an emergency' : 'Eau sûre en urgence',
            Icons.local_drink_rounded,
            const WaterSafetyScreen(),
          ),
        ),
        _Shortcut(
          const [
            'food safety',
            'food',
            'aliment',
            'refrigerator',
            'fridge',
            'frigo',
            'freezer',
            'congélateur',
            'thawed food',
            'décongelé',
          ],
          _SearchHit(
            en ? 'Preparedness' : 'Kits & survie',
            en ? 'Emergency food safety' : 'Sécurité alimentaire',
            Icons.restaurant_rounded,
            const EmergencyFoodSafetyScreen(),
          ),
        ),
        _Shortcut(
          const [
            'smoke',
            'fumée',
            'air quality',
            'qualité de l’air',
            'air purifier',
            'purificateur',
          ],
          _SearchHit(
            en ? 'Risks' : 'Risques',
            en ? 'Smoke & air quality' : 'Fumée & qualité de l’air',
            Icons.air_rounded,
            const SmokeAirQualityScreen(),
          ),
        ),
        _Shortcut(
          const [
            'hygiene',
            'hygiène',
            'sanitation',
            'assainissement',
            'dirty water',
            'eaux souillées',
          ],
          _SearchHit(
            en ? 'Preparedness' : 'Kits & survie',
            en ? 'Hygiene & sanitation' : 'Hygiène & assainissement',
            Icons.sanitizer_rounded,
            const SanitationHygieneScreen(),
          ),
        ),
        _Shortcut(
          const ['kit', '72h kit', 'kit 72', 'emergency kit'],
          _SearchHit(
            en ? 'Kits' : 'Kits & survie',
            en ? '72-hour kit' : 'Kit 72 h',
            Icons.backpack_rounded,
            const ChecklistScreen(kit: true),
          ),
        ),
        _Shortcut(
          const [
            'special kit',
            'specialized kit',
            'kit spécialisé',
            'baby kit',
            'kit bébé',
            'pet kit',
            'kit animal',
            'evacuation bag',
            'sac évacuation',
          ],
          _SearchHit(
            en ? 'Kits' : 'Kits & survie',
            en ? 'Specialized kits' : 'Kits spécialisés',
            Icons.inventory_2_rounded,
            const SpecialKitsScreen(),
          ),
        ),
        _Shortcut(
          const ['checklist', 'check-list', 'check list'],
          _SearchHit(
            en ? 'Kits' : 'Kits & survie',
            en ? 'Emergency checklists' : 'Check-lists',
            Icons.fact_check_rounded,
            const ChecklistScreen(kit: false),
          ),
        ),
        _Shortcut(
          const [
            'car',
            'vehicle',
            'voiture',
            'breakdown',
            'panne voiture',
            'car crash',
            'accident voiture',
            'flooded road',
            'route inondée',
          ],
          _SearchHit(
            en ? 'Risks' : 'Risques',
            en ? 'Vehicle emergency' : 'Urgence véhicule',
            Icons.directions_car_rounded,
            const VehicleEmergencyScreen(),
          ),
        ),
        _Shortcut(
          const [
            'travel',
            'voyage',
            'lost passport',
            'passeport perdu',
            'consulate',
            'consulat',
            'embassy',
            'ambassade',
          ],
          _SearchHit(
            en ? 'Travel' : 'Voyage',
            en ? 'Emergency while travelling' : 'Urgence en voyage',
            Icons.luggage_rounded,
            const TravelEmergencyScreen(),
          ),
        ),
        _Shortcut(
          const [
            'family reunification',
            'réunification',
            'child pickup',
            'récupérer enfant',
            'meeting point',
            'point de rendez-vous',
          ],
          _SearchHit(
            en ? 'Family' : 'Famille',
            en ? 'Family reunification' : 'Réunification familiale',
            Icons.family_restroom_rounded,
            const FamilyReunificationScreen(),
          ),
        ),
        _Shortcut(
          const ['family', 'famille', 'documents', 'document'],
          _SearchHit(
            en ? 'Family' : 'Famille',
            en ? 'Family & documents' : 'Famille & documents',
            Icons.family_restroom_rounded,
            const FamilyDocumentsScreen(),
          ),
        ),
        _Shortcut(
          const [
            'vault',
            'coffre',
            'secure reference',
            'référence sécurisée',
            'encrypted',
            'chiffré',
          ],
          _SearchHit(
            en ? 'Family' : 'Famille',
            en ? 'Secure vault' : 'Coffre sécurisé',
            Icons.lock_rounded,
            const SecureVaultScreen(),
          ),
        ),
        _Shortcut(
          const [
            'pharmacy',
            'pharmacie',
            'hospital',
            'hôpital',
            'shelter',
            'abri',
            'map',
            'carte',
            'landmark',
            'repère',
            'aed nearby',
            'dae proche',
          ],
          _SearchHit(
            en ? 'Map' : 'Carte',
            en ? 'Map & landmarks' : 'Carte & repères',
            Icons.map_rounded,
            const OnlineMapsScreen(),
          ),
        ),
        _Shortcut(
          const [
            'emergency plan',
            'plan urgence',
            'plan d’urgence',
            'household plan',
          ],
          _SearchHit(
            en ? 'Family' : 'Famille',
            en ? 'My emergency plan' : 'Mon plan d’urgence',
            Icons.assignment_turned_in_rounded,
            const EmergencyPlanSummaryScreen(),
          ),
        ),
        _Shortcut(
          const [
            'communication',
            'out of area contact',
            'contact extérieur',
            'safe message',
            'message sécurité',
          ],
          _SearchHit(
            en ? 'Family' : 'Famille',
            en ? 'Communication plan' : 'Plan de communication',
            Icons.connect_without_contact_rounded,
            const CommunicationPlanScreen(),
          ),
        ),
        _Shortcut(
          const [
            'official alert',
            'alerte',
            'official source',
            'source officielle',
            'warning',
          ],
          _SearchHit(
            en ? 'Official' : 'Officiel',
            en
                ? 'Official alerts & sources'
                : 'Alertes & sources officielles',
            Icons.campaign_rounded,
            const OfficialSourcesScreen(),
          ),
        ),
        _Shortcut(
          const [
            'recovery',
            'after emergency',
            'après',
            'retour maison',
          ],
          _SearchHit(
            en ? 'After the emergency' : 'Après l’urgence',
            en ? 'Recovery' : 'Récupération',
            Icons.restore_rounded,
            const RecoveryScreen(),
          ),
        ),
        _Shortcut(
          const ['sos tool', 'signal sos', 'emergency tool', 'outil'],
          _SearchHit(
            en ? 'Tools' : 'Outils',
            en ? 'Emergency tools' : 'Outils d’urgence',
            Icons.sos_rounded,
            const SafetyToolsScreen(),
          ),
        ),
        _Shortcut(
          const [
            'carbon monoxide',
            'monoxyde',
            'co poisoning',
            'generator',
            'groupe électrogène',
          ],
          _SearchHit(
            en ? 'Risks' : 'Risques',
            en ? 'Carbon monoxide' : 'Monoxyde de carbone',
            Icons.warning_amber_rounded,
            const CarbonMonoxideScreen(),
          ),
        ),
        _Shortcut(
          const [
            'thunderstorm',
            'orage',
            'lightning',
            'foudre',
            'hail',
            'grêle',
          ],
          _SearchHit(
            en ? 'Risks' : 'Risques',
            en ? 'Thunderstorm & lightning' : 'Orage & foudre',
            Icons.thunderstorm_rounded,
            const LightningSafetyScreen(),
          ),
        ),
        _Shortcut(
          const [
            'tsunami',
            'sea withdrawal',
            'retrait de la mer',
          ],
          _SearchHit(
            en ? 'Risks' : 'Risques',
            'Tsunami',
            Icons.waves_rounded,
            const TsunamiSafetyScreen(),
          ),
        ),
        _Shortcut(
          const [
            'volcano',
            'volcan',
            'volcanic ash',
            'cendres volcaniques',
          ],
          _SearchHit(
            en ? 'Risks' : 'Risques',
            en ? 'Volcano & ash' : 'Volcan & cendres',
            Icons.volcano_rounded,
            const VolcanoSafetyScreen(),
          ),
        ),
        _Shortcut(
          const ['avalanche', 'rega'],
          _SearchHit(
            en ? 'Risks' : 'Risques',
            en ? 'Avalanche safety' : 'Sécurité avalanche',
            Icons.landscape_rounded,
            const AvalancheSafetyScreen(),
          ),
        ),
        _Shortcut(
          const [
            'power outage',
            'blackout',
            'panne électrique',
            'courant',
          ],
          _SearchHit(
            en ? 'Preparedness' : 'Préparation',
            en ? 'Power outage' : 'Panne électrique',
            Icons.power_off_rounded,
            const PowerOutageScreen(),
          ),
        ),
        _Shortcut(
          const [
            'home safety',
            'domicile',
            'gas shutoff',
            'gaz',
            'electrical panel',
            'tableau électrique',
          ],
          _SearchHit(
            en ? 'Preparedness' : 'Préparation',
            en ? 'Home safety' : 'Sécurité du domicile',
            Icons.home_work_rounded,
            const HomeSafetyScreen(),
          ),
        ),
        _Shortcut(
          const [
            'medicine',
            'médicament',
            'prescription',
            'ordonnance',
            'medical device',
            'appareil médical',
            'dialysis',
            'dialyse',
          ],
          _SearchHit(
            en ? 'Preparedness' : 'Préparation',
            en ? 'Medical continuity' : 'Continuité médicale',
            Icons.medical_services_rounded,
            const MedicalContinuityScreen(),
          ),
        ),
        _Shortcut(
          const [
            'pet',
            'animal',
            'veterinarian',
            'vétérinaire',
          ],
          _SearchHit(
            en ? 'Family' : 'Famille',
            en ? 'Pets in an emergency' : 'Animaux en urgence',
            Icons.pets_rounded,
            const PetEmergencyScreen(),
          ),
        ),
        _Shortcut(
          const [
            'accessibility',
            'accessibilité',
            'mobility',
            'mobilité',
            'hearing',
            'audition',
            'support need',
            'besoin spécifique',
          ],
          _SearchHit(
            en ? 'Family' : 'Famille',
            en ? 'Support needs' : 'Besoins spécifiques',
            Icons.accessibility_new_rounded,
            const SupportNeedsScreen(),
          ),
        ),
        _Shortcut(
          const [
            'offline',
            'hors ligne',
            'no internet',
            'sans internet',
          ],
          _SearchHit(
            en ? 'Preparedness' : 'Préparation',
            en ? 'Offline readiness' : 'Préparation hors ligne',
            Icons.offline_bolt_rounded,
            const OfflineReadinessScreen(),
          ),
        ),
        _Shortcut(
          const [
            'expiry',
            'péremption',
            'reminder',
            'rappel',
            'maintenance',
          ],
          _SearchHit(
            en ? 'Preparedness' : 'Préparation',
            en ? 'Maintenance & reminders' : 'Entretien & rappels',
            Icons.event_repeat_rounded,
            const MaintenanceScreen(),
          ),
        ),
        _Shortcut(
          const [
            'preparedness review',
            'revue',
            'annual check',
            'vérification',
          ],
          _SearchHit(
            en ? 'Preparedness' : 'Préparation',
            en ? 'Preparedness review' : 'Revue de préparation',
            Icons.fact_check_rounded,
            const PreparednessReviewScreen(),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final en = _en;
    final hits = _hits(_controller.text);

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(
          en ? 'Search ReadySafe' : 'Rechercher dans ReadySafe',
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              TextField(
                controller: _controller,
                autofocus: widget.initialQuery.isEmpty,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: en
                      ? 'E.g. CPR, water, pharmacy, flood…'
                      : 'Ex. RCP, eau, pharmacie, inondation…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              if (_controller.text.trim().isEmpty)
                _SearchHelp(en: en)
              else if (hits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      en
                          ? 'No matching result.'
                          : 'Aucun résultat correspondant.',
                    ),
                  ),
                )
              else ...[
                Text(
                  en
                      ? '${hits.length} result(s)'
                      : '${hits.length} résultat(s)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xff65747a),
                  ),
                ),
                const SizedBox(height: 8),
                ...hits.map(
                  (hit) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xffe7f3f1),
                        child: Icon(
                          hit.icon,
                          color: const Color(0xff087f83),
                        ),
                      ),
                      title: Text(
                        hit.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(hit.section),
                      trailing:
                          const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => hit.page,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchHelp extends StatelessWidget {
  const _SearchHelp({required this.en});

  final bool en;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffeaf6f4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              en ? 'Global search' : 'Recherche globale',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              en
                  ? 'Search for an action, risk, piece of equipment or tool: CPR, burn, water, kit, pharmacy, shelter, flood, alert, communication…'
                  : 'Cherchez un geste, un risque, un équipement ou un outil : RCP, brûlure, eau, kit, pharmacie, abri, inondation, alerte, communication…',
              style: const TextStyle(height: 1.4),
            ),
          ],
        ),
      );
}

class _Shortcut {
  const _Shortcut(this.terms, this.hit);

  final List<String> terms;
  final _SearchHit hit;
}

class _SearchHit {
  const _SearchHit(
    this.section,
    this.title,
    this.icon,
    this.page,
  );

  final String section;
  final String title;
  final IconData icon;
  final Widget page;
}

const _firstAidAliases = <String, List<String>>{
  'cpr_adult': ['adult cpr', 'rcp adulte', 'massage cardiaque'],
  'cpr_child': ['child cpr', 'rcp enfant'],
  'cpr_infant': ['infant cpr', 'rcp nourrisson'],
  'choking_adult': ['adult choking', 'étouffement adulte'],
  'choking_child': ['child choking', 'étouffement enfant'],
  'choking_infant': ['infant choking', 'étouffement nourrisson'],
  'bleeding': ['severe bleeding', 'hémorragie', 'hemorrhage'],
  'unconscious': ['unconscious', 'inconscience', 'recovery position', 'pls'],
  'aed': ['aed', 'dae', 'defibrillator', 'défibrillateur'],
  'drowning': ['drowning', 'noyade'],
  'anaphylaxis': ['anaphylaxis', 'anaphylaxie', 'severe allergy', 'allergie grave'],
  'stroke': ['stroke', 'avc'],
  'chest_pain': ['chest pain', 'douleur thoracique'],
  'asthma': ['asthma', 'asthme'],
  'hypoglycemia': ['hypoglycemia', 'hypoglycémie'],
  'burn': ['burn', 'brûlure'],
  'seizure': ['seizure', 'convulsion', 'crise épileptique'],
  'poisoning': ['poisoning', 'intoxication'],
};

const _hazardAliases = <String, List<String>>{
  'emergency': ['general emergency', 'urgence générale'],
  'evacuation': ['evacuation', 'évacuation'],
  'blackout': ['power outage', 'blackout', 'panne électrique'],
  'fire': ['fire', 'incendie'],
  'flood': ['flood', 'inondation'],
  'storm': ['storm', 'tempête'],
  'earthquake': ['earthquake', 'séisme', 'tremblement de terre'],
  'heat': ['extreme heat', 'canicule', 'chaleur extrême'],
  'cold': ['extreme cold', 'grand froid', 'froid extrême'],
  'water': ['water outage', 'coupure eau'],
  'shelter': ['shelter in place', 'confinement'],
  'wildfire': ['wildfire', 'feu de végétation'],
  'landslide': ['landslide', 'glissement de terrain'],
  'gas_leak': [
    'gas leak',
    'smell gas',
    'gas smell',
    'fuite de gaz',
    'odeur de gaz',
  ],
  'industrial': ['chemical incident', 'industrial incident', 'accident industriel'],
  'radiological': ['radiological', 'radiologique'],
  'outbreak': ['outbreak', 'epidemic', 'épidémie'],
};


