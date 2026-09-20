import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../core/search_text.dart';
import '../data/first_aid_repository.dart';
import '../models/first_aid_guide.dart';
import '../services/first_aid_pdf_service.dart';
import 'emergency_screen.dart';

const _essentialIds = <String>[
  'unconscious',
  'cpr_adult',
  'aed',
  'bleeding',
  'wounds',
  'waiting_positions',
  'choking_adult',
  'choking_child',
  'choking_infant',
  'burn',
  'stroke',
  'chest_pain',
  'anaphylaxis',
  'seizure',
  'drowning',
  'hypothermia',
  'heatstroke',
];

const _referencePosterAssets = <String, String>{
  'cpr_adult': 'assets/illustrations/posters/cpr_adult.png',
  'choking_adult': 'assets/illustrations/posters/choking_adult.png',
  'unconscious': 'assets/illustrations/posters/unconscious.png',
  'bleeding': 'assets/illustrations/posters/bleeding.png',
  'aed': 'assets/illustrations/posters/aed.png',
  'cpr_child': 'assets/illustrations/posters/cpr_child.png',
  'cpr_infant': 'assets/illustrations/posters/cpr_infant.png',
  'choking_infant': 'assets/illustrations/posters/choking_infant.png',
  'drowning': 'assets/illustrations/posters/drowning.png',
  'anaphylaxis': 'assets/illustrations/posters/anaphylaxis.png',
};

String _aidText(BuildContext context, String key) {
  final t = AppLocalizations.of(context);
  final en = Localizations.localeOf(context).languageCode == 'en';

  const fr = <String, String>{
    'first_aid_search': 'Rechercher une fiche ou un symptôme',
    'first_aid_empty': 'Aucune fiche correspondante',
    'first_aid_all': 'Toutes',
    'first_aid_adult': 'Adulte',
    'first_aid_child': 'Enfant',
    'first_aid_infant': 'Nourrisson',
    'first_aid_header': 'Fiches Premiers Secours',
    'first_aid_header_body':
        '10 fiches essentielles, visuelles et disponibles hors ligne',
  };

  const english = <String, String>{
    'first_aid_search': 'Search a guide or symptom',
    'first_aid_empty': 'No matching guide',
    'first_aid_all': 'All',
    'first_aid_adult': 'Adult',
    'first_aid_child': 'Child',
    'first_aid_infant': 'Infant',
    'first_aid_header': 'First Aid Guides',
    'first_aid_header_body':
        '10 essential visual guides available offline',
  };

  return (en ? english : fr)[key] ?? t.get(key);
}
bool _posterCritical(String id) => const {
      'cpr_adult',
      'choking_adult',
      'bleeding',
      'choking_infant',
      'anaphylaxis',
      'wounds',
    }.contains(id);

String? _emergencyNumber(BuildContext context) {
  return AppScope.of(context).activeCountry?.preferredEmergencyNumber;
}

