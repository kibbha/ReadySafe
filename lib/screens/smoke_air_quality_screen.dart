import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SmokeAirQualityScreen extends StatelessWidget {
  const SmokeAirQualityScreen({super.key});

  Future<void> _openSource() async {
    final uri = Uri.parse(
      'https://www.epa.gov/emergencies-iaq/create-clean-room-protect-indoor-air-quality-during-wildfire',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Smoke & indoor air' : 'Fumée & qualité de l’air'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffffeeee), Color(0xffeef3f4)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xffd16a32),
                  child: Icon(Icons.air_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en
                            ? 'Reduce smoke exposure while staying ready to evacuate'
                            : 'Réduire l’exposition à la fumée tout en restant prêt à évacuer',
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        en
                            ? 'Wildfire smoke can enter buildings and make indoor air unhealthy. Follow local air-quality and evacuation instructions first.'
                            : 'La fumée de feu de végétation peut pénétrer dans les bâtiments et dégrader l’air intérieur. Suivez d’abord les consignes locales sur la qualité de l’air et l’évacuation.',
                        style: const TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _AirCard(
            icon: Icons.meeting_room_outlined,
            color: const Color(0xff087f83),
            title: en ? 'Create a cleaner-air room' : 'Créer une pièce à air plus propre',
            lines: en
                ? const [
                    'Choose a room that can fit the household and can be closed off.',
                    'Close windows and doors without blocking your ability to leave in an emergency.',
                    'Use a suitable portable air cleaner if available.',
                    'Spend as much time as practical in that room while smoke levels remain high.',
                  ]
                : const [
                    'Choisissez une pièce pouvant accueillir le foyer et être isolée du reste du logement.',
                    'Fermez fenêtres et portes sans bloquer la possibilité de sortir en urgence.',
                    'Utilisez un purificateur d’air adapté si vous en avez un.',
                    'Passez autant de temps que possible dans cette pièce tant que la fumée reste importante.',
                  ],
          ),
          _AirCard(
            icon: Icons.air_outlined,
            color: const Color(0xff237fc7),
            title: en ? 'Reduce incoming smoke' : 'Limiter l’entrée de fumée',
            lines: en
                ? const [
                    'Set compatible air-conditioning or ventilation systems to recirculate rather than draw outdoor air.',
                    'Use high-efficiency filtration when compatible with your system.',
                    'Check and replace heavily soiled filters more often during smoke events.',
                  ]
                : const [
                    'Réglez les systèmes compatibles en recirculation plutôt qu’en apport d’air extérieur.',
                    'Utilisez une filtration à haute efficacité si elle est compatible avec votre installation.',
                    'Contrôlez et remplacez plus souvent les filtres très encrassés pendant un épisode de fumée.',
                  ],
          ),
          _AirCard(
            icon: Icons.do_not_disturb_alt_rounded,
            color: const Color(0xffd92d36),
            title: en ? 'Avoid making indoor air worse' : 'Ne pas aggraver l’air intérieur',
            lines: en
                ? const [
                    'Avoid smoking or vaping indoors.',
                    'Avoid candles, incense and activities that create particles.',
                    'Avoid frying or broiling food when smoke levels are high.',
                    'Avoid vacuuming unless using a HEPA-equipped vacuum.',
                  ]
                : const [
                    'Évitez de fumer ou vapoter à l’intérieur.',
                    'Évitez bougies, encens et activités produisant des particules.',
                    'Évitez friture ou cuisson à très haute température pendant les épisodes de fumée.',
                    'Évitez l’aspirateur sauf s’il est équipé d’un filtre HEPA.',
                  ],
          ),
          _AirCard(
            icon: Icons.directions_run_rounded,
            color: const Color(0xffb7833f),
            title: en ? 'Know when staying inside is no longer enough' : 'Savoir quand rester à l’intérieur ne suffit plus',
            lines: en
                ? const [
                    'Remain ready to evacuate if authorities instruct you to leave.',
                    'Seek a cleaner-air location if smoke remains severe, indoor heat becomes unsafe or power loss makes the home unsuitable.',
                    'People with heart or lung disease, older adults, children and pregnant people may need extra precautions.',
                  ]
                : const [
                    'Restez prêt à évacuer si les autorités vous demandent de partir.',
                    'Rejoignez un lieu à l’air plus propre si la fumée reste importante, si la chaleur intérieure devient dangereuse ou si une panne rend le logement inadapté.',
                    'Les personnes souffrant de maladies cardiaques ou respiratoires, les seniors, les enfants et les personnes enceintes peuvent nécessiter des précautions supplémentaires.',
                  ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xfffff4c7),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.health_and_safety_outlined, color: Color(0xff9a6a00)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    en
                        ? 'If you have asthma, heart disease or another condition affected by smoke, follow your clinician’s action plan and seek urgent medical help for severe symptoms.'
                        : 'Si vous avez de l’asthme, une maladie cardiaque ou une autre pathologie aggravée par la fumée, suivez le plan établi avec votre soignant et demandez une aide médicale urgente en cas de symptômes sévères.',
                    style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openSource,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(
              en
                  ? 'Source: US EPA cleaner-air room guidance'
                  : 'Source : EPA — pièce à air plus propre',
            ),
          ),
        ],
      ),
    );
  }
}

class _AirCard extends StatelessWidget {
  const _AirCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: .12),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 18, color: color),
                      const SizedBox(width: 7),
                      Expanded(child: Text(line, style: const TextStyle(height: 1.33))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
}
