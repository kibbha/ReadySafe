import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TsunamiSafetyScreen extends StatelessWidget {
  const TsunamiSafetyScreen({super.key});

  Future<void> _openSource() async {
    final uri = Uri.parse(
      'https://www.ready.gov/sites/default/files/2024-08/ready-gov_tsunami_info-sheet.pdf',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(en ? 'Tsunami safety' : 'Sécurité tsunami')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          _Hero(
            icon: Icons.waves_rounded,
            title: en
                ? 'Move inland or to higher ground when warning signs appear'
                : 'S’éloigner du littoral ou gagner de la hauteur dès les signes d’alerte',
            body: en
                ? 'A tsunami can follow a strong or long earthquake, unusual sea behaviour or an official alert.'
                : 'Un tsunami peut suivre un séisme fort ou prolongé, un comportement inhabituel de la mer ou une alerte officielle.',
          ),
          const SizedBox(height: 14),
          _Card(
            icon: Icons.warning_amber_rounded,
            color: const Color(0xffd92d36),
            title: en ? 'Natural warning signs' : 'Signes naturels à reconnaître',
            lines: en
                ? const [
                    'A strong or long earthquake near the coast can be a natural tsunami warning.',
                    'A loud roar from the ocean or unusual sea behaviour, such as sudden draining or a rapid rise, can also be warning signs.',
                    'If natural warning signs occur, do not wait for a phone notification before moving to safety.',
                  ]
                : const [
                    'Un séisme fort ou prolongé près du littoral peut être un avertissement naturel de tsunami.',
                    'Un grondement inhabituel de l’océan ou un retrait brutal / une montée rapide de la mer peuvent aussi être des signes d’alerte.',
                    'Si ces signes naturels apparaissent, n’attendez pas une notification téléphonique avant de vous mettre en sécurité.',
                  ],
          ),
          _Card(
            icon: Icons.directions_run_rounded,
            color: const Color(0xff087f83),
            title: en ? 'Evacuate quickly' : 'Évacuer rapidement',
            lines: en
                ? const [
                    'After earthquake shaking stops, move inland or to higher ground using local tsunami evacuation routes when available.',
                    'Follow evacuation signs and local authorities.',
                    'Do not go to the shore to watch the waves.',
                    'If you are visiting a coastal area, learn the local tsunami zone and route before an emergency.',
                  ]
                : const [
                    'Une fois les secousses terminées, éloignez-vous du littoral ou gagnez de la hauteur en utilisant les itinéraires d’évacuation tsunami locaux lorsqu’ils existent.',
                    'Suivez la signalisation et les instructions des autorités.',
                    'N’allez pas sur le rivage pour observer les vagues.',
                    'En voyage sur une zone côtière, repérez avant l’urgence la zone à risque et les itinéraires locaux.',
                  ],
          ),
          _Card(
            icon: Icons.repeat_rounded,
            color: const Color(0xff237fc7),
            title: en ? 'Expect more than one wave' : 'S’attendre à plusieurs vagues',
            lines: en
                ? const [
                    'A tsunami is a series of waves, not a single wave.',
                    'Stay away from coastal and flooded areas until authorities say it is safe to return.',
                    'Avoid floodwater because it can hide debris, damaged roads and electrical hazards.',
                  ]
                : const [
                    'Un tsunami est une série de vagues, pas une seule vague.',
                    'Restez éloigné des zones côtières et inondées jusqu’à ce que les autorités déclarent le retour sûr.',
                    'Évitez les eaux de crue, qui peuvent cacher débris, routes endommagées et risques électriques.',
                  ],
          ),
          _Card(
            icon: Icons.family_restroom_rounded,
            color: const Color(0xff6750a4),
            title: en ? 'Household plan' : 'Plan du foyer',
            lines: en
                ? const [
                    'Choose a family meeting place outside the tsunami hazard zone.',
                    'Keep a small evacuation kit ready if you live in or visit a coastal hazard area.',
                    'Know how children, older adults, pets and people with mobility needs will evacuate.',
                  ]
                : const [
                    'Choisissez un point de rassemblement familial hors de la zone de danger tsunami.',
                    'Gardez un petit kit d’évacuation prêt si vous vivez ou séjournez dans une zone côtière exposée.',
                    'Prévoyez comment évacuer enfants, seniors, animaux et personnes avec besoins de mobilité.',
                  ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openSource,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(en ? 'Source: Ready.gov tsunami guidance' : 'Source : Ready.gov — tsunami'),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffe5f2fb), Color(0xffe4f3f0)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xff237fc7),
              child: Icon(icon, color: Colors.white),
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

class _Card extends StatelessWidget {
  const _Card({
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