String _posterTag(String id, bool en) {
  const fr = <String, String>{
    'cpr_adult': 'AGIR VITE PEUT SAUVER UNE VIE',
    'choking_adult': 'AIDER UNE PERSONNE QUI S’ÉTOUFFE',
    'unconscious': 'POSITION LATÉRALE DE SÉCURITÉ',
    'bleeding': 'ARRÊTER LE SAIGNEMENT',
    'aed': 'SIMPLE ET EFFICACE',
    'cpr_child': '1 AN — PUBERTÉ',
    'cpr_infant': '0 — 1 AN',
    'choking_infant': 'DÉSOBSTRUER LES VOIES AÉRIENNES',
    'drowning': 'RÉAGIR RAPIDEMENT',
    'anaphylaxis': 'RÉACTION ALLERGIQUE SÉVÈRE',
    'wounds': 'NE JAMAIS RETIRER UN OBJET FICHÉ',
    'waiting_positions': 'INSTALLER SANS AGGRAVER',
    'burn': 'REFROIDIR RAPIDEMENT',
    'stroke': 'RECONNAÎTRE · ALERTER',
    'chest_pain': 'MALAISE CARDIAQUE',
    'seizure': 'PROTÉGER · CHRONOMÉTRER',
    'hypothermia': 'RÉCHAUFFER PROGRESSIVEMENT',
    'heatstroke': 'REFROIDIR SANS ATTENDRE',
  };
  const english = <String, String>{
    'cpr_adult': 'ACT FAST — SAVE A LIFE',
    'choking_adult': 'HELP A PERSON WHO IS CHOKING',
    'unconscious': 'RECOVERY POSITION',
    'bleeding': 'STOP THE BLEEDING',
    'aed': 'SIMPLE AND EFFECTIVE',
    'cpr_child': '1 YEAR — PUBERTY',
    'cpr_infant': '0 — 1 YEAR',
    'choking_infant': 'CLEAR THE AIRWAY',
    'drowning': 'ACT QUICKLY',
    'anaphylaxis': 'SEVERE ALLERGIC REACTION',
    'wounds': 'NEVER REMOVE AN EMBEDDED OBJECT',
    'waiting_positions': 'POSITION WITHOUT WORSENING',
    'burn': 'COOL RAPIDLY',
    'stroke': 'RECOGNISE · CALL',
    'chest_pain': 'CARDIAC WARNING SIGNS',
    'seizure': 'PROTECT · TIME',
    'hypothermia': 'WARM GRADUALLY',
    'heatstroke': 'COOL WITHOUT DELAY',
  };
  return (en ? english : fr)[id] ?? (en ? 'FIRST AID' : 'PREMIERS SECOURS');
}

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  final _searchController = TextEditingController();

  String _query = '';
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesAge(String id) {
    if (_filter == 'all') return true;
    if (_filter == 'child') return id.contains('child');
    if (_filter == 'infant') return id.contains('infant');
    if (_filter == 'adult') return !id.contains('child') && !id.contains('infant');
    return true;
  }

  List<FirstAidGuide> get _essentials => [
        for (final id in _essentialIds)
          firstAidGuides.firstWhere((guide) => guide.id == id),
      ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';
    final q = normalizeSearchText(_query);
    final browsingAll = q.isNotEmpty || _filter != 'all';

    final guides = (browsingAll ? firstAidGuides : _essentials).where((guide) {
      if (!_matchesAge(guide.id)) return false;
      if (q.isEmpty) return true;
      final haystack = [
        t.get(guide.titleKey),
        t.get(guide.summaryKey),
        ...guide.steps.map((step) => _aidText(context, step.textKey)),
      ].join(' ');
      return normalizeSearchText(haystack).contains(q);
    }).toList();

    final extras = firstAidGuides.where((guide) => !_essentialIds.contains(guide.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff6faf9),
      appBar: AppBar(
        title: Text(t.get('firstAid')),
        actions: [
          IconButton(
            tooltip: en ? 'Emergency numbers' : 'Numéros d’urgence',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyScreen()),
            ),
            icon: const Icon(Icons.phone_in_talk_rounded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1180
              ? 5
              : width >= 900
                  ? 4
                  : width >= 650
                      ? 3
                      : width >= 460
                          ? 2
                          : 1;
          final horizontal = width >= 760 ? 16.0 : 10.0;
          final posterHeight = columns >= 5
              ? 405.0
              : columns == 4
                  ? 430.0
                  : columns == 3
                      ? 455.0
                      : columns == 2
                          ? 480.0
                          : 505.0;

          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 28),
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: _aidText(context, 'first_aid_search'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('all', _aidText(context, 'first_aid_all')),
                    _filterChip('adult', _aidText(context, 'first_aid_adult')),
                    _filterChip('child', _aidText(context, 'first_aid_child')),
                    _filterChip('infant', _aidText(context, 'first_aid_infant')),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (guides.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text(_aidText(context, 'first_aid_empty'))),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: guides.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: posterHeight,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                  ),
                  itemBuilder: (context, index) {
                    final guide = guides[index];
                    final essentialIndex = _essentialIds.indexOf(guide.id);
                    return _PosterGuideCard(
                      guide: guide,
                      number: essentialIndex >= 0 ? essentialIndex + 1 : null,
                      title: t.get(guide.titleKey),
                      subtitle: _posterTag(guide.id, en),
                      emergencyNumber: _emergencyNumber(context),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FirstAidDetailScreen(guide: guide)),
                      ),
                    );
                  },
                ),
              if (!browsingAll && extras.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  en ? 'MORE FIRST-AID POSTERS' : 'AUTRES FICHES PREMIERS SECOURS',
                  style: const TextStyle(
                    fontSize: 15,
                    letterSpacing: .5,
                    color: Color(0xff087f83),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: extras.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: posterHeight,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                  ),
                  itemBuilder: (context, index) {
                    final guide = extras[index];
                    return _PosterGuideCard(
                      guide: guide,
                      number: null,
                      title: t.get(guide.titleKey),
                      subtitle: _posterTag(guide.id, en),
                      emergencyNumber: _emergencyNumber(context),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FirstAidDetailScreen(guide: guide),
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 14),
              _MedicalNotice(text: t.get('medicalNotice')),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String value, String label) => Padding(
        padding: const EdgeInsets.only(right: 7),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter == value,
          showCheckmark: false,
          onSelected: (_) => setState(() => _filter = value),
        ),
      );
}

