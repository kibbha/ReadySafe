import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SanitationHygieneScreen extends StatelessWidget {
  const SanitationHygieneScreen({super.key});

  Future<void> _openSource() async {
    final uri = Uri.parse(
      'https://www.cdc.gov/water-emergency/safety/guidelines-for-personal-hygiene-during-an-emergency.html',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    final sections = <_SanitationSection>[
      _SanitationSection(
        en ? 'Hands first' : 'Les mains d’abord',
        Icons.clean_hands_rounded,
        const Color(0xff087f83),
        [
          en
              ? 'Wash hands with soap and safe water for at least 20 seconds whenever possible.'
              : 'Lavez les mains avec du savon et une eau sûre pendant au moins 20 secondes chaque fois que possible.',
          en
              ? 'If soap and water are unavailable, use an alcohol-based hand sanitizer with at least 60% alcohol when appropriate.'
              : 'Si savon et eau sont indisponibles, utilisez un gel hydroalcoolique contenant au moins 60 % d’alcool lorsque cela convient.',
          en
              ? 'Follow local water advisories because handwashing instructions can change depending on the type of contamination.'
              : 'Suivez les avis locaux sur l’eau car les consignes de lavage des mains peuvent changer selon le type de contamination.',
        ],
      ),
      _SanitationSection(
        en ? 'Keep clean and dirty zones separate' : 'Séparer zones propres et zones sales',
        Icons.rule_rounded,
        const Color(0xff6750a4),
        [
          en
              ? 'Keep food preparation, drinking-water containers and clean utensils away from waste and dirty equipment.'
              : 'Éloignez préparation des aliments, récipients d’eau potable et ustensiles propres des déchets et du matériel souillé.',
          en
              ? 'Use separate bags or containers for contaminated clothing, waste and damaged items.'
              : 'Utilisez des sacs ou contenants séparés pour vêtements contaminés, déchets et objets endommagés.',
          en
              ? 'Clean surfaces only with products and water that are safe for the situation.'
              : 'Nettoyez les surfaces uniquement avec des produits et une eau adaptés à la situation.',
        ],
      ),
      _SanitationSection(
        en ? 'Waste and toilets' : 'Déchets et toilettes',
        Icons.delete_outline_rounded,
        const Color(0xffb7833f),
        [
          en
              ? 'Follow local instructions for toilets, wastewater and rubbish when services are disrupted.'
              : 'Suivez les consignes locales pour les toilettes, eaux usées et déchets lorsque les services sont perturbés.',
          en
              ? 'Keep human and pet waste away from drinking-water sources and food areas.'
              : 'Éloignez les déchets humains et animaux des sources d’eau potable et des zones alimentaires.',
          en
              ? 'Do not improvise disposal methods that could contaminate soil, drains or water sources.'
              : 'N’improvisez pas de méthode d’évacuation susceptible de contaminer le sol, les canalisations ou les sources d’eau.',
        ],
      ),
      _SanitationSection(
        en ? 'Floodwater and dirty water' : 'Eaux de crue et eaux souillées',
        Icons.flood_rounded,
        const Color(0xff237fc7),
        [
          en
              ? 'Avoid contact with floodwater whenever possible because it may contain sewage, chemicals or sharp objects.'
              : 'Évitez autant que possible le contact avec les eaux de crue car elles peuvent contenir eaux usées, produits chimiques ou objets coupants.',
          en
              ? 'Cover open wounds before unavoidable contact and wash exposed skin afterwards with safe water.'
              : 'Couvrez les plaies avant tout contact inévitable et lavez ensuite la peau exposée avec une eau sûre.',
          en
              ? 'Do not use floodwater for washing dishes, brushing teeth, food preparation or drinking.'
              : 'N’utilisez pas l’eau de crue pour la vaisselle, le brossage des dents, la préparation des aliments ou la boisson.',
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Hygiene & sanitation' : 'Hygiène & assainissement'),
      ),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xff087f83),
                  child: Icon(Icons.sanitizer_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en
                            ? 'Prevent illness when normal services are disrupted'
                            : 'Éviter les maladies quand les services habituels sont perturbés',
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        en
                            ? 'Safe water, hand hygiene and clean separation become especially important after floods, outages and evacuations.'
                            : 'Eau sûre, hygiène des mains et séparation du propre et du sale deviennent essentielles après inondation, panne ou évacuation.',
                        style: const TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...sections.map((section) => _SectionCard(section: section)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xffffeeee),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.science_outlined, color: Color(0xffd92d36)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    en
                        ? 'Never mix bleach with ammonia, acids or other cleaners. Dangerous gases can be produced.'
                        : 'Ne mélangez jamais l’eau de Javel avec de l’ammoniaque, des acides ou d’autres produits ménagers. Des gaz dangereux peuvent se former.',
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
                  ? 'Source: CDC emergency hygiene guidance'
                  : 'Source : recommandations CDC sur l’hygiène en urgence',
            ),
          ),
        ],
      ),
    );
  }
}

class _SanitationSection {
  const _SanitationSection(this.title, this.icon, this.color, this.lines);
  final String title;
  final IconData icon;
  final Color color;
  final List<String> lines;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});
  final _SanitationSection section;

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
                    backgroundColor: section.color.withValues(alpha: .12),
                    child: Icon(section.icon, color: section.color),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      section.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final line in section.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 18, color: section.color),
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
