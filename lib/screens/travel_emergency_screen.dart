import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import 'emergency_screen.dart';
import 'official_sources_screen.dart';
import 'secure_vault_screen.dart';
import 'special_kits_screen.dart';

class TravelEmergencyScreen extends StatelessWidget {
  const TravelEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final activeCountry = AppScope.of(context).activeCountry;
    final countryLabel = activeCountry?.isoCode ?? '—';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Emergency while travelling' : 'Urgence en voyage'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffeceaf8), Color(0xffe4f3f0)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xff6750a4),
                  child: Icon(Icons.luggage_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en
                            ? 'Use the active country, not your home-country habits'
                            : 'Utiliser les informations du pays actif, pas les habitudes du pays de résidence',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        en
                            ? 'ReadySafe currently treats $countryLabel as the active country for emergency numbers and official sources.'
                            : 'ReadySafe utilise actuellement $countryLabel comme pays actif pour les numéros d’urgence et les sources officielles.',
                        style: const TextStyle(
                          color: Color(0xff65747a),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _TravelCard(
            icon: Icons.medical_services_outlined,
            color: const Color(0xffd92d36),
            title: en ? 'Medical emergency' : 'Urgence médicale',
            lines: en
                ? const [
                    'Use the local emergency number for the country you are in.',
                    'Keep travel-insurance and assistance references accessible offline.',
                    'Have a list of medicines, allergies and essential treatment information available when relevant.',
                  ]
                : const [
                    'Utilisez le numéro d’urgence local du pays où vous vous trouvez.',
                    'Gardez les références d’assurance et d’assistance voyage accessibles hors ligne.',
                    'Gardez une liste des traitements, allergies et informations médicales indispensables lorsque cela est pertinent.',
                  ],
          ),
          _TravelCard(
            icon: Icons.badge_outlined,
            color: const Color(0xff6750a4),
            title: en ? 'Passport or identity document lost' : 'Passeport ou pièce d’identité perdu',
            lines: en
                ? const [
                    'Keep a separate copy or reference of identity documents.',
                    'Follow the local procedure for reporting theft or loss when required.',
                    'Contact the consular service of your nationality for replacement or emergency travel-document instructions.',
                    'Do not store the only copy of identity information in the same bag as the original.',
                  ]
                : const [
                    'Conservez une copie ou les références des documents d’identité séparément.',
                    'Suivez la procédure locale de déclaration de vol ou de perte lorsqu’elle est requise.',
                    'Contactez le service consulaire de votre nationalité pour les démarches de remplacement ou document de voyage d’urgence.',
                    'Ne conservez pas l’unique copie des informations d’identité dans le même sac que l’original.',
                  ],
          ),
          _TravelCard(
            icon: Icons.campaign_outlined,
            color: const Color(0xffb7833f),
            title: en ? 'Disaster or major disruption' : 'Catastrophe ou perturbation majeure',
            lines: en
                ? const [
                    'Follow local authorities and official warning channels in the country you are visiting.',
                    'Use text messages when networks are congested and keep an out-of-area contact informed.',
                    'Know at least one place where you can shelter and one route away from the affected area.',
                    'Keep transport, accommodation and insurance references available offline.',
                  ]
                : const [
                    'Suivez les autorités locales et les canaux d’alerte officiels du pays visité.',
                    'Privilégiez les SMS lorsque les réseaux sont saturés et informez un contact extérieur.',
                    'Repérez au moins un lieu où vous mettre à l’abri et un itinéraire pour quitter la zone touchée.',
                    'Conservez hors ligne les références de transport, hébergement et assurance.',
                  ],
          ),
          _TravelCard(
            icon: Icons.account_balance_outlined,
            color: const Color(0xff087f83),
            title: en ? 'Consular assistance' : 'Assistance consulaire',
            lines: en
                ? const [
                    'Know how to contact the embassy or consulate responsible for your nationality and current location.',
                    'Consular services may help with travel documents and provide information or contacts, but their powers vary by country and situation.',
                    'Keep the consular reference and travel-insurance assistance number in the secure vault.',
                  ]
                : const [
                    'Sachez comment contacter l’ambassade ou le consulat compétent pour votre nationalité et le lieu où vous vous trouvez.',
                    'Les services consulaires peuvent aider pour les documents de voyage et fournir des informations ou contacts, mais leurs pouvoirs varient selon le pays et la situation.',
                    'Conservez la référence consulaire et le numéro d’assistance voyage dans le coffre sécurisé.',
                  ],
          ),
          const SizedBox(height: 8),
          Text(
            en ? 'Useful ReadySafe shortcuts' : 'Raccourcis ReadySafe utiles',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          _Shortcut(
            icon: Icons.phone_in_talk_rounded,
            title: en ? 'Emergency numbers for $countryLabel' : 'Numéros d’urgence — $countryLabel',
            page: const EmergencyScreen(),
          ),
          _Shortcut(
            icon: Icons.campaign_rounded,
            title: en ? 'Official alerts & sources' : 'Alertes & sources officielles',
            page: const OfficialSourcesScreen(),
          ),
          _Shortcut(
            icon: Icons.lock_rounded,
            title: en ? 'Secure travel references' : 'Références voyage sécurisées',
            page: const SecureVaultScreen(),
          ),
          _Shortcut(
            icon: Icons.inventory_2_rounded,
            title: en ? 'Travel kit' : 'Kit voyage',
            page: const SpecialKitsScreen(),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xfffff4c7),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.public_rounded, color: Color(0xff9a6a00)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    en
                        ? 'Before travelling, switch ReadySafe travel mode to the destination country and verify the emergency numbers and official sources shown by the app.'
                        : 'Avant un voyage, activez le mode voyage ReadySafe sur le pays de destination et vérifiez les numéros d’urgence ainsi que les sources officielles affichées par l’application.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
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

class _TravelCard extends StatelessWidget {
  const _TravelCard({
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
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
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: color,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          line,
                          style: const TextStyle(height: 1.33),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.page,
  });

  final IconData icon;
  final String title;
  final Widget page;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xffe4f2f0),
            child: Icon(icon, color: const Color(0xff087f83)),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          ),
        ),
      );
}
