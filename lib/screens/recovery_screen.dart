import 'package:flutter/material.dart';

import 'emergency_food_safety_screen.dart';
import 'family_documents_screen.dart';
import 'official_sources_screen.dart';
import 'online_maps_screen.dart';
import 'recovery_log_screen.dart';

class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      const _RecoverySection(
        'Personnes d’abord',
        Icons.groups_rounded,
        Color(0xff087f83),
        [
          'Vérifiez que les membres du foyer sont en sécurité et rejoignez le point de rassemblement prévu.',
          'Suivez les instructions des secours et des autorités avant de retourner dans une zone évacuée.',
          'Signalez une personne manquante ou vulnérable aux services compétents lorsque cela est nécessaire.',
        ],
      ),
      const _RecoverySection(
        'Retour dans le logement',
        Icons.home_work_outlined,
        Color(0xffd16a32),
        [
          'N’entrez pas dans un bâtiment déclaré dangereux ou présentant des dégâts structurels visibles.',
          'N’allumez pas de flamme ou d’appareil électrique si une fuite de gaz ou un dommage électrique est suspecté.',
          'Photographiez les dégâts lorsque cela peut être fait en sécurité avant de déplacer les biens.',
        ],
      ),
      const _RecoverySection(
        'Eau, aliments et hygiène',
        Icons.water_drop_outlined,
        Color(0xff237fc7),
        [
          'Respectez tout avis officiel concernant la potabilité de l’eau.',
          'Écartez les aliments exposés à une contamination, une chaleur anormale ou une rupture prolongée de la chaîne du froid.',
          'Utilisez une source d’eau et des équipements d’hygiène sûrs pendant le nettoyage.',
        ],
      ),
      const _RecoverySection(
        'Documents et démarches',
        Icons.folder_copy_outlined,
        Color(0xff6750a4),
        [
          'Conservez les références utiles : photos, factures, contrats, numéros de dossier et coordonnées des intervenants.',
          'Contactez l’assurance ou les organismes concernés selon votre situation.',
          'Mettez à jour votre plan ReadySafe après l’événement : contacts, points de rassemblement et matériel manquant.',
        ],
      ),
      const _RecoverySection(
        'Information fiable',
        Icons.verified_outlined,
        Color(0xff147343),
        [
          'Continuez à consulter les canaux officiels tant que la situation n’est pas déclarée stabilisée.',
          'Vérifiez les messages avant de les partager, particulièrement les itinéraires, restrictions et consignes sanitaires.',
          'Ne vous fiez pas à une publication isolée si elle contredit les autorités responsables de la zone.',
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: const Text('Après l’urgence')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffe4f3f0), Color(0xfffff4e8)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xff087f83),
                  child: Icon(Icons.restore_rounded, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reprendre le contrôle étape par étape',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'La phase qui suit une urgence reste une période à risque. ReadySafe garde les actions essentielles dans un ordre simple.',
                        style: TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionChip(
                icon: Icons.family_restroom_rounded,
                label: 'Famille & documents',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FamilyDocumentsScreen()),
                ),
              ),
              _ActionChip(
                icon: Icons.map_rounded,
                label: 'Carte & repères',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OnlineMapsScreen()),
                ),
              ),
              _ActionChip(
                icon: Icons.restaurant_rounded,
                label: 'Aliments',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmergencyFoodSafetyScreen()),
                ),
              ),
              _ActionChip(
                icon: Icons.assignment_outlined,
                label: 'Journal après urgence',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecoveryLogScreen()),
                ),
              ),
              _ActionChip(
                icon: Icons.campaign_outlined,
                label: 'Sources officielles',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OfficialSourcesScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...sections.map((section) => _RecoveryCard(section: section)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xffffeeee),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xffd92d36)),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Ces conseils sont généraux. Une interdiction d’accès, une consigne de confinement, un avis sanitaire ou une instruction des secours doit toujours être respecté en priorité.',
                    style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoverySection {
  const _RecoverySection(this.title, this.icon, this.color, this.steps);
  final String title;
  final IconData icon;
  final Color color;
  final List<String> steps;
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({required this.section});
  final _RecoverySection section;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: section.color.withValues(alpha: .12),
            child: Icon(section.icon, color: section.color),
          ),
          title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 13),
          children: [
            for (var i = 0; i < section.steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: section.color,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(section.steps[i], style: const TextStyle(height: 1.35)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        avatar: Icon(icon, size: 18, color: const Color(0xff087f83)),
        label: Text(label),
        onPressed: onTap,
      );
}