class _PosterGuideCard extends StatelessWidget {
  const _PosterGuideCard({
    required this.guide,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.emergencyNumber,
    required this.onTap,
  });

  final FirstAidGuide guide;
  final int? number;
  final String title;
  final String subtitle;
  final String? emergencyNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final steps = guide.steps.take(4).toList();
    final critical = _posterCritical(guide.id);
    final referencePoster = !en && emergencyNumber == '144'
        ? _referencePosterAssets[guide.id]
        : null;

    return Material(
      color: const Color(0xfffffdf7),
      elevation: 1,
      shadowColor: const Color(0x26000000),
      borderRadius: BorderRadius.circular(9),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: referencePoster != null
            ? Semantics(
                button: true,
                label: '$title. ${en ? 'Open guide' : 'Ouvrir la fiche'}',
                child: ColoredBox(
                  color: Colors.white,
                  child: Image.asset(
                    referencePoster,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              )
            : Container(
          decoration: BoxDecoration(
            color: const Color(0xfffffdf7),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xff58afa5), width: 1.4),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 7),
                color: const Color(0xff087f83),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: number == null
                          ? const Icon(
                              Icons.health_and_safety_rounded,
                              color: Color(0xff087f83),
                              size: 20,
                            )
                          : Text(
                              number.toString(),
                              style: TextStyle(
                                color: critical
                                    ? const Color(0xffd92d36)
                                    : const Color(0xff087f83),
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.2,
                              height: 1.0,
                              letterSpacing: .1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xffd8f3ef),
                              fontSize: 8.4,
                              letterSpacing: .2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xfffffff9),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Column(
                    children: [
                      for (var i = 0; i < steps.length; i++)
                        Expanded(
                          child: _PosterMiniStep(
                            number: i + 1,
                            text: _aidText(context, steps[i].textKey),
                            illustrationAsset: steps[i].illustrationAsset,
                            last: i == steps.length - 1,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                color: critical
                    ? const Color(0xffe52b34)
                    : const Color(0xffffdf35),
                child: Row(
                  children: [
                    Icon(
                      critical
                          ? Icons.warning_amber_rounded
                          : Icons.info_outline_rounded,
                      size: 18,
                      color: critical ? Colors.white : const Color(0xff6f4e00),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        emergencyNumber == null
                            ? (en
                                ? 'Immediate danger: use verified emergency numbers'
                                : 'Danger immédiat : utiliser les numéros d’urgence vérifiés')
                            : (en
                                ? 'Immediate danger: call $emergencyNumber'
                                : 'Danger immédiat : appeler le $emergencyNumber'),
                        style: TextStyle(
                          fontSize: 8.2,
                          color:
                              critical ? Colors.white : const Color(0xff6f4e00),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: critical ? Colors.white : const Color(0xff6f4e00),
                    ),
                  ],
                ),
              ),
              const _PosterBranding(),
            ],
          ),
              ),
      ),
    );
  }
}

