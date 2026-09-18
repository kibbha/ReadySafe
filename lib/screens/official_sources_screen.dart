import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_scope.dart';

class OfficialSourcesScreen extends StatelessWidget {
  const OfficialSourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final country = AppScope.of(context).activeCountry;
    final code = country?.isoCode ?? '—';
    final curated = country == null
        ? const <_OfficialSource>[]
        : _sourcesFor(country.isoCode);
    final sources = curated.isNotEmpty
        ? curated
        : _fallbackSources(country?.sources ?? const <Uri>[]);

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(
          en
              ? 'Official alerts & sources'
              : 'Alertes & sources officielles',
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xffffeee8),
                      Color(0xfffff7df),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xffd92d36),
                      child: Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            en
                                ? 'Verify before acting'
                                : 'Vérifier avant d’agir',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            en
                                ? 'ReadySafe provides quick access, but a real warning should always be read from its official source. Local instructions take priority over general guidance.'
                                : 'ReadySafe regroupe des accès rapides, mais une alerte réelle doit toujours être lue depuis sa source officielle. Les instructions locales priment sur les conseils généraux.',
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
              Text(
                en
                    ? 'Recommended sources — $code'
                    : 'Sources recommandées — $code',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              if (sources.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff4c7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xffffdf75),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xff9a6a00),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          en
                              ? 'No country-specific official warning source has been verified and bundled for this profile yet. ReadySafe therefore does not invent or redirect to an unofficial substitute.'
                              : 'Aucune source officielle d’alerte spécifique à ce profil pays n’a encore été vérifiée et intégrée. ReadySafe n’invente donc pas de lien de remplacement non officiel.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...sources.map(
                  (source) => _SourceCard(
                    source: source,
                    en: en,
                  ),
                ),
              const SizedBox(height: 14),
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
                        const Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xff087f83),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            en
                                ? 'Do not depend on a single channel'
                                : 'Ne dépendez pas d’un seul canal',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      en
                          ? 'Keep government alert functions on the phone enabled, maintain a radio that works without Internet and keep at least one additional official source when your country provides one.'
                          : 'Gardez les alertes système du téléphone activées, une radio utilisable sans Internet et au moins une source officielle supplémentaire lorsque votre pays en propose une.',
                      style: const TextStyle(height: 1.35),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      color: Color(0xff9a6a00),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        en
                            ? 'ReadySafe does not intercept or replace government warning systems. This page opens available official channels so you can verify current information.'
                            : 'ReadySafe n’intercepte pas et ne remplace pas les alertes gouvernementales. Cette page ouvre les canaux officiels disponibles pour vérification.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            'Federal alerts, emergency information and preparedness planning.',
            'https://www.alert.swiss/',
            Icons.warning_amber_rounded,
          ),
          _OfficialSource(
            'Dangers naturels Suisse',
            'Portail fédéral des avertissements : météo, crues, incendies, avalanches et séismes.',
            'Federal natural-hazard warnings for weather, floods, wildfire, avalanche and earthquakes.',
            'https://www.naturgefahren.ch/',
            Icons.thunderstorm_rounded,
          ),
          _OfficialSource(
            'MétéoSuisse',
            'Informations officielles sur les avertissements météorologiques.',
            'Official information about Swiss severe-weather warnings.',
            'https://www.meteoswiss.admin.ch/weather/hazards/how-severe-weather-warnings-are-prepared.html',
            Icons.cloud_outlined,
          ),
          _OfficialSource(
            'SLF — Bulletin avalanche',
            'Bulletin et informations officielles du WSL Institut pour l’étude de la neige et des avalanches.',
            'Official avalanche bulletin and snow-condition information from the WSL Institute for Snow and Avalanche Research.',
            'https://www.slf.ch/fr/bulletin-davalanches-et-situation-nivologique/',
            Icons.landscape_outlined,
          ),
          _OfficialSource(
            '112 Europe',
            'Informations générales sur le numéro d’urgence européen 112.',
            'Official European information about the 112 emergency number.',
            'https://digital-strategy.ec.europa.eu/en/policies/112',
            Icons.phone_in_talk_rounded,
          ),
        ];
      case 'FR':
        return const [
          _OfficialSource(
            'FR-Alert',
            'Alertes et informations des autorités françaises.',
            'Official French public-warning information.',
            'https://fr-alert.gouv.fr/',
            Icons.warning_amber_rounded,
          ),
          _OfficialSource(
            'Vigilance Météo-France',
            'Carte officielle des dangers météorologiques.',
            'Official French weather-hazard vigilance map.',
            'https://vigilance.meteofrance.fr/fr',
            Icons.thunderstorm_rounded,
          ),
          _OfficialSource(
            '112 Europe',
            'Informations générales sur le numéro d’urgence européen 112.',
            'Official European information about the 112 emergency number.',
            'https://digital-strategy.ec.europa.eu/en/policies/112',
            Icons.phone_in_talk_rounded,
          ),
        ];
      case 'DE':
        return const [
          _OfficialSource(
            'Warn-App NINA / BBK',
            'Avertissements de protection civile, météo et inondations.',
            'Civil-protection, severe-weather and flood warnings from Germany’s BBK.',
            'https://www.bbk.bund.de/DE/Warnung-Vorsorge/Warn-App-NINA/warn-app-nina_node.html',
            Icons.warning_amber_rounded,
          ),
          _OfficialSource(
            '112 Europe',
            'Informations générales sur le numéro d’urgence européen 112.',
            'Official European information about the 112 emergency number.',
            'https://digital-strategy.ec.europa.eu/en/policies/112',
            Icons.phone_in_talk_rounded,
          ),
        ];
      case 'BE':
        return const [
          _OfficialSource(
            '112 Belgique',
            'Numéros, App 112 BE et informations officielles.',
            'Official Belgian emergency numbers and 112 BE information.',
            'https://112.be/fr',
            Icons.phone_in_talk_rounded,
          ),
          _OfficialSource(
            'App 112 BE',
            'Accès ambulance, pompiers et police avec fonctions adaptées.',
            'Official 112 BE mobile-app information for ambulance, fire and police access.',
            'https://112.be/fr/application-mobile',
            Icons.smartphone_rounded,
          ),
        ];
      case 'IT':
        return const [
          _OfficialSource(
            'Protezione Civile',
            'Bulletins et informations nationales de protection civile.',
            'National civil-protection bulletins and emergency information.',
            'https://www.protezionecivile.gov.it/en/',
            Icons.shield_outlined,
          ),
          _OfficialSource(
            '112 Europe',
            'Informations générales sur le numéro d’urgence européen 112.',
            'Official European information about the 112 emergency number.',
            'https://digital-strategy.ec.europa.eu/en/policies/112',
            Icons.phone_in_talk_rounded,
          ),
        ];
      case 'GB':
        return const [
          _OfficialSource(
            'UK Emergency Alerts',
            'Alertes gouvernementales pour les urgences menaçant la vie.',
            'UK government emergency alerts for life-threatening incidents.',
            'https://www.gov.uk/alerts',
            Icons.warning_amber_rounded,
          ),
          _OfficialSource(
            '999 / 112',
            'Informations officielles sur les numéros d’urgence britanniques.',
            'Official UK information about the 999 and 112 emergency numbers.',
            'https://www.gov.uk/guidance/999-and-112-the-uks-national-emergency-numbers',
            Icons.phone_in_talk_rounded,
          ),
        ];
      default:
        return const [];
    }
  }

  static List<_OfficialSource> _fallbackSources(List<Uri> uris) {
    return [
      for (final uri in uris)
        _OfficialSource(
          _sourceTitle(uri),
          'Référence officielle vérifiée pour ce profil pays.',
          'Verified official reference for this country profile.',
          uri.toString(),
          uri.host.contains('europa.eu')
              ? Icons.phone_in_talk_rounded
              : Icons.verified_user_outlined,
        ),
    ];
  }

  static String _sourceTitle(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host.contains('europa.eu')) return '112 Europe';
    if (host.contains('bakom.admin.ch')) return 'OFCOM / BAKOM';
    if (host.contains('rega.ch')) return 'Rega';
    if (host.contains('service-public.fr')) return 'Service-Public.fr';
    if (host.contains('112.be')) return '112 Belgique';
    if (host.contains('bbk.bund.de')) return 'BBK';
    if (host.contains('interno.gov.it')) return 'Ministero dell’Interno';
    if (host.contains('dsb.no')) return 'DSB Norge';
    if (host.contains('politiet.no')) return 'Politiet Norge';
    if (host.contains('helsenorge.no')) return 'Helsenorge';
    if (host == '112.is' || host.endsWith('.112.is')) return '112 Iceland';
    if (host.contains('112.gov.tr')) return '112 Türkiye';
    if (host.contains('llv.li')) return 'Liechtensteinische Landesverwaltung';
    if (host.contains('112.gov.ge')) return '112 Georgia';
    if (host.contains('gov.md')) return 'Government of Moldova';
    if (host.contains('akmc.gov.al')) return 'AKMC Albania';
    if (host.contains('cuk.gov.mk')) return 'Crisis Management Center — North Macedonia';
    if (host.contains('gov.uk')) return 'GOV.UK';
    return uri.host.replaceFirst('www.', '');
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.source,
    required this.en,
  });

  final _OfficialSource source;
  final bool en;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(source.url);

    if (!await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        ) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            en
                ? 'Unable to open this official source.'
                : 'Impossible d’ouvrir cette source.',
          ),
        ),
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
            child: Icon(
              source.icon,
              color: const Color(0xff087f83),
            ),
          ),
          title: Text(
            source.title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            en ? source.subtitleEn : source.subtitleFr,
          ),
          trailing: const Icon(Icons.open_in_new_rounded),
          onTap: () => _open(context),
        ),
      );
}

class _OfficialSource {
  const _OfficialSource(
    this.title,
    this.subtitleFr,
    this.subtitleEn,
    this.url,
    this.icon,
  );

  final String title;
  final String subtitleFr;
  final String subtitleEn;
  final String url;
  final IconData icon;
}
