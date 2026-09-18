import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_scope.dart';

class AvalancheSafetyScreen extends StatelessWidget {
  const AvalancheSafetyScreen({super.key});

  Future<void> _openSource() async {
    final uri = Uri.parse('https://www.naturgefahren.ch/gefahrenstufen/lawinen/verhalten.html');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final code = AppScope.of(context).activeCountry?.isoCode ?? '';
    final swiss = code == 'CH';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Avalanche safety' : 'Sécurité avalanche'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffedf5fb), Color(0xfffff4e8)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xff237fc7),
                  child: Icon(Icons.landscape_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en
                            ? 'Follow the official avalanche bulletin before entering exposed terrain'
                            : 'Consulter le bulletin avalanche officiel avant tout terrain exposé',
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        en
                            ? 'Avalanche risk changes with slope, snowpack, wind and temperature. ReadySafe provides general emergency guidance only.'
                            : 'Le risque d’avalanche varie avec la pente, le manteau neigeux, le vent et la température. ReadySafe fournit uniquement un rappel général d’urgence.',
                        style: const TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _AvalancheCard(
            icon: Icons.hiking_rounded,
            color: const Color(0xff087f83),
            title: en ? 'Before heading out' : 'Avant de partir',
            lines: en
                ? const [
                    'Check the current official avalanche bulletin and local closures.',
                    'Choose a route suited to the danger level, terrain and group experience.',
                    'Carry appropriate rescue equipment when travelling in avalanche terrain and know how to use it.',
                    'Tell someone your route and expected return time.',
                  ]
                : const [
                    'Consultez le bulletin avalanche officiel en vigueur et les fermetures locales.',
                    'Choisissez un itinéraire adapté au niveau de danger, au terrain et à l’expérience du groupe.',
                    'Emportez le matériel de secours adapté au terrain avalancheux et sachez l’utiliser.',
                    'Communiquez l’itinéraire prévu et l’heure de retour à un proche.',
                  ],
          ),
          _AvalancheCard(
            icon: Icons.snowboarding_rounded,
            color: const Color(0xffb7833f),
            title: en ? 'If caught in an avalanche' : 'Si vous êtes emporté',
            lines: en
                ? const [
                    'Release ski poles if possible and deploy an avalanche airbag if you have one.',
                    'Try to move toward the side of the flow if escape is possible.',
                    'If escape is impossible, protect your face and airway with your hands.',
                    'Once the snow stops, conserve energy and try to create breathing space if possible.',
                  ]
                : const [
                    'Lâchez les bâtons si possible et déclenchez l’airbag avalanche si vous en disposez.',
                    'Essayez de rejoindre le bord de l’écoulement si une fuite est possible.',
                    'Si vous ne pouvez pas sortir de la coulée, protégez le visage et les voies respiratoires avec les mains.',
                    'Lorsque la neige s’arrête, économisez votre énergie et essayez de préserver un espace respiratoire si possible.',
                  ],
          ),
          _AvalancheCard(
            icon: Icons.visibility_rounded,
            color: const Color(0xff6750a4),
            title: en ? 'If someone is buried' : 'Si une personne est ensevelie',
            lines: en
                ? const [
                    'Watch the avalanche and remember the last-seen point.',
                    'Protect yourself from secondary avalanches before starting rescue.',
                    'Alert emergency services as soon as possible.',
                    'Begin companion rescue immediately if you are trained and equipped to do so safely.',
                    'After excavation, start lifesaving first aid and protect the person from cold.',
                  ]
                : const [
                    'Observez la coulée et mémorisez le dernier point où la personne a été vue.',
                    'Protégez-vous du risque de sur-avalanche avant de commencer le secours.',
                    'Alertez les secours dès que possible.',
                    'Commencez immédiatement le secours par les compagnons si vous êtes formé, équipé et pouvez le faire sans vous exposer.',
                    'Après dégagement, commencez les gestes vitaux nécessaires et protégez la personne du froid.',
                  ],
          ),
          if (swiss)
            Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xffffeeee),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.phone_in_talk_rounded, color: Color(0xffd92d36)),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      en
                          ? 'Switzerland: Rega 1414 · ambulance 144 · international emergency number 112.'
                          : 'Suisse : Rega 1414 · ambulance 144 · numéro d’urgence international 112.',
                      style: const TextStyle(fontWeight: FontWeight.w900, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          _AvalancheCard(
            icon: Icons.home_work_outlined,
            color: const Color(0xff147343),
            title: en ? 'Roads and settlements' : 'Routes et zones habitées',
            lines: en
                ? const [
                    'Respect closures and instructions from local authorities.',
                    'If authorities instruct residents to stay inside, remain sheltered and monitor official information.',
                    'Do not enter damaged structures after an avalanche until they are considered safe.',
                  ]
                : const [
                    'Respectez les fermetures et les instructions des autorités locales.',
                    'Si les autorités demandent de rester à l’intérieur, restez à l’abri et suivez les informations officielles.',
                    'N’entrez pas dans un bâtiment endommagé après une avalanche avant qu’il soit considéré comme sûr.',
                  ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openSource,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(
              en
                  ? 'Source: Swiss Natural Hazards Portal'
                  : 'Source : Portail des dangers naturels de la Confédération',
            ),
          ),
        ],
      ),
    );
  }
}

class _AvalancheCard extends StatelessWidget {
  const _AvalancheCard({
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
