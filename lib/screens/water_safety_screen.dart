import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WaterSafetyScreen extends StatelessWidget {
  const WaterSafetyScreen({super.key});

  Future<void> _openSource() async {
    final uri = Uri.parse('https://www.cdc.gov/water-emergency/about/index.html');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Safe water in an emergency' : 'Eau sûre en situation d’urgence'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffe5f2fb), Color(0xffe8f4f2)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xff237fc7),
                  child: Icon(Icons.water_drop_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en ? 'When tap water may no longer be safe' : 'Quand l’eau du robinet peut ne plus être sûre',
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        en
                            ? 'Follow local water advisories first. Use bottled, boiled or properly treated water when authorities say tap water is unsafe.'
                            : 'Suivez d’abord les avis officiels sur l’eau. Utilisez de l’eau embouteillée, bouillie ou correctement traitée lorsque l’eau du réseau est déclarée incertaine.',
                        style: const TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MethodCard(
            number: 1,
            icon: Icons.local_drink_rounded,
            color: const Color(0xff237fc7),
            title: en ? 'Use a safe source first' : 'Privilégier une source sûre',
            body: en
                ? 'Commercially bottled water is the simplest option when available. Use safe water for drinking, cooking, brushing teeth and preparing infant formula.'
                : 'L’eau embouteillée du commerce est l’option la plus simple lorsqu’elle est disponible. Utilisez une eau sûre pour boire, cuisiner, se brosser les dents et préparer les biberons.',
          ),
          _MethodCard(
            number: 2,
            icon: Icons.soup_kitchen_rounded,
            color: const Color(0xffd16a32),
            title: en ? 'Boiling is the preferred germ-killing method' : 'Faire bouillir est la méthode de référence contre les germes',
            body: en
                ? 'If water is cloudy, let it settle or filter it through a clean cloth first. Bring clear water to a rolling boil for 1 minute; above about 2,000 m altitude, boil for 3 minutes. Let it cool in a clean covered container.'
                : 'Si l’eau est trouble, laissez-la décanter ou filtrez-la d’abord à travers un tissu propre. Portez l’eau claire à gros bouillons pendant 1 minute ; au-dessus d’environ 2 000 m d’altitude, faites bouillir 3 minutes. Laissez refroidir dans un récipient propre et fermé.',
          ),
          _MethodCard(
            number: 3,
            icon: Icons.science_outlined,
            color: const Color(0xff6750a4),
            title: en ? 'Chemical disinfection: follow the product label' : 'Désinfection chimique : suivre le produit',
            body: en
                ? 'Use a product intended for drinking-water disinfection and follow its label exactly. Concentrations and dosing differ. Chemical treatment may be less effective against some parasites.'
                : 'Utilisez un produit prévu pour la désinfection de l’eau potable et suivez exactement sa notice. Les concentrations et dosages varient. Le traitement chimique peut être moins efficace contre certains parasites.',
          ),
          _MethodCard(
            number: 4,
            icon: Icons.filter_alt_outlined,
            color: const Color(0xff147343),
            title: en ? 'A portable filter is not automatically enough' : 'Un filtre portable ne suffit pas toujours',
            body: en
                ? 'Many portable filters do not remove viruses and some do not remove bacteria. Follow the filter instructions and combine with an appropriate disinfection method when required.'
                : 'De nombreux filtres portables n’éliminent pas les virus et certains n’éliminent pas les bactéries. Suivez la notice du filtre et complétez par une désinfection adaptée lorsque nécessaire.',
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
                const Icon(Icons.dangerous_outlined, color: Color(0xffd92d36)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    en
                        ? 'Boiling, filtering or disinfecting cannot make water contaminated with fuel, toxic chemicals or radioactive material safe. Use another source and follow official instructions.'
                        : 'Faire bouillir, filtrer ou désinfecter ne rend pas potable une eau contaminée par du carburant, des produits toxiques ou des matières radioactives. Utilisez une autre source et suivez les consignes officielles.',
                    style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xffeaf6f4),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.clean_hands_rounded, color: Color(0xff087f83)),
                    const SizedBox(width: 8),
                    Text(
                      en ? 'Also use safe water for hygiene when required' : 'Utiliser aussi une eau sûre pour l’hygiène si nécessaire',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  en
                      ? 'During a water advisory, official guidance may apply to handwashing, dishes, food preparation, ice, pets and bathing. Follow the exact wording of the local advisory.'
                      : 'Pendant un avis sur la qualité de l’eau, les consignes peuvent aussi concerner le lavage des mains, la vaisselle, la préparation des aliments, les glaçons, les animaux ou la toilette. Suivez précisément l’avis local.',
                  style: const TextStyle(height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openSource,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(en ? 'Source: CDC emergency water guidance' : 'Source : recommandations CDC sur l’eau en urgence'),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.number,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final int number;
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: .12),
                    child: Icon(icon, color: color),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: color,
                      child: Text(
                        '$number',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(body, style: const TextStyle(height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
