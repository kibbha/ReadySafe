import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CarbonMonoxideScreen extends StatelessWidget {
  const CarbonMonoxideScreen({super.key});

  Future<void> _openSource() async {
    final uri = Uri.parse('https://www.cdc.gov/carbon-monoxide/about/');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Carbon monoxide safety' : 'Sécurité monoxyde de carbone'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffffeeee), Color(0xfffff4e8)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xffd92d36),
                  child: Icon(Icons.warning_amber_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en
                            ? 'Carbon monoxide cannot be seen or smelled'
                            : 'Le monoxyde de carbone est invisible et inodore',
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        en
                            ? 'Fuel-burning equipment can create dangerous CO, especially during outages and severe weather.'
                            : 'Les appareils à combustion peuvent produire du CO dangereux, notamment pendant une panne électrique ou un épisode météo sévère.',
                        style: const TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _CoCard(
            icon: Icons.power_rounded,
            color: const Color(0xffd92d36),
            title: en ? 'Portable generators' : 'Groupes électrogènes',
            lines: en
                ? const [
                    'Use generators outdoors only.',
                    'Keep them more than 20 feet (about 6 metres) from windows, doors and vents.',
                    'Never use a generator inside a home, garage, basement, carport or camper.',
                    'Use extension cords and equipment rated for the intended outdoor use.',
                  ]
                : const [
                    'Utilisez les groupes électrogènes uniquement à l’extérieur.',
                    'Placez-les à plus de 20 pieds, soit environ 6 mètres, des fenêtres, portes et bouches d’aération.',
                    'N’utilisez jamais un groupe électrogène dans une maison, un garage, une cave, un abri voiture ou un camping-car.',
                    'Utilisez des rallonges et équipements prévus pour l’usage extérieur concerné.',
                  ],
          ),
          _CoCard(
            icon: Icons.outdoor_grill_outlined,
            color: const Color(0xffb7833f),
            title: en ? 'Other fuel-burning devices' : 'Autres appareils à combustion',
            lines: en
                ? const [
                    'Never burn charcoal indoors.',
                    'Do not use portable gas camping stoves indoors.',
                    'Do not heat the home with a gas oven.',
                    'Never run a vehicle in an attached garage, even with the garage door open.',
                  ]
                : const [
                    'Ne brûlez jamais de charbon de bois à l’intérieur.',
                    'N’utilisez pas de réchaud de camping à gaz à l’intérieur.',
                    'Ne chauffez pas le logement avec un four ou une cuisinière à gaz.',
                    'Ne laissez jamais tourner un véhicule dans un garage attenant, même porte ouverte.',
                  ],
          ),
          _CoCard(
            icon: Icons.sensors_rounded,
            color: const Color(0xff087f83),
            title: en ? 'Detection' : 'Détection',
            lines: en
                ? const [
                    'Use battery-powered or battery-backup carbon monoxide alarms.',
                    'Check alarm batteries regularly and replace devices according to the manufacturer instructions.',
                    'Place alarms according to local rules and the manufacturer instructions.',
                  ]
                : const [
                    'Utilisez des détecteurs de monoxyde de carbone à piles ou avec batterie de secours.',
                    'Vérifiez régulièrement les piles et remplacez les appareils selon les instructions du fabricant.',
                    'Installez les détecteurs conformément aux règles locales et à la notice du fabricant.',
                  ],
          ),
          _CoCard(
            icon: Icons.health_and_safety_outlined,
            color: const Color(0xff6750a4),
            title: en ? 'Possible poisoning' : 'Suspicion d’intoxication',
            lines: en
                ? const [
                    'Possible symptoms include headache, dizziness, weakness, nausea, vomiting, chest pain or confusion.',
                    'If CO poisoning is suspected, move to fresh air if you can do so safely and call emergency services.',
                    'Do not re-enter a suspected contaminated area until it has been declared safe.',
                  ]
                : const [
                    'Les signes possibles incluent maux de tête, vertiges, faiblesse, nausées, vomissements, douleur thoracique ou confusion.',
                    'En cas de suspicion, rejoignez l’air libre si vous pouvez le faire sans danger et appelez les secours.',
                    'Ne rentrez pas dans une zone suspectée contaminée avant qu’elle soit déclarée sûre.',
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
                const Icon(Icons.info_outline_rounded, color: Color(0xff9a6a00)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    en
                        ? 'Carbon monoxide exposure can become life-threatening quickly. Follow emergency-services instructions rather than trying to identify the source yourself.'
                        : 'Une exposition au monoxyde de carbone peut devenir rapidement mortelle. Suivez les instructions des secours plutôt que de chercher vous-même la source.',
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
              en ? 'Source: CDC carbon monoxide guidance' : 'Source : CDC — monoxyde de carbone',
            ),
          ),
        ],
      ),
    );
  }
}

class _CoCard extends StatelessWidget {
  const _CoCard({
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
