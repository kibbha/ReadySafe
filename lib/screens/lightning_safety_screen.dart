import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LightningSafetyScreen extends StatelessWidget {
  const LightningSafetyScreen({super.key});

  Future<void> _openSource() async {
    final uri = Uri.parse(
      'https://www.ready.gov/sites/default/files/2024-08/ready-gov_thunderstorm_info-sheet.pdf',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Thunderstorm & lightning' : 'Orage & foudre'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          _LightningHero(
            title: en
                ? 'When thunder roars, go indoors'
                : 'Dès que le tonnerre gronde, se mettre à l’abri',
            body: en
                ? 'A sturdy building is the safest place during a thunderstorm. A hard-topped vehicle can be a fallback when a building is unavailable.'
                : 'Un bâtiment solide est l’endroit le plus sûr pendant un orage. Un véhicule fermé à toit rigide peut servir de solution de repli si aucun bâtiment n’est disponible.',
          ),
          const SizedBox(height: 14),
          _LightningCard(
            icon: Icons.home_rounded,
            color: const Color(0xff087f83),
            title: en ? 'Move to safe shelter' : 'Rejoindre un abri sûr',
            lines: en
                ? const [
                    'Go indoors immediately when you hear thunder or receive a thunderstorm warning.',
                    'If boating or swimming, get to land and move into a sturdy grounded shelter or suitable vehicle.',
                    'Do not shelter under an isolated tree, open shelter or exposed structure.',
                  ]
                : const [
                    'Rentrez immédiatement à l’intérieur lorsque vous entendez le tonnerre ou recevez une alerte d’orage.',
                    'Si vous êtes sur l’eau ou en train de nager, regagnez la terre ferme puis un bâtiment solide ou un véhicule adapté.',
                    'Ne vous abritez pas sous un arbre isolé, un abri ouvert ou une structure exposée.',
                  ],
          ),
          _LightningCard(
            icon: Icons.electrical_services_rounded,
            color: const Color(0xff6750a4),
            title: en ? 'While indoors' : 'À l’intérieur',
            lines: en
                ? const [
                    'Avoid plumbing and running water during the storm.',
                    'Avoid corded landline phones.',
                    'Stay away from windows and doors when severe wind or hail is present.',
                    'Unplug sensitive equipment before the storm when there is time to do so safely.',
                  ]
                : const [
                    'Évitez la plomberie et l’eau courante pendant l’orage.',
                    'Évitez les téléphones fixes filaires.',
                    'Éloignez-vous des fenêtres et portes en cas de vent violent ou de grêle.',
                    'Débranchez les équipements sensibles avant l’orage s’il est encore possible de le faire sans danger.',
                  ],
          ),
          _LightningCard(
            icon: Icons.directions_car_rounded,
            color: const Color(0xff237fc7),
            title: en ? 'If using a vehicle for shelter' : 'Si le véhicule sert d’abri',
            lines: en
                ? const [
                    'Use a hard-topped vehicle with the windows closed.',
                    'Avoid touching metal parts connected to the vehicle exterior while lightning is active.',
                    'Do not stop where flooding, falling trees or traffic create a greater danger.',
                  ]
                : const [
                    'Utilisez un véhicule fermé à toit rigide, fenêtres fermées.',
                    'Évitez de toucher les parties métalliques reliées à l’extérieur du véhicule pendant l’activité électrique.',
                    'Ne vous arrêtez pas là où inondation, chute d’arbres ou circulation créent un danger supérieur.',
                  ],
          ),
          _LightningCard(
            icon: Icons.flood_rounded,
            color: const Color(0xffd16a32),
            title: en ? 'Watch for secondary hazards' : 'Surveiller les dangers associés',
            lines: en
                ? const [
                    'Thunderstorms can bring flash flooding, hail, strong wind and falling trees.',
                    'Never drive into a flooded road when the depth or current is uncertain.',
                    'After the storm, avoid fallen power lines and report them to the responsible service.',
                  ]
                : const [
                    'Les orages peuvent provoquer crues soudaines, grêle, vents violents et chutes d’arbres.',
                    'Ne vous engagez jamais sur une route inondée si la profondeur ou le courant sont incertains.',
                    'Après l’orage, évitez les lignes électriques tombées et signalez-les au service compétent.',
                  ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openSource,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(en ? 'Source: Ready.gov thunderstorm guidance' : 'Source : Ready.gov — orage et foudre'),
          ),
        ],
      ),
    );
  }
}

class _LightningHero extends StatelessWidget {
  const _LightningHero({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffeceaf8), Color(0xfffff3df)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xff6750a4),
              child: Icon(Icons.thunderstorm_rounded, color: Colors.white),
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

class _LightningCard extends StatelessWidget {
  const _LightningCard({
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
