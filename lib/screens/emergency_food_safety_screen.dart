import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyFoodSafetyScreen extends StatelessWidget {
  const EmergencyFoodSafetyScreen({super.key});

  Future<void> _openSource() async {
    final uri = Uri.parse(
      'https://www.cdc.gov/food-safety/foods/keep-food-safe-after-emergency.html',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Food safety after an emergency' : 'Sécurité des aliments après une urgence'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xfffff3df), Color(0xffe8f4f2)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xffb7833f),
                  child: Icon(Icons.restaurant_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en ? 'When in doubt, throw it out' : 'En cas de doute, jetez',
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        en
                            ? 'Power outages, floods and contaminated water can make food unsafe even when it looks or smells normal.'
                            : 'Panne électrique, inondation ou eau contaminée peuvent rendre les aliments dangereux même s’ils semblent normaux.',
                        style: const TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FoodCard(
            icon: Icons.kitchen_rounded,
            color: const Color(0xff237fc7),
            title: en ? 'Refrigerator and freezer' : 'Réfrigérateur et congélateur',
            lines: en
                ? const [
                    'Keep doors closed as much as possible.',
                    'A closed refrigerator keeps food cold for about 4 hours.',
                    'A full closed freezer keeps food cold for about 48 hours; about 24 hours if half full.',
                    'Use appliance thermometers whenever possible.',
                  ]
                : const [
                    'Gardez les portes fermées autant que possible.',
                    'Un réfrigérateur fermé garde les aliments froids environ 4 heures.',
                    'Un congélateur plein et fermé tient environ 48 heures ; environ 24 heures s’il est à moitié plein.',
                    'Utilisez des thermomètres d’appareil lorsque possible.',
                  ],
          ),
          _FoodCard(
            icon: Icons.delete_forever_outlined,
            color: const Color(0xffd92d36),
            title: en ? 'Discard unsafe food' : 'Jeter les aliments à risque',
            lines: en
                ? const [
                    'Discard perishable refrigerated food after about 4 hours without power or another cold source.',
                    'Never taste food to decide whether it is safe.',
                    'Discard food with unusual smell, colour or texture, but remember unsafe food can also look normal.',
                  ]
                : const [
                    'Jetez les aliments périssables réfrigérés après environ 4 heures sans courant ni autre source de froid.',
                    'Ne goûtez jamais un aliment pour décider s’il est sûr.',
                    'Jetez tout aliment à l’odeur, couleur ou texture anormale, mais rappelez-vous qu’un aliment dangereux peut aussi sembler normal.',
                  ],
          ),
          _FoodCard(
            icon: Icons.flood_rounded,
            color: const Color(0xff087f83),
            title: en ? 'After flooding' : 'Après une inondation',
            lines: en
                ? const [
                    'Discard food that may have touched floodwater or stormwater.',
                    'Discard food in packages that are not waterproof.',
                    'Discard cardboard food and drink containers that contacted floodwater.',
                    'Follow official instructions before cleaning or saving any sealed commercial containers.',
                  ]
                : const [
                    'Jetez tout aliment ayant pu entrer en contact avec une eau de crue ou de ruissellement.',
                    'Jetez les aliments dans des emballages non étanches.',
                    'Jetez les cartons alimentaires ou de boisson ayant touché l’eau de crue.',
                    'Suivez les consignes officielles avant de nettoyer ou conserver des contenants commerciaux fermés.',
                  ],
          ),
          _FoodCard(
            icon: Icons.thermostat_rounded,
            color: const Color(0xff6750a4),
            title: en ? 'If frozen food thawed' : 'Si les aliments congelés ont décongelé',
            lines: en
                ? const [
                    'Food that still contains ice crystals or is at 4°C / 40°F or below may generally be refrozen or cooked.',
                    'Discard food that has been too warm for too long or whose safety cannot be established.',
                  ]
                : const [
                    'Un aliment contenant encore des cristaux de glace ou restant à 4 °C ou moins peut généralement être recongelé ou cuit.',
                    'Jetez les aliments restés trop chauds trop longtemps ou dont la sécurité ne peut pas être établie.',
                  ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xffffeeee),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xffd92d36)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    en
                        ? 'People who are pregnant, very young, older, immunocompromised or living with certain medical conditions can be at higher risk from foodborne illness.'
                        : 'Les personnes enceintes, très jeunes, âgées, immunodéprimées ou vivant avec certaines maladies peuvent être plus exposées aux complications d’une intoxication alimentaire.',
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
                  ? 'Source: CDC food safety after emergencies'
                  : 'Source : CDC — sécurité alimentaire après une urgence',
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({
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
