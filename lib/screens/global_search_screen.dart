import 'package:flutter/material.dart';

import '../data/content.dart';
import '../data/first_aid_repository.dart';
import 'checklist_screen.dart';
import 'communication_plan_screen.dart';
import 'emergency_plan_summary_screen.dart';
import 'family_documents_screen.dart';
import 'first_aid_screen.dart';
import 'guide_list_screen.dart';
import 'home_safety_screen.dart';
import 'offline_readiness_screen.dart';
import 'official_sources_screen.dart';
import 'power_outage_screen.dart';
import 'preparedness_review_screen.dart';
import 'recovery_screen.dart';
import 'safety_tools_screen.dart';
import 'special_kits_screen.dart';
import 'support_needs_screen.dart';
import 'online_maps_screen.dart';
import 'survival_hub_screen.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key, this.initialQuery = ''});
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

  List<_SearchHit> _hits(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final hits = <_SearchHit>[];
    for (final guide in firstAidGuides) {
      final terms = '${guide.id} ${guide.titleKey} ${guide.summaryKey}'.toLowerCase();
      if (terms.contains(q) ||
          (q.contains('rcp') && guide.id.contains('cpr')) ||
          (q.contains('étouff') && guide.id.contains('choking')) ||
          (q.contains('hemorr') && guide.id.contains('bleeding')) ||
          (q.contains('hémorr') && guide.id.contains('bleeding')) ||
          (q.contains('allerg') && guide.id.contains('anaphylaxis'))) {
        hits.add(_SearchHit(
          'Premiers secours',
          _labelAid(guide.id),
          Icons.health_and_safety_rounded,
          const FirstAidScreen(),
        ));
      }
    }

    for (final guide in disasterGuides) {
      if ('${guide.title} ${guide.immediate} ${guide.steps.join(' ')}'.toLowerCase().contains(q)) {
        hits.add(_SearchHit(
          'Risques',
          guide.title,
          Icons.warning_amber_rounded,
          const GuideListScreen(kind: GuideKind.disasters),
        ));
      }
    }

    for (final guide in emergencyGuides) {
      if ('${guide.title} ${guide.immediate} ${guide.steps.join(' ')}'.toLowerCase().contains(q)) {
        hits.add(_SearchHit(
          'Réflexes de survie',
          guide.title,
          Icons.shield_outlined,
          const GuideListScreen(kind: GuideKind.emergencies),
        ));
      }
    }

    const shortcuts = <String, _SearchHit>{
      'eau': _SearchHit('Kits & survie', 'Eau & réserves', Icons.water_drop_rounded, SurvivalHubScreen()),
      'kit': _SearchHit('Kits & survie', 'Kit 72 h', Icons.backpack_rounded, ChecklistScreen(kit: true)),
      'voiture': _SearchHit('Kits & survie', 'Kits spécialisés', Icons.directions_car_rounded, SpecialKitsScreen()),
      'voyage': _SearchHit('Kits & survie', 'Kits spécialisés', Icons.luggage_rounded, SpecialKitsScreen()),
      'animal': _SearchHit('Kits & survie', 'Kits spécialisés', Icons.pets_rounded, SpecialKitsScreen()),
      'bébé': _SearchHit('Kits & survie', 'Kits spécialisés', Icons.child_care_rounded, SpecialKitsScreen()),
      'evacuation bag': _SearchHit('Kits & survie', 'Kits spécialisés', Icons.inventory_2_rounded, SpecialKitsScreen()),
      'check': _SearchHit('Kits & survie', 'Check-lists', Icons.fact_check_rounded, ChecklistScreen(kit: false)),
      'famille': _SearchHit('Famille', 'Famille & documents', Icons.family_restroom_rounded, FamilyDocumentsScreen()),
      'document': _SearchHit('Famille', 'Documents importants', Icons.folder_copy_rounded, FamilyDocumentsScreen()),
      'pharmacie': _SearchHit('Carte', 'Carte & repères', Icons.local_pharmacy_rounded, OnlineMapsScreen()),
      'hôpital': _SearchHit('Carte', 'Santé à proximité', Icons.local_hospital_rounded, OnlineMapsScreen()),
      'hopital': _SearchHit('Carte', 'Santé à proximité', Icons.local_hospital_rounded, OnlineMapsScreen()),
      'abri': _SearchHit('Carte', 'Abris & lieux sûrs', Icons.home_work_rounded, OnlineMapsScreen()),
      'carte': _SearchHit('Carte', 'Carte & repères', Icons.map_rounded, OnlineMapsScreen()),
      'plan urgence': _SearchHit('Famille', 'Mon plan d’urgence', Icons.assignment_turned_in_rounded, EmergencyPlanSummaryScreen()),
      'plan d’urgence': _SearchHit('Famille', 'Mon plan d’urgence', Icons.assignment_turned_in_rounded, EmergencyPlanSummaryScreen()),
      'communication': _SearchHit('Famille', 'Plan de communication', Icons.connect_without_contact_rounded, CommunicationPlanScreen()),
      'contact extérieur': _SearchHit('Famille', 'Plan de communication', Icons.connect_without_contact_rounded, CommunicationPlanScreen()),
      'alerte': _SearchHit('Officiel', 'Alertes & sources officielles', Icons.campaign_rounded, OfficialSourcesScreen()),
      'source officielle': _SearchHit('Officiel', 'Alertes & sources officielles', Icons.verified_outlined, OfficialSourcesScreen()),
      'après': _SearchHit('Après l’urgence', 'Récupération', Icons.restore_rounded, RecoveryScreen()),
      'retour maison': _SearchHit('Après l’urgence', 'Récupération', Icons.restore_rounded, RecoveryScreen()),
      'signal sos': _SearchHit('Outils', 'Outils d’urgence', Icons.sos_rounded, SafetyToolsScreen()),
      'outil': _SearchHit('Outils', 'Outils d’urgence', Icons.handyman_rounded, SafetyToolsScreen()),
      'panne électrique': _SearchHit('Préparation', 'Panne électrique', Icons.power_off_rounded, PowerOutageScreen()),
      'blackout': _SearchHit('Préparation', 'Panne électrique', Icons.power_off_rounded, PowerOutageScreen()),
      'courant': _SearchHit('Préparation', 'Panne électrique', Icons.power_off_rounded, PowerOutageScreen()),
      'domicile': _SearchHit('Préparation', 'Sécurité du domicile', Icons.home_work_rounded, HomeSafetyScreen()),
      'gaz': _SearchHit('Préparation', 'Sécurité du domicile', Icons.settings_input_component_rounded, HomeSafetyScreen()),
      'électricité': _SearchHit('Préparation', 'Sécurité du domicile', Icons.electrical_services_rounded, HomeSafetyScreen()),
      'accessibilité': _SearchHit('Famille', 'Besoins spécifiques', Icons.accessibility_new_rounded, SupportNeedsScreen()),
      'mobilité': _SearchHit('Famille', 'Besoins spécifiques', Icons.accessible_forward_rounded, SupportNeedsScreen()),
      'audition': _SearchHit('Famille', 'Besoins spécifiques', Icons.hearing_rounded, SupportNeedsScreen()),
      'hors ligne': _SearchHit('Préparation', 'Préparation hors ligne', Icons.offline_bolt_rounded, OfflineReadinessScreen()),
      'offline': _SearchHit('Préparation', 'Préparation hors ligne', Icons.offline_bolt_rounded, OfflineReadinessScreen()),
      'revue': _SearchHit('Préparation', 'Revue de préparation', Icons.fact_check_rounded, PreparednessReviewScreen()),
      'vérification': _SearchHit('Préparation', 'Revue de préparation', Icons.fact_check_rounded, PreparednessReviewScreen()),
    };
    for (final entry in shortcuts.entries) {
      if (entry.key.contains(q) || q.contains(entry.key)) hits.add(entry.value);
    }

    final unique = <String, _SearchHit>{};
    for (final hit in hits) {
      unique['${hit.section}|${hit.title}'] = hit;
    }
    return unique.values.take(12).toList();
  }

  String _labelAid(String id) {
    switch (id) {
      case 'cpr_adult':
        return 'RCP adulte';
      case 'cpr_child':
        return 'RCP enfant';
      case 'cpr_infant':
        return 'RCP nourrisson';
      case 'choking_adult':
        return 'Étouffement adulte';
      case 'choking_child':
        return 'Étouffement enfant';
      case 'choking_infant':
        return 'Étouffement nourrisson';
      case 'bleeding':
        return 'Hémorragie grave';
      case 'unconscious':
        return 'Inconscience & PLS';
      case 'aed':
        return 'DAE';
      case 'drowning':
        return 'Noyade';
      case 'anaphylaxis':
        return 'Anaphylaxie';
      default:
        return 'Guide de premiers secours';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hits = _hits(_controller.text);
    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher dans ReadySafe')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          TextField(
            controller: _controller,
            autofocus: widget.initialQuery.isEmpty,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Ex. RCP, eau, pharmacie, inondation…',
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
            const _SearchHelp()
          else if (hits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: Text('Aucun résultat correspondant.')),
            )
          else ...[
            Text(
              '${hits.length} résultat(s)',
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xff65747a)),
            ),
            const SizedBox(height: 8),
            ...hits.map(
              (hit) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xffe7f3f1),
                    child: Icon(hit.icon, color: const Color(0xff087f83)),
                  ),
                  title: Text(hit.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(hit.section),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => hit.page),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchHelp extends StatelessWidget {
  const _SearchHelp();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffeaf6f4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recherche globale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            SizedBox(height: 6),
            Text(
              'Cherchez un geste, un risque, un équipement ou un outil : RCP, brûlure, eau, kit, pharmacie, abri, inondation, alerte, communication…',
              style: TextStyle(height: 1.4),
            ),
          ],
        ),
      );
}

class _SearchHit {
  const _SearchHit(this.section, this.title, this.icon, this.page);
  final String section;
  final String title;
  final IconData icon;
  final Widget page;
}
