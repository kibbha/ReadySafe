import 'package:flutter/material.dart';

import '../app/localizations.dart';
import 'emergency_screen.dart';
import 'communication_plan_screen.dart';
import 'family_documents_screen.dart';
import 'first_aid_screen.dart';
import 'guide_list_screen.dart';
import 'official_sources_screen.dart';
import 'preparedness_review_screen.dart';
import 'recovery_screen.dart';
import 'safety_tools_screen.dart';
import 'settings_screen.dart';
import 'training_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';
    final items = <_MoreItem>[
      _MoreItem(
        en ? 'First aid' : 'Premiers secours',
        en ? 'Visual guides and step-by-step mode' : 'Fiches visuelles et mode pas à pas',
        Icons.health_and_safety_rounded,
        const FirstAidScreen(),
      ),
      _MoreItem(
        en ? 'Family & documents' : 'Famille & documents',
        en ? 'Contacts, plans and document checklist' : 'Contacts, plan familial et documents',
        Icons.family_restroom_rounded,
        const FamilyDocumentsScreen(),
      ),
      _MoreItem(
        en ? 'Emergency tools' : 'Outils d’urgence',
        en ? 'SOS signal, messages, numbers and landmarks' : 'Signal SOS, messages, numéros et repères',
        Icons.handyman_rounded,
        const SafetyToolsScreen(),
      ),
      _MoreItem(
        en ? 'Communication plan' : 'Plan de communication',
        en ? 'Reconnect your household after an incident' : 'Contact extérieur, reconnexion et message rapide',
        Icons.connect_without_contact_rounded,
        const CommunicationPlanScreen(),
      ),
      _MoreItem(
        en ? 'Emergency numbers' : 'Numéros d’urgence',
        en ? 'Official numbers for the active country' : 'Numéros officiels du pays actif',
        Icons.phone_in_talk_rounded,
        const EmergencyScreen(),
      ),
      _MoreItem(
        en ? 'Official alerts & sources' : 'Alertes & sources officielles',
        en ? 'Open trusted government warning channels' : 'Ouvrir les canaux officiels du pays actif',
        Icons.campaign_rounded,
        const OfficialSourcesScreen(),
      ),
      _MoreItem(
        en ? 'After the emergency' : 'Après l’urgence',
        en ? 'Recovery, home safety and practical next steps' : 'Retour, sécurité du logement et démarches essentielles',
        Icons.restore_rounded,
        const RecoveryScreen(),
      ),
      _MoreItem(
        en ? 'Risks & disasters' : 'Risques & catastrophes',
        en ? 'Before, during and after major events' : 'Avant, pendant et après les situations majeures',
        Icons.thunderstorm_rounded,
        const GuideListScreen(kind: GuideKind.disasters),
      ),
      _MoreItem(
        en ? 'Survival advice' : 'Ressources & conseils',
        en ? 'Blackout, evacuation and shelter guidance' : 'Panne, évacuation, confinement et réflexes utiles',
        Icons.menu_book_rounded,
        const GuideListScreen(kind: GuideKind.emergencies),
      ),
      _MoreItem(
        en ? 'Preparedness review' : 'Revue de préparation',
        en ? 'Annual review of contacts, supplies and plans' : 'Revoir chaque année contacts, réserves et plans',
        Icons.fact_check_rounded,
        const PreparednessReviewScreen(),
      ),
      _MoreItem(
        en ? 'Training' : 'Formation & exercices',
        en ? 'Practise and refresh your knowledge' : 'Réviser et tester votre préparation',
        Icons.school_rounded,
        const TrainingScreen(),
      ),
      _MoreItem(
        t.get('settings'),
        en ? 'Country, language and travel mode' : 'Pays, langue et mode voyage',
        Icons.settings_outlined,
        const SettingsScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.get('more'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffe5f4f1), Color(0xfffff4e8)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xff087f83),
                  child: Icon(Icons.shield_rounded, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Centre ReadySafe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      SizedBox(height: 2),
                      Text(
                        'Premiers secours, préparation, famille, ressources et paramètres.',
                        style: TextStyle(color: Color(0xff65747a)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                minTileHeight: 70,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xffe7f3f1),
                  child: Icon(item.icon, color: const Color(0xff087f83)),
                ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.page),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem(this.title, this.subtitle, this.icon, this.page);
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}
