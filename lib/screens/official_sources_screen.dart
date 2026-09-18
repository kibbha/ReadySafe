import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_scope.dart';

class OfficialSourcesScreen extends StatelessWidget {
  const OfficialSourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final country = AppScope.of(context).activeCountry;
    final code = country?.isoCode ?? 'CH';
    final sources = _sourcesFor(code);

    return Scaffold(
      appBar: AppBar(title: const Text('Alertes & sources officielles')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffffeee8), Color(0xfffff7df)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xffd92d36),
                  child: Icon(Icons.campaign_rounded, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vérifier avant d’agir',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ReadySafe regroupe des accès rapides, mais une alerte réelle doit toujours être lue depuis sa source officielle. Les instructions locales priment sur les conseils généraux.',
                        style: TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Sources recommandées — $code',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...sources.map((source) => _SourceCard(source: source)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xffeaf6f4),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: Color(0xff087f83)),
                    SizedBox(width: 8),
                    Text(
                      'Ne dépendez pas d’un seul canal',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                Text(
                  'Gardez les alertes système du téléphone activées, une radio utilisable sans Internet et au moins une source officielle supplémentaire lorsque votre pays en propose une.',
                  style: TextStyle(height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xfffff4c7),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.security_rounded, color: Color(0xff9a6a00)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ReadySafe n’intercepte pas et ne remplace pas les alertes gouvernementales. Cette page ouvre les canaux officiels disponibles pour vérification.',
                    style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<_OfficialSource> _sourcesFor(String code) {
    switch (code) {
      case 'CH':
        return const [
          _OfficialSource(
            'Alertswiss',
            'Alertes, informations et plan d’urgence de la Confédération.',
            'https://www.alert.swiss/',
            Icons.warning_amber_rounded,
          ),
          _OfficialSource(
            'MétéoSuisse',
            'Dangers météorologiques et informations sur les phénomènes sévères.',
            'https://www.meteoswiss.admin.ch/weather/hazards.html',
            Icons.thunderstorm_rounded,
          ),
          _OfficialSource(
            '112 Europe',
            'Informations générales sur le numéro d’urgence européen 112.',
            'https://digital-strategy.ec.europa.eu/en/policies/112',
            Icons.phone_in_talk_rounded,
          ),
        ];
      case 'FR':
        return const [
          _OfficialSource(
            'FR-Alert',
            'Alertes et informations des autorités françaises.',
            'https://fr-alert.gouv.fr/',
            Icons.warning_amber_rounded,
          ),
          _OfficialSource(
            'Vigilance Météo-France',
            'Carte officielle des dangers météorologiques.',
            'https://vigilance.meteofrance.fr/fr',
            Icons.thunderstorm_rounded,
          ),
          _OfficialSource(
            '112 Europe',
            'Informations générales sur le numéro d’urgence européen 112.',
            'https://digital-strategy.ec.europa.eu/en/policies/112',
            Icons.phone_in_talk_rounded,
          ),
        ];
      case 'DE':
        return const [
          _OfficialSource(
            'Warn-App NINA / BBK',
            'Avertissements de protection civile, météo et inondations.',
            'https://www.bbk.bund.de/DE/Warnung-Vorsorge/Warn-App-NINA/warn-app-nina_node.html',
            Icons.warning_amber_rounded,
          ),
          _OfficialSource(
            '112 Europe',
            'Informations générales sur le numéro d’urgence européen 112.',
            'https://digital-strategy.ec.europa.eu/en/policies/112',
            Icons.phone_in_talk_rounded,
          ),
        ];
      case 'BE':
        return const [
          _OfficialSource(
            '112 Belgique',
            'Numéros, App 112 BE et informations officielles.',
            'https://112.be/fr',
            Icons.phone_in_talk_rounded,
          ),
          _OfficialSource(
            'App 112 BE',
            'Accès ambulance, pompiers et police avec fonctions adaptées.',
            'https://112.be/fr/application-mobile',
            Icons.smartphone_rounded,
          ),
        ];
      case 'IT':
        return const [
          _OfficialSource(
            'Protezione Civile',
            'Bulletins et informations nationales de protection civile.',
            'https://www.protezionecivile.gov.it/en/',
            Icons.shield_outlined,
          ),
          _OfficialSource(
            '112 Europe',
            'Informations générales sur le numéro d’urgence européen 112.',
            'https://digital-strategy.ec.europa.eu/en/policies/112',
            Icons.phone_in_talk_rounded,
          ),
        ];
      case 'GB':
        return const [
          _OfficialSource(
            'UK Emergency Alerts',
            'Alertes gouvernementales pour les urgences menaçant la vie.',
            'https://www.gov.uk/alerts',
            Icons.warning_amber_rounded,
          ),
          _OfficialSource(
            '999 / 112',
            'Informations officielles sur les numéros d’urgence britanniques.',
            'https://www.gov.uk/guidance/999-and-112-the-uks-national-emergency-numbers',
            Icons.phone_in_talk_rounded,
          ),
        ];
      default:
        return const [
          _OfficialSource(
            '112 Europe',
            'Informations générales sur le numéro d’urgence européen 112.',
            'https://digital-strategy.ec.europa.eu/en/policies/112',
            Icons.phone_in_talk_rounded,
          ),
        ];
    }
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});
  final _OfficialSource source;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(source.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir cette source.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          minTileHeight: 76,
          leading: CircleAvatar(
            backgroundColor: const Color(0xffe7f3f1),
            child: Icon(source.icon, color: const Color(0xff087f83)),
          ),
          title: Text(source.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(source.subtitle),
          trailing: const Icon(Icons.open_in_new_rounded),
          onTap: () => _open(context),
        ),
      );
}

class _OfficialSource {
  const _OfficialSource(this.title, this.subtitle, this.url, this.icon);
  final String title;
  final String subtitle;
  final String url;
  final IconData icon;
}