class _PosterMiniStep extends StatelessWidget {
  const _PosterMiniStep({
    required this.number,
    required this.text,
    required this.illustrationAsset,
    required this.last,
  });

  final int number;
  final String text;
  final String illustrationAsset;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(2, 5, 1, 5),
        decoration: BoxDecoration(
          border: Border(
            bottom: last
                ? BorderSide.none
                : const BorderSide(color: Color(0xffd9e7e4)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xff087f83),
                shape: BoxShape.circle,
              ),
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 9.6,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff20383c),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 58,
              height: 56,
              child: SvgPicture.asset(
                illustrationAsset,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );
}

class _PosterBranding extends StatelessWidget {
  const _PosterBranding();

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    return Container(
      height: 23,
      alignment: Alignment.center,
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            color: Color(0xff087f83),
            size: 14,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              en ? 'ReadySafe · Be ready. Save lives.' : 'ReadySafe · Être prêt. Sauver des vies.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8.2,
                color: Color(0xff087f83),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FirstAidDetailScreen extends StatelessWidget {
  const FirstAidDetailScreen({super.key, required this.guide});
  final FirstAidGuide guide;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';
    final emergencyNumber = _emergencyNumber(context);
    final index = _essentialIds.indexOf(guide.id);
    final number = index < 0 ? null : index + 1;
    final referencePoster = !en && emergencyNumber == '144'
        ? _referencePosterAssets[guide.id]
        : null;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(t.get(guide.titleKey)),
        actions: [
          IconButton(
            tooltip: en ? 'Export PDF' : 'Exporter en PDF',
            onPressed: () async {
              try {
                await FirstAidPdfService.share(
                  guide: guide,
                  text: (key) => t.get(key),
                  english: en,
                  emergencyNumber: emergencyNumber,
                );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        en
                            ? 'Unable to export this PDF.'
                            : 'Impossible d’exporter ce PDF.',
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
          ),
          IconButton(
            tooltip: en ? 'Print guide' : 'Imprimer la fiche',
            onPressed: () async {
              try {
                await FirstAidPdfService.printGuide(
                  guide: guide,
                  text: (key) => t.get(key),
                  english: en,
                  emergencyNumber: emergencyNumber,
                );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        en
                            ? 'Unable to open printing.'
                            : 'Impossible d’ouvrir l’impression.',
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.print_rounded),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(en ? 'Back' : 'Retour'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xffd92d36),
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FirstAidEmergencyModeScreen(guide: guide)),
                ),
                icon: const Icon(Icons.sos_rounded),
                label: Text(en ? 'Emergency mode' : 'Mode urgence'),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 780;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListView(
                padding: EdgeInsets.fromLTRB(wide ? 24 : 12, 4, wide ? 24 : 12, 26),
                children: [
                  InteractiveViewer(
                    minScale: 1,
                    maxScale: 3.2,
                    boundaryMargin: const EdgeInsets.all(40),
                    child: referencePoster != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              referencePoster,
                              fit: BoxFit.fitWidth,
                              filterQuality: FilterQuality.high,
                            ),
                          )
                        : _PosterDetailPanel(
                            number: number,
                            title: t.get(guide.titleKey),
                            subtitle: _posterTag(guide.id, en),
                            guide: guide,
                            emergencyNumber: emergencyNumber,
                            onEmergency: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmergencyScreen(),
                              ),
                            ),
                          ),
                  ),
                  if (guide.definitionTitleKey != null &&
                      guide.definitionBodyKey != null) ...[
                    const SizedBox(height: 10),
                    _DefinitionBox(
                      title: t.get(guide.definitionTitleKey!),
                      body: t.get(guide.definitionBodyKey!),
                    ),
                  ],
                  for (final warningKey in guide.warningKeys) ...[
                    const SizedBox(height: 8),
                    _GuideWarning(text: t.get(warningKey)),
                  ],
                  const SizedBox(height: 10),
                  _MedicalNotice(text: t.get('medicalNotice')),
                  const SizedBox(height: 8),
                  _ReferenceSources(
                    sources: guide.sourceUris,
                    en: en,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReferenceSources extends StatelessWidget {
  const _ReferenceSources({
    required this.sources,
    required this.en,
  });

  final List<Uri> sources;
  final bool en;

  String _label(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host.contains('erc.edu')) return 'European Resuscitation Council · 2025';
    if (host.contains('nhs.uk')) return 'NHS · First aid';
    return host.replaceFirst('www.', '');
  }

  Future<void> _open(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            en ? 'Unable to open this reference.' : 'Impossible d’ouvrir cette référence.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        child: ExpansionTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xfffff4c7),
            child: Icon(Icons.verified_outlined, color: Color(0xff9a6a00)),
          ),
          title: Text(
            en ? 'Verified references' : 'Références vérifiées',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            en
                ? 'Offline guide · ${sources.length} authoritative source(s)'
                : 'Guide hors ligne · ${sources.length} source(s) de référence',
          ),
          children: [
            for (final source in sources)
              ListTile(
                dense: true,
                leading: const Icon(Icons.open_in_new_rounded, size: 20),
                title: Text(
                  _label(source),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  source.host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _open(context, source),
              ),
          ],
        ),
      );
}

class _PosterDetailPanel extends StatelessWidget {
  const _PosterDetailPanel({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.guide,
    required this.emergencyNumber,
    required this.onEmergency,
  });

  final int? number;
  final String title;
  final String subtitle;
  final FirstAidGuide guide;
  final String? emergencyNumber;
  final VoidCallback onEmergency;

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final critical = _posterCritical(guide.id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfffffff9),
        border: Border.all(color: const Color(0xff58afa5), width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
            color: const Color(0xff087f83),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: number == null
                      ? const Icon(
                          Icons.health_and_safety_rounded,
                          color: Color(0xff087f83),
                        )
                      : Text(
                          number.toString(),
                          style: TextStyle(
                            color: critical
                                ? const Color(0xffd92d36)
                                : const Color(0xff087f83),
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xffd8f3ef),
                          fontSize: 8.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final entry in guide.steps.indexed)
            _PosterFullStep(
              number: entry.$1 + 1,
              step: entry.$2,
              emphasizeCpr: guide.id == 'cpr_adult' && entry.$1 == 1,
              last: entry.$1 == guide.steps.length - 1,
            ),
          Material(
            color: critical
                ? const Color(0xffe52b34)
                : const Color(0xffffdf35),
            child: InkWell(
              onTap: onEmergency,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      critical
                          ? Icons.warning_amber_rounded
                          : Icons.phone_in_talk_rounded,
                      color: critical ? Colors.white : const Color(0xff6f4e00),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        emergencyNumber == null
                            ? (en
                                ? 'IMMEDIATE DANGER — USE VERIFIED EMERGENCY NUMBERS'
                                : 'DANGER IMMÉDIAT — UTILISER LES NUMÉROS D’URGENCE VÉRIFIÉS')
                            : (en
                                ? 'IMMEDIATE DANGER — CALL $emergencyNumber'
                                : 'DANGER IMMÉDIAT — APPELER LE $emergencyNumber'),
                        style: TextStyle(
                          color:
                              critical ? Colors.white : const Color(0xff6f4e00),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: critical ? Colors.white : const Color(0xff6f4e00),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const _PosterBranding(),
        ],
      ),
    );
  }
}

class _PosterFullStep extends StatelessWidget {
  const _PosterFullStep({
    required this.number,
    required this.step,
    required this.emphasizeCpr,
    required this.last,
  });

  final int number;
  final FirstAidStep step;
  final bool emphasizeCpr;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(9, 7, 8, 7),
        decoration: BoxDecoration(
          color: number.isOdd
              ? const Color(0xfffffff9)
              : const Color(0xfff7f2e8),
          border: Border(
            bottom: last
                ? BorderSide.none
                : const BorderSide(color: Color(0xffd7e6e2)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 23,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xff087f83),
                shape: BoxShape.circle,
              ),
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (step.headingKey != null) ...[
                    Text(
                      _aidText(context, step.headingKey!).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xff1268d8),
                        fontSize: 11.5,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    _aidText(context, step.textKey),
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  for (final detailKey in step.detailKeys) ...[
                    const SizedBox(height: 5),
                    _SquareBullet(text: _aidText(context, detailKey)),
                  ],
                  if (emphasizeCpr || step.cprPacing) ...[
                    const SizedBox(height: 7),
                    const Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetricBadge(label: '100–120/min'),
                        _MetricBadge(label: '5–6 cm', alert: true),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 112,
              height: 88,
              child: SvgPicture.asset(
                step.illustrationAsset,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );
}

class _SquareBullet extends StatelessWidget {
  const _SquareBullet({
    required this.text,
    this.fontSize = 11.5,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: EdgeInsets.only(top: fontSize * .45, right: 7),
            color: Colors.black87,
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
}

class _DefinitionBox extends StatelessWidget {
  const _DefinitionBox({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffeaf3ff),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffaacbf6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff1268d8),
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              body,
              style: const TextStyle(
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

class _GuideWarning extends StatelessWidget {
  const _GuideWarning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xffffeeee),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffffb8bd)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xffc8212c),
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, this.alert = false});
  final String label;
  final bool alert;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: alert ? const Color(0xffffe7e8) : const Color(0xffe7f4f2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: alert ? const Color(0xffc8212c) : const Color(0xff075e68),
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
        ),
      );
}

class FirstAidEmergencyModeScreen extends StatefulWidget {
  const FirstAidEmergencyModeScreen({super.key, required this.guide});
  final FirstAidGuide guide;

  @override
  State<FirstAidEmergencyModeScreen> createState() => _FirstAidEmergencyModeScreenState();
}

class _FirstAidEmergencyModeScreenState extends State<FirstAidEmergencyModeScreen> {
  static const _cprBeat = Duration(milliseconds: 545); // ≈110/min

  int index = 0;
  late final PageController controller;
  Timer? _metronome;
  bool _metronomeOn = false;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  void _pulse() {
    unawaited(SystemSound.play(SystemSoundType.click));
    unawaited(HapticFeedback.selectionClick());
  }

  void _startMetronome() {
    _metronome?.cancel();
    _pulse();
    _metronome = Timer.periodic(_cprBeat, (_) => _pulse());
    _metronomeOn = true;
  }

  void _stopMetronome() {
    _metronome?.cancel();
    _metronome = null;
    _metronomeOn = false;
  }

  void _toggleMetronome() {
    setState(() {
      if (_metronomeOn) {
        _stopMetronome();
      } else {
        _startMetronome();
      }
    });
  }

  @override
  void dispose() {
    _stopMetronome();
    controller.dispose();
    super.dispose();
  }

  void _go(int next) {
    if (next < 0 || next >= widget.guide.steps.length) return;
    controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';
    final emergencyNumber = _emergencyNumber(context);
    final compact = MediaQuery.sizeOf(context).width < 380;

    return Scaffold(
      backgroundColor: const Color(0xfff4f9f8),
      appBar: AppBar(
        title: Text(t.get(widget.guide.titleKey)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffffe7e8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${index + 1}/${widget.guide.steps.length}',
              style: const TextStyle(color: Color(0xffc8212c), fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (index + 1) / widget.guide.steps.length,
              minHeight: 6,
              color: const Color(0xffd92d36),
              backgroundColor: const Color(0xffffdfe1),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: widget.guide.steps.length,
                onPageChanged: (value) {
                  if (!widget.guide.steps[value].cprPacing) {
                    _stopMetronome();
                  }
                  setState(() => index = value);
                },
                itemBuilder: (context, pageIndex) {
                  final step = widget.guide.steps[pageIndex];
                  final cprMetric = step.cprPacing;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xff087f83),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Text(
                                  '${pageIndex + 1}',
                                  style: const TextStyle(color: Color(0xff087f83), fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  en ? 'EMERGENCY STEP ${pageIndex + 1}' : 'ÉTAPE URGENCE ${pageIndex + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: .4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: (MediaQuery.sizeOf(context).height * .28)
                              .clamp(140.0, 240.0)
                              .toDouble(),
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffeaf6f4),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xffcce4e1)),
                          ),
                          child: SvgPicture.asset(step.illustrationAsset, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xffd3e6e3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (step.headingKey != null) ...[
                                Text(
                                  _aidText(context, step.headingKey!).toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xff1268d8),
                                    fontSize: 14,
                                    height: 1.15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 7),
                              ],
                              Text(
                                _aidText(context, step.textKey),
                                style: const TextStyle(
                                  fontSize: 19,
                                  height: 1.32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              for (final detailKey in step.detailKeys) ...[
                                const SizedBox(height: 9),
                                _SquareBullet(
                                  text: _aidText(context, detailKey),
                                  fontSize: 14,
                                ),
                              ],
                              if (cprMetric) ...[
                                const SizedBox(height: 12),
                                const Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _MetricBadge(label: '100–120/min'),
                                    _MetricBadge(label: '5–6 cm', alert: true),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _metronomeOn
                                          ? const Color(0xffd92d36)
                                          : const Color(0xff1268d8),
                                    ),
                                    onPressed: _toggleMetronome,
                                    icon: Icon(
                                      _metronomeOn
                                          ? Icons.stop_circle_outlined
                                          : Icons.graphic_eq_rounded,
                                    ),
                                    label: Text(
                                      _metronomeOn
                                          ? (en
                                              ? 'Stop CPR rhythm'
                                              : 'Arrêter le rythme RCR')
                                          : (en
                                              ? 'Start 110/min rhythm'
                                              : 'Démarrer le rythme 110/min'),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xfffff2c5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, color: Color(0xff9a6a00)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  en
                                      ? 'Follow the emergency operator’s instructions whenever available.'
                                      : 'Suivez les instructions de l’opérateur des secours dès qu’elles sont disponibles.',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: index == 0 ? null : () => _go(index - 1),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(compact ? (en ? 'Back' : 'Préc.') : (en ? 'Previous' : 'Précédent')),
                    ),
                  ),
                  const SizedBox(width: 7),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffd92d36),
                      minimumSize: const Size(112, 50),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                    ),
                    icon: const Icon(Icons.call_rounded),
                    label: Text(emergencyNumber ?? (en ? 'Numbers' : 'Numéros')),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: index == widget.guide.steps.length - 1 ? null : () => _go(index + 1),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(compact ? (en ? 'Next' : 'Suiv.') : (en ? 'Next' : 'Suivant')),
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
}

class _MedicalNotice extends StatelessWidget {
  const _MedicalNotice({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xffffeeee),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.emergency_outlined, color: Color(0xffd92d36)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.35),
              ),
            ),
          ],
        ),
      );
}
