import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VolcanoSafetyScreen extends StatelessWidget {
  const VolcanoSafetyScreen({super.key});

  Future<void> _openSource() async {
    final uri = Uri.parse(
      'https://www.ready.gov/sites/default/files/2025-02/fema_full-suite-hazard-info-sheets.pdf',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(en ? 'Volcano & ash safety' : 'Volcan & cendres')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          _VolcanoHero(
            title: en
                ? 'Follow evacuation or shelter orders early'
                : 'Suivre rapidement les ordres d’évacuation ou de mise à l’abri',
            body: en
                ? 'Volcanic hazards include ash, gases, rockfall, lava and fast-moving debris or mudflows.'
                : 'Les dangers volcaniques incluent cendres, gaz, projections, lave et coulées rapides de débris ou de boue.',
          ),
          const SizedBox(height: 14),
          _VolcanoCard(
            icon: Icons.campaign_outlined,
            color: const Color(0xffd92d36),
            title: en ? 'Alerts and evacuation' : 'Alertes et évacuation',
            lines: en
                ? const [
                    'Follow local alerts and evacuation orders.',
                    'Evacuate early when instructed rather than waiting for conditions to worsen.',
                    'Avoid areas downwind of the eruption and river valleys downstream when authorities identify those areas as dangerous.',
                  ]
                : const [
                    'Suivez les alertes locales et les ordres d’évacuation.',
                    'Évacuez tôt lorsque cela est demandé, plutôt que d’attendre que la situation se dégrade.',
                    'Évitez les zones sous le vent et les vallées en aval lorsque les autorités les signalent comme dangereuses.',
                  ],
          ),
          _VolcanoCard(
            icon: Icons.air_rounded,
            color: const Color(0xff6750a4),
            title: en ? 'Volcanic ash' : 'Cendres volcaniques',
            lines: en
                ? const [
                    'If told to shelter from ash, close windows and doors and reduce outdoor air entering the building.',
                    'Protect eyes and breathing passages if you must go outside.',
                    'People with respiratory disease should avoid ash exposure and follow medical advice.',
                    'Avoid driving in heavy ash because visibility can fall and ash can damage engines.',
                  ]
                : const [
                    'Si une mise à l’abri contre les cendres est demandée, fermez fenêtres et portes et réduisez l’entrée d’air extérieur.',
                    'Protégez les yeux et les voies respiratoires si vous devez sortir.',
                    'Les personnes souffrant de maladie respiratoire doivent éviter l’exposition aux cendres et suivre leur avis médical.',
                    'Évitez de conduire sous une forte chute de cendres : la visibilité diminue et les cendres peuvent endommager le moteur.',
                  ],
          ),
          _VolcanoCard(
            icon: Icons.water_rounded,
            color: const Color(0xff237fc7),
            title: en ? 'Water and mudflows' : 'Eau et coulées de boue',
            lines: en
                ? const [
                    'Volcanic activity can contaminate water supplies; follow local drinking-water advisories.',
                    'Mudflows and debris flows can move along valleys and waterways.',
                    'Do not cross a river, bridge or low area when a debris flow is approaching.',
                  ]
                : const [
                    'Une activité volcanique peut contaminer les réserves d’eau : suivez les avis locaux sur l’eau potable.',
                    'Les coulées de boue et de débris peuvent suivre vallées et cours d’eau.',
                    'Ne traversez pas une rivière, un pont ou une zone basse lorsqu’une coulée de débris approche.',
                  ],
          ),
          _VolcanoCard(
            icon: Icons.home_repair_service_outlined,
            color: const Color(0xffb7833f),
            title: en ? 'After ashfall' : 'Après une chute de cendres',
            lines: en
                ? const [
                    'Wait for authorities to say it is safe to return or work outside.',
                    'Ash can make roofs and surfaces slippery and heavy; do not climb onto roofs unless you have appropriate guidance and equipment.',
                    'Keep ash out of indoor living areas as much as possible and protect yourself during cleanup.',
                  ]
                : const [
                    'Attendez que les autorités déclarent le retour ou les travaux extérieurs suffisamment sûrs.',
                    'Les cendres rendent les toits et surfaces glissants et peuvent devenir très lourdes : ne montez pas sur un toit sans consignes et équipement adaptés.',
                    'Limitez l’entrée de cendres dans les espaces de vie et protégez-vous pendant le nettoyage.',
                  ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openSource,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(en ? 'Source: Ready.gov volcano guidance' : 'Source : Ready.gov — volcan'),
          ),
        ],
      ),
    );
  }
}

class _VolcanoHero extends StatelessWidget {
  const _VolcanoHero({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffffeeee), Color(0xfffff3df)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xffd16a32),
              child: Icon(Icons.volcano_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(color: Color(0xff65747a), height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _VolcanoCard extends StatelessWidget {
  const _VolcanoCard({
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
