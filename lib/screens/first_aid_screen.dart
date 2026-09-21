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
import '../services/emergency_speech_service.dart';
import 'emergency_screen.dart';
import 'online_maps_screen.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          final effectiveTextScale =
              MediaQuery.textScalerOf(context).scale(16) / 16;
          final useAccessibleList =
              width < 520 || effectiveTextScale > 1.30;

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
                _GuideCollection(
                  guides: guides,
                  columns: columns,
                  posterHeight: posterHeight,
                  accessibleList: useAccessibleList,
                ),
              if (!browsingAll && extras.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  en ? 'MORE FIRST-AID POSTERS' : 'AUTRES FICHES PREMIERS SECOURS',
                  style: TextStyle(
                    fontSize: 15,
                    letterSpacing: .5,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                _GuideCollection(
                  guides: extras,
                  columns: columns,
                  posterHeight: posterHeight,
                  accessibleList: useAccessibleList,
                  numberGuides: false,
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

class _GuideCollection extends StatelessWidget {
  const _GuideCollection({
    required this.guides,
    required this.columns,
    required this.posterHeight,
    required this.accessibleList,
    this.numberGuides = true,
  });

  final List<FirstAidGuide> guides;
  final int columns;
  final double posterHeight;
  final bool accessibleList;
  final bool numberGuides;

  void _open(BuildContext context, FirstAidGuide guide) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirstAidDetailScreen(guide: guide),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';

    if (accessibleList) {
      return Column(
        children: [
          for (var i = 0; i < guides.length; i++) ...[
            _AccessibleGuideCard(
              guide: guides[i],
              number: numberGuides
                  ? (() {
                      final value = _essentialIds.indexOf(guides[i].id);
                      return value < 0 ? null : value + 1;
                    })()
                  : null,
              title: t.get(guides[i].titleKey),
              summary: t.get(guides[i].summaryKey),
              onTap: () => _open(context, guides[i]),
            ),
            if (i != guides.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }

    return GridView.builder(
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
          number: numberGuides && essentialIndex >= 0
              ? essentialIndex + 1
              : null,
          title: t.get(guide.titleKey),
          subtitle: _posterTag(guide.id, en),
          emergencyNumber: _emergencyNumber(context),
          onTap: () => _open(context, guide),
        );
      },
    );
  }
}

class _AccessibleGuideCard extends StatelessWidget {
  const _AccessibleGuideCard({
    required this.guide,
    required this.number,
    required this.title,
    required this.summary,
    required this.onTap,
  });

  final FirstAidGuide guide;
  final int? number;
  final String title;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final critical = _posterCritical(guide.id);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 13, 10, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: critical
                      ? scheme.errorContainer
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: number == null
                    ? Icon(
                        Icons.health_and_safety_rounded,
                        color: critical
                            ? scheme.onErrorContainer
                            : scheme.onPrimaryContainer,
                      )
                    : Text(
                        '$number',
                        style: TextStyle(
                          color: critical
                              ? scheme.onErrorContainer
                              : scheme.onPrimaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      summary,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (guide.supportsCprMetronome) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _SmallFeatureChip(
                            icon: Icons.graphic_eq_rounded,
                            label: '100–120/min',
                          ),
                          const _SmallFeatureChip(
                            icon: Icons.offline_bolt_rounded,
                            label: 'Offline',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.primary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallFeatureChip extends StatelessWidget {
  const _SmallFeatureChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovedUnconsciousImage extends StatelessWidget {
  const _ApprovedUnconsciousImage({
    required this.fit,
    this.alignment = Alignment.center,
  });

  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/first_aid_sheets/unconscious_pls_approved.webp',
      width: double.infinity,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );
  }
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
    final useApprovedPreview = guide.id == 'unconscious' && !en;
    return Material(
      color: const Color(0xfffffdf7),
      elevation: 1,
      shadowColor: const Color(0x26000000),
      borderRadius: BorderRadius.circular(9),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
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
                child: useApprovedPreview
                    ? const ColoredBox(
                        color: Color(0xfffffff9),
                        child: ClipRect(
                          child: _ApprovedUnconsciousImage(
                            fit: BoxFit.cover,
                            alignment: Alignment(0, -0.32),
                          ),
                        ),
                      )
                    : Container(
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
    final useApprovedImageSheet = guide.id == 'unconscious' && !en;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        minimum: const EdgeInsets.fromLTRB(6, 5, 6, 7),
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
          final wide = constraints.maxWidth >= 900;
          final horizontal = wide ? 18.0 : 4.0;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: ListView(
                padding: EdgeInsets.fromLTRB(horizontal, 2, horizontal, 20),
                children: [
                  if (useApprovedImageSheet)
                    const _ApprovedFirstAidSheetImage()
                  else
                    InteractiveViewer(
                      minScale: 1,
                      maxScale: 3.2,
                      boundaryMargin: const EdgeInsets.all(56),
                      child: _PosterDetailPanel(
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
                    const SizedBox(height: 8),
                    _DefinitionBox(
                      title: t.get(guide.definitionTitleKey!),
                      body: t.get(guide.definitionBodyKey!),
                    ),
                  ],
                  for (final warningKey in guide.warningKeys) ...[
                    const SizedBox(height: 8),
                    _GuideWarning(text: t.get(warningKey)),
                  ],
                  const SizedBox(height: 8),
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

class _ApprovedFirstAidSheetImage extends StatelessWidget {
  const _ApprovedFirstAidSheetImage();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label:
          'Fiche visuelle premiers secours : vérifier la conscience et la respiration',
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 3.2,
        boundaryMargin: EdgeInsets.all(48),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          child: _ApprovedUnconsciousImage(
            fit: BoxFit.fitWidth,
          ),
        ),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffbfd5dc)),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
            color: const Color(0xff1268d8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: number == null
                      ? const Icon(
                          Icons.health_and_safety_rounded,
                          color: Color(0xff1268d8),
                          size: 30,
                        )
                      : Text(
                          number.toString(),
                          style: TextStyle(
                            color: critical
                                ? const Color(0xffd92d36)
                                : const Color(0xff1268d8),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          height: 1.02,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xffdcecff),
                          fontSize: 11.5,
                          height: 1.15,
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
                ? const Color(0xffd92d36)
                : const Color(0xffffdf35),
            child: InkWell(
              onTap: onEmergency,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      critical
                          ? Icons.warning_amber_rounded
                          : Icons.phone_in_talk_rounded,
                      color: critical ? Colors.white : const Color(0xff654900),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
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
                              critical ? Colors.white : const Color(0xff654900),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: critical ? Colors.white : const Color(0xff654900),
                      size: 28,
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageHeight = (screenWidth * .58).clamp(220.0, 380.0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: number.isOdd ? Colors.white : const Color(0xfff6fafc),
        border: Border(
          bottom: last
              ? BorderSide.none
              : const BorderSide(color: Color(0xffd9e6eb)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: imageHeight,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xffeef6f8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffd3e4e9)),
            ),
            child: SvgPicture.asset(
              step.illustrationAsset,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xff1268d8),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step.headingKey != null) ...[
                      Text(
                        _aidText(context, step.headingKey!).toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xff1268d8),
                          fontSize: 14.5,
                          height: 1.18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      _aidText(context, step.textKey),
                      style: const TextStyle(
                        color: Color(0xff172126),
                        fontSize: 17,
                        height: 1.32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    for (final detailKey in step.detailKeys) ...[
                      const SizedBox(height: 7),
                      _SquareBullet(
                        text: _aidText(context, detailKey),
                        fontSize: 14,
                        color: const Color(0xff172126),
                      ),
                    ],
                    if (emphasizeCpr || step.cprPacing) ...[
                      const SizedBox(height: 10),
                      const Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _MetricBadge(label: '100–120/min'),
                          _MetricBadge(label: '5–6 cm', alert: true),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SquareBullet extends StatelessWidget {
  const _SquareBullet({
    required this.text,
    this.fontSize = 11.5,
    this.color,
  });

  final String text;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? Theme.of(context).colorScheme.onSurface;
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: EdgeInsets.only(top: fontSize * .45, right: 7),
            color: foreground,
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: foreground,
                fontSize: fontSize,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
  }
}

class _DefinitionBox extends StatelessWidget {
  const _DefinitionBox({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.primary.withValues(alpha: .35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: scheme.onPrimaryContainer,
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
}

class _GuideWarning extends StatelessWidget {
  const _GuideWarning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.error.withValues(alpha: .35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: scheme.onErrorContainer,
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
  final EmergencySpeechService _speech = EmergencySpeechService();
  Timer? _metronome;
  bool _metronomeOn = false;
  bool _autoRead = false;
  bool _preparingSpeech = false;
  EmergencySpeechAvailability? _speechAvailability;
  String? _speechLanguage;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_speechLanguage != language) {
      _speechLanguage = language;
      unawaited(_prepareSpeech(language));
    }
  }

  Future<void> _prepareSpeech(String language) async {
    if (_preparingSpeech) return;
    _preparingSpeech = true;
    final availability = await _speech.prepare(language);
    if (!mounted) return;
    setState(() {
      _speechAvailability = availability;
      _preparingSpeech = false;
      if (availability != EmergencySpeechAvailability.ready) {
        _autoRead = false;
      }
    });
  }

  String _spokenStep(int pageIndex) {
    final step = widget.guide.steps[pageIndex];
    final parts = <String>[
      if (step.headingKey != null) _aidText(context, step.headingKey!),
      _aidText(context, step.textKey),
      for (final key in step.detailKeys) _aidText(context, key),
    ];
    return parts.join('. ');
  }

  Future<void> _readStep(int pageIndex) async {
    final en = Localizations.localeOf(context).languageCode == 'en';
    var availability = _speechAvailability;
    if (availability != EmergencySpeechAvailability.ready) {
      await _prepareSpeech(en ? 'en' : 'fr');
      availability = _speechAvailability;
    }

    if (availability != EmergencySpeechAvailability.ready) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              en
                  ? 'Offline voice unavailable. Install an offline English voice in your phone settings.'
                  : 'Voix hors ligne indisponible. Installez une voix française hors ligne dans les réglages du téléphone.',
            ),
          ),
        );
      }
      return;
    }

    final ok = await _speech.speak(_spokenStep(pageIndex));
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            en
                ? 'Unable to read this step aloud.'
                : 'Impossible de lire cette étape à voix haute.',
          ),
        ),
      );
    }
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
    unawaited(_speech.dispose());
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
    final supportsAedLocator =
        widget.guide.supportsCprMetronome || widget.guide.id == 'aed';

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(t.get(widget.guide.titleKey)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${index + 1}/${widget.guide.steps.length}',
              style: TextStyle(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w900,
              ),
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
                  if (_autoRead &&
                      _speechAvailability == EmergencySpeechAvailability.ready) {
                    unawaited(_readStep(value));
                  }
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
                          height: (MediaQuery.sizeOf(context).height * .38)
                              .clamp(220.0, 360.0)
                              .toDouble(),
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xffd3e4e9),
                            ),
                          ),
                          child: SvgPicture.asset(
                            step.illustrationAsset,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: scheme.outline),
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
                        _SpeechControls(
                          ready: _speechAvailability ==
                              EmergencySpeechAvailability.ready,
                          preparing: _preparingSpeech,
                          autoRead: _autoRead,
                          en: en,
                          onRead: () => _readStep(pageIndex),
                          onAutoReadChanged: (enabled) {
                            if (_speechAvailability !=
                                EmergencySpeechAvailability.ready) {
                              unawaited(_readStep(pageIndex));
                              return;
                            }
                            setState(() => _autoRead = enabled);
                            if (enabled) {
                              unawaited(_readStep(pageIndex));
                            } else {
                              unawaited(_speech.stop());
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: scheme.onTertiaryContainer,
                              ),
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
            if (supportsAedLocator)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffd9822b),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnlineMapsScreen(
                          autoFindNearestAed: true,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.near_me_rounded),
                    label: Text(
                      en ? 'Find nearest AED' : 'Trouver le DAE le plus proche',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
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

class _SpeechControls extends StatelessWidget {
  const _SpeechControls({
    required this.ready,
    required this.preparing,
    required this.autoRead,
    required this.en,
    required this.onRead,
    required this.onAutoReadChanged,
  });

  final bool ready;
  final bool preparing;
  final bool autoRead;
  final bool en;
  final VoidCallback onRead;
  final ValueChanged<bool> onAutoReadChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: preparing ? null : onRead,
              icon: preparing
                  ? const SizedBox.square(
                      dimension: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      ready
                          ? Icons.volume_up_rounded
                          : Icons.download_for_offline_outlined,
                    ),
              label: Text(
                ready
                    ? (en ? 'Read this step' : 'Lire cette étape')
                    : (en ? 'Offline voice' : 'Voix hors ligne'),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: autoRead,
                onChanged: preparing ? null : onAutoReadChanged,
              ),
              Text(
                en ? 'Auto' : 'Auto',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicalNotice extends StatelessWidget {
  const _MedicalNotice({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.emergency_outlined, color: scheme.onErrorContainer),
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
}
