import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../core/search_text.dart';
import '../data/first_aid_repository.dart';
import '../models/first_aid_guide.dart';
import 'emergency_screen.dart';

const _essentialIds = <String>[
  'cpr_adult',
  'choking_adult',
  'unconscious',
  'bleeding',
  'aed',
  'cpr_child',
  'cpr_infant',
  'choking_infant',
  'drowning',
  'anaphylaxis',
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
          final columns = width >= 1500
              ? 5
              : width >= 1050
                  ? 3
                  : width >= 640
                      ? 2
                      : 1;
          final horizontal = width >= 760 ? 20.0 : 12.0;
          final posterHeight = columns >= 3
              ? 610.0
              : columns == 2
                  ? 575.0
                  : 545.0;

          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 28),
            children: [
              _FirstAidHeader(
                title: _aidText(context, 'first_aid_header'),
                subtitle: _aidText(context, 'first_aid_header_body'),
                emergencyNumber: _emergencyNumber(context),
              ),
              const SizedBox(height: 10),
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

class _FirstAidHeader extends StatelessWidget {
  const _FirstAidHeader({
    required this.title,
    required this.subtitle,
    required this.emergencyNumber,
  });

  final String title;
  final String subtitle;
  final String? emergencyNumber;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffe5f4f1), Color(0xfffff5e8)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffd7e8e5)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xff087f83),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xff607075), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xffffe8e8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(Icons.call_rounded, size: 15, color: Color(0xffd92d36)),
                  const SizedBox(width: 4),
                  Text(
                    emergencyNumber ?? (Localizations.localeOf(context).languageCode == 'en' ? 'Numbers' : 'Numéros'),
                    style: const TextStyle(color: Color(0xffd92d36), fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
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
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: number == null
                          ? const Icon(
                              Icons.health_and_safety_rounded,
                              color: Color(0xff087f83),
                              size: 23,
                            )
                          : Text(
                              number.toString(),
                              style: TextStyle(
                                color: critical
                                    ? const Color(0xffd92d36)
                                    : const Color(0xff087f83),
                                fontSize: 22,
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
                              fontSize: 15.5,
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
                              fontSize: 9.3,
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
                          fontSize: 10.5,
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
              width: 25,
              height: 25,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xff087f83),
                shape: BoxShape.circle,
              ),
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.7,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff20383c),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 78,
              height: 76,
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
      height: 28,
      alignment: Alignment.center,
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            color: Color(0xff087f83),
            size: 16,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              en ? 'ReadySafe · Be ready. Save lives.' : 'ReadySafe · Être prêt. Sauver des vies.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.2,
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

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(t.get(guide.titleKey))),
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
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: EdgeInsets.fromLTRB(wide ? 24 : 12, 4, wide ? 24 : 12, 26),
                children: [
                  _PosterDetailPanel(
                    number: number,
                    title: t.get(guide.titleKey),
                    subtitle: _posterTag(guide.id, en),
                    guide: guide,
                    emergencyNumber: emergencyNumber,
                    onEmergency: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                    ),
                  ),
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
        borderRadius: BorderRadius.circular(10),
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
                          fontSize: 10.5,
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
              height: 28,
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
                  Text(
                    _aidText(context, step.textKey),
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (emphasizeCpr) ...[
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
  int index = 0;
  late final PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
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
                onPageChanged: (value) => setState(() => index = value),
                itemBuilder: (context, pageIndex) {
                  final step = widget.guide.steps[pageIndex];
                  final cprMetric = widget.guide.id == 'cpr_adult' && pageIndex == 2;
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
                              Text(
                                _aidText(context, step.textKey),
                                style: const TextStyle(fontSize: 19, height: 1.32, fontWeight: FontWeight.w800),
                              ),
                              if (cprMetric) ...[
                                const SizedBox(height: 10),
                                const Wrap(
                                  spacing: 8,
                                  children: [
                                    _MetricBadge(label: '100–120/min'),
                                    _MetricBadge(label: '5–6 cm', alert: true),
                                  ],
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
