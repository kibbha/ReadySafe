import 'package:flutter/material.dart';

import '../app/localizations.dart';
import 'communication_plan_screen.dart';
import 'emergency_plan_summary_screen.dart';
import 'emergency_screen.dart';
import 'family_documents_screen.dart';
import 'family_reunification_screen.dart';
import 'first_aid_screen.dart';
import 'guide_list_screen.dart';
import 'home_safety_screen.dart';
import 'maintenance_screen.dart';
import 'medical_continuity_screen.dart';
import 'offline_readiness_screen.dart';
import 'official_sources_screen.dart';
import 'pet_emergency_screen.dart';
import 'power_outage_screen.dart';
import 'preparedness_review_screen.dart';
import 'recovery_log_screen.dart';
import 'recovery_screen.dart';
import 'safety_tools_screen.dart';
import 'secure_vault_screen.dart';
import 'settings_screen.dart';
import 'support_needs_screen.dart';
import 'training_screen.dart';
import 'travel_emergency_screen.dart';
import 'vehicle_emergency_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';

    final sections = <_MoreSection>[
      _MoreSection(
        en ? 'Emergency' : 'Urgence',
        en
            ? 'Immediate actions and official information'
            : 'Actions immédiates et information officielle',
        Icons.sos_rounded,
        [
          _MoreItem(
            en ? 'First aid' : 'Premiers secours',
            en ? 'Illustrated guides and step-by-step emergency mode' : 'Fiches illustrées et mode urgence pas à pas',
            Icons.health_and_safety_rounded,
            const FirstAidScreen(),
          ),
          _MoreItem(
            en ? 'Emergency numbers' : 'Numéros d’urgence',
            en ? 'Official numbers for the active country' : 'Numéros officiels du pays actif',
            Icons.phone_in_talk_rounded,
            const EmergencyScreen(),
          ),
          _MoreItem(
            en ? 'Emergency tools' : 'Outils d’urgence',
            en ? 'SOS signal, messages, numbers and landmarks' : 'Signal SOS, messages, numéros et repères',
            Icons.handyman_rounded,
            const SafetyToolsScreen(),
          ),
          _MoreItem(
            en ? 'Official alerts & sources' : 'Alertes & sources officielles',
            en ? 'Trusted government warning channels' : 'Canaux d’alerte gouvernementaux fiables',
            Icons.campaign_rounded,
            const OfficialSourcesScreen(),
          ),
        ],
      ),
      _MoreSection(
        en ? 'Family & essential information' : 'Famille & informations essentielles',
        en
            ? 'Keep the household connected and ready'
            : 'Garder le foyer coordonné et prêt',
        Icons.family_restroom_rounded,
        [
          _MoreItem(
            en ? 'My emergency plan' : 'Mon plan d’urgence',
            en ? 'One operational summary for the household' : 'Une synthèse opérationnelle du foyer',
            Icons.assignment_turned_in_rounded,
            const EmergencyPlanSummaryScreen(),
          ),
          _MoreItem(
            en ? 'Family & documents' : 'Famille & documents',
            en ? 'Contacts, household plan and document checklist' : 'Contacts, plan familial et checklist documentaire',
            Icons.folder_copy_rounded,
            const FamilyDocumentsScreen(),
          ),
          _MoreItem(
            en ? 'Family reunification' : 'Réunification familiale',
            en ? 'Meeting places, child pickup and emergency card' : 'Rendez-vous, récupération des enfants et carte urgence',
            Icons.family_restroom_rounded,
            const FamilyReunificationScreen(),
          ),
          _MoreItem(
            en ? 'Communication plan' : 'Plan de communication',
            en ? 'Out-of-area contact, reconnection and safe message' : 'Contact extérieur, reconnexion et message rapide',
            Icons.connect_without_contact_rounded,
            const CommunicationPlanScreen(),
          ),
          _MoreItem(
            en ? 'Secure vault' : 'Coffre sécurisé',
            en ? 'Encrypted references and sensitive emergency notes' : 'Références chiffrées et notes sensibles',
            Icons.lock_rounded,
            const SecureVaultScreen(),
          ),
          _MoreItem(
            en ? 'Medical continuity' : 'Continuité médicale',
            en ? 'Medicines, devices, refrigeration and backup care' : 'Traitements, appareils, froid et solution de secours',
            Icons.medical_services_rounded,
            const MedicalContinuityScreen(),
          ),
          _MoreItem(
            en ? 'Pets' : 'Animaux',
            en ? 'Evacuation, shelter, identification and supplies' : 'Évacuation, hébergement, identification et matériel',
            Icons.pets_rounded,
            const PetEmergencyScreen(),
          ),
          _MoreItem(
            en ? 'Accessibility & support needs' : 'Besoins spécifiques',
            en ? 'Mobility, hearing, vision, assistance and power needs' : 'Mobilité, audition, vision, aide et énergie',
            Icons.accessibility_new_rounded,
            const SupportNeedsScreen(),
          ),
        ],
      ),
      _MoreSection(
        en ? 'Preparedness' : 'Préparation',
        en
            ? 'Home, vehicle, power and offline readiness'
            : 'Domicile, véhicule, énergie et fonctionnement hors ligne',
        Icons.backpack_rounded,
        [
          _MoreItem(
            en ? 'Home safety' : 'Sécurité du domicile',
            en ? 'Exits, utilities, alarms and safe indoor area' : 'Sorties, coupures techniques, détecteurs et zone sûre',
            Icons.home_work_rounded,
            const HomeSafetyScreen(),
          ),
          _MoreItem(
            en ? 'Travel emergency' : 'Urgence en voyage',
            en ? 'Local emergency numbers, documents and consular references' : 'Numéros locaux, documents et références consulaires',
            Icons.luggage_rounded,
            const TravelEmergencyScreen(),
          ),
          _MoreItem(
            en ? 'Vehicle emergency' : 'Urgence véhicule',
            en ? 'Breakdown, crash, severe weather and roadside readiness' : 'Panne, accident, météo sévère et préparation routière',
            Icons.directions_car_rounded,
            const VehicleEmergencyScreen(),
          ),
          _MoreItem(
            en ? 'Power outage' : 'Panne électrique',
            en ? 'Power continuity, food safety and carbon monoxide' : 'Énergie, froid alimentaire, communication et sécurité CO',
            Icons.power_off_rounded,
            const PowerOutageScreen(),
          ),
          _MoreItem(
            en ? 'Offline readiness' : 'Préparation hors ligne',
            en ? 'Check what remains useful without connectivity' : 'Vérifier ce qui reste utile sans connexion',
            Icons.offline_bolt_rounded,
            const OfflineReadinessScreen(),
          ),
          _MoreItem(
            en ? 'Maintenance & reminders' : 'Entretien & rappels',
            en ? 'Expiry dates and periodic preparedness checks' : 'Péremptions et vérifications périodiques',
            Icons.event_repeat_rounded,
            const MaintenanceScreen(),
          ),
          _MoreItem(
            en ? 'Preparedness review' : 'Revue de préparation',
            en ? 'Annual review of contacts, supplies and plans' : 'Revoir chaque année contacts, réserves et plans',
            Icons.fact_check_rounded,
            const PreparednessReviewScreen(),
          ),
        ],
      ),
      _MoreSection(
        en ? 'Risks & survival knowledge' : 'Risques & connaissances',
        en
            ? 'Hazard guidance and essential survival resources'
            : 'Guides de risques et ressources essentielles de survie',
        Icons.thunderstorm_rounded,
        [
          _MoreItem(
            en ? 'Risks & disasters' : 'Risques & catastrophes',
            en ? 'Fire, flood, storm, earthquake and more' : 'Incendie, inondation, tempête, séisme et plus',
            Icons.thunderstorm_rounded,
            const GuideListScreen(kind: GuideKind.disasters),
          ),
          _MoreItem(
            en ? 'Survival advice' : 'Ressources & conseils',
            en ? 'Evacuation, shelter, outages and essential actions' : 'Évacuation, confinement, pannes et réflexes essentiels',
            Icons.menu_book_rounded,
            const GuideListScreen(kind: GuideKind.emergencies),
          ),
        ],
      ),
      _MoreSection(
        en ? 'After & learn' : 'Après & apprendre',
        en
            ? 'Recovery, documentation and practice'
            : 'Récupération, documentation et entraînement',
        Icons.restore_rounded,
        [
          _MoreItem(
            en ? 'After the emergency' : 'Après l’urgence',
            en ? 'Safe return, home safety and practical next steps' : 'Retour, sécurité du logement et démarches essentielles',
            Icons.restore_rounded,
            const RecoveryScreen(),
          ),
          _MoreItem(
            en ? 'Recovery log' : 'Journal après urgence',
            en ? 'Damage, contacts, case numbers and follow-up' : 'Dégâts, contacts, numéros de dossier et suivi',
            Icons.assignment_outlined,
            const RecoveryLogScreen(),
          ),
          _MoreItem(
            en ? 'Training & drills' : 'Formation & exercices',
            en ? 'Practise and refresh essential actions' : 'Réviser et tester les actions essentielles',
            Icons.school_rounded,
            const TrainingScreen(),
          ),
        ],
      ),
      _MoreSection(
        en ? 'Application' : 'Application',
        en ? 'Country, language and display preferences' : 'Pays, langue et préférences d’affichage',
        Icons.settings_outlined,
        [
          _MoreItem(
            t.get('settings'),
            en ? 'Country, language, travel mode and accessibility' : 'Pays, langue, mode voyage et accessibilité',
            Icons.settings_outlined,
            const SettingsScreen(),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.get('more'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffe5f4f1), Color(0xfffff4e8)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xff087f83),
                  child: Icon(Icons.shield_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en ? 'ReadySafe center' : 'Centre ReadySafe',
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        en
                            ? 'Everything that does not need to occupy the main navigation, organised by purpose.'
                            : 'Tout ce qui n’a pas besoin d’occuper la navigation principale, organisé par usage.',
                        style: const TextStyle(color: Color(0xff65747a), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final section in sections) ...[
            _SectionHeader(section: section),
            const SizedBox(height: 7),
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < section.items.length; i++) ...[
                    _MoreTile(item: section.items[i]),
                    if (i != section.items.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});
  final _MoreSection section;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xffe6f3f1),
            child: Icon(section.icon, size: 19, color: const Color(0xff087f83)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                Text(
                  section.subtitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xff65747a)),
                ),
              ],
            ),
          ),
        ],
      );
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.item});
  final _MoreItem item;

  @override
  Widget build(BuildContext context) => ListTile(
        minTileHeight: 70,
        leading: CircleAvatar(
          backgroundColor: const Color(0xffe7f3f1),
          child: Icon(item.icon, color: const Color(0xff087f83)),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.page),
        ),
      );
}

class _MoreSection {
  const _MoreSection(
    this.title,
    this.subtitle,
    this.icon,
    this.items,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final List<_MoreItem> items;
}

class _MoreItem {
  const _MoreItem(this.title, this.subtitle, this.icon, this.page);

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}
