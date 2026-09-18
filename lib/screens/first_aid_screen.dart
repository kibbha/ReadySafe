import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../data/first_aid_repository.dart';
import '../models/country_profile.dart';
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
    'first_aid_header_body': '10 fiches essentielles pour savoir réagir en cas d’urgence',
    'aid_child_cpr_1': 'Vérifiez la réaction et la respiration. Appelez les secours sans délai et utilisez le haut-parleur.',
    'aid_child_cpr_2': 'Si l’enfant ne respire pas normalement, donnez 5 insufflations initiales.',
    'aid_child_cpr_3': 'Commencez immédiatement les compressions. Faites 30 compressions pour 2 insufflations, ou 15:2 si vous êtes spécifiquement formé à la RCP pédiatrique PBLS.',
    'aid_child_cpr_4': 'Faites apporter et connecter un DAE dès que possible. Suivez ses instructions sans interrompre inutilement la RCP.',
    'aid_infant_cpr_1': 'Vérifiez la réaction et la respiration. Appelez les secours sans délai et utilisez le haut-parleur.',
    'aid_infant_cpr_2': 'Si le nourrisson ne respire pas normalement, donnez 5 insufflations initiales.',
    'aid_infant_cpr_3': 'Commencez immédiatement les compressions. Faites 30 compressions pour 2 insufflations, ou 15:2 si vous êtes spécifiquement formé à la RCP pédiatrique PBLS.',
    'aid_infant_cpr_4': 'Faites apporter et connecter un DAE dès que possible. Suivez ses instructions sans interrompre inutilement la RCP.',
  };

  const english = <String, String>{
    'first_aid_search': 'Search a guide or symptom',
    'first_aid_empty': 'No matching guide',
    'first_aid_all': 'All',
    'first_aid_adult': 'Adult',
    'first_aid_child': 'Child',
    'first_aid_infant': 'Infant',
    'first_aid_header': 'First Aid Guides',
    'first_aid_header_body': '10 essential guides to help you react in an emergency',
    'aid_child_cpr_1': 'Check responsiveness and breathing. Call emergency services without delay and use speakerphone.',
    'aid_child_cpr_2': 'If the child is not breathing normally, give 5 initial rescue breaths.',
    'aid_child_cpr_3': 'Immediately start compressions. Use 30 compressions to 2 breaths, or 15:2 if you are specifically trained in paediatric PBLS.',
    'aid_child_cpr_4': 'Have an AED brought and attached as soon as possible. Follow its prompts and minimise interruptions to CPR.',
    'aid_infant_cpr_1': 'Check responsiveness and breathing. Call emergency services without delay and use speakerphone.',
    'aid_infant_cpr_2': 'If the infant is not breathing normally, give 5 initial rescue breaths.',
    'aid_infant_cpr_3': 'Immediately start compressions. Use 30 compressions to 2 breaths, or 15:2 if you are specifically trained in paediatric PBLS.',
    'aid_infant_cpr_4': 'Have an AED brought and attached as soon as possible. Follow its prompts and minimise interruptions to CPR.',
  };

  return (en ? english : fr)[key] ?? t.get(key);
}

String _emergencyNumber(BuildContext context) {
  final country = AppScope.of(context).activeCountry!;
  EmergencyService? preferred;
  for (final service in country.services) {
    if (!service.isCallable) continue;
    if (service.id == 'medical' || service.nameKey.contains('ambulance')) {
      preferred = service;
      break;
    }
  }
  if (preferred != null && preferred.number != null) return preferred.number!;
  for (final service in country.services) {
    if (service.isCallable && service.number != null) return service.number!;
  }
  return '112';
}

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  String _query = '';
  String _filter = 'all';

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
    final q = _query.trim().toLowerCase();
    final browsingAll = q.isNotEmpty || _filter != 'all';

    final guides = (browsingAll ? firstAidGuides : _essentials).where((guide) {
      if (!_matchesAge(guide.id)) return false;
      if (q.isEmpty) return true;
      final haystack = [
        t.get(guide.titleKey),
        t.get(guide.summaryKey),
        ...guide.steps.map((step) => _aidText(context, step.textKey)),
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();

    final extras = firstAidGuides
        .where((guide) => !_essentialIds.contains(guide.id))
        .toList();

    return Scaffold(
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
          final columns = width >= 900
              ? 5
              : width >= 650
                  ? 3
                  : 2;
          final horizontal = width >= 760 ? 22.0 : 12.0;
          final posterHeight = width >= 900
              ? 350.0
              : width >= 650
                  ? 330.0
                  : 310.0;

          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 2, horizontal, 28),
            children: [
              _FirstAidHeader(
                title: _aidText(context, 'first_aid_header'),
                subtitle: _aidText(context, 'first_aid_header_body'),
                emergencyNumber: _emergencyNumber(context),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: _aidText(context, 'first_aid_search'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => setState(() => _query = ''),
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 12),
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
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final guide = guides[index];
                    final essentialIndex = _essentialIds.indexOf(guide.id);
                    return _PosterGuideCard(
                      guide: guide,
                      number: essentialIndex >= 0 ? essentialIndex + 1 : null,
                      title: t.get(guide.titleKey),
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
              if (!browsingAll && extras.isNotEmpty) ...[
                const SizedBox(height: 18),
                _AdditionalGuides(guides: extras),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffffeeee),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.emergency_outlined, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        t.get('medicalNotice'),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String value, String label) => Padding(
        padding: const EdgeInsets.only(right: 8),
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
  final String emergencyNumber;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffdbe8e7)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xff087f83),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 29),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xff607075), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xffffeeee),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.call_rounded, size: 16, color: Color(0xffd92d36)),
                  const SizedBox(width: 4),
                  Text(
                    emergencyNumber,
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
    required this.emergencyNumber,
    required this.onTap,
  });

  final FirstAidGuide guide;
  final int? number;
  final String title;
  final String emergencyNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final steps = guide.steps.take(4).toList();
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xffb9ded9)),
          ),
          child: Column(
            children: [
              Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xff087f83),
                child: Row(
                  children: [
                    if (number != null)
                      Container(
                        width: 33,
                        height: 33,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Text(
                          number.toString(),
                          style: const TextStyle(color: Color(0xff087f83), fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                    if (number != null) const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 11.5, height: 1.05, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(7, 7, 7, 5),
                  child: Column(
                    children: [
                      for (var i = 0; i < steps.length; i++)
                        Expanded(
                          child: _PosterStep(
                            number: i + 1,
                            text: _aidText(context, steps[i].textKey),
                            illustrationAsset: steps[i].illustrationAsset,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                color: const Color(0xffffeded),
                child: Text(
                  en ? 'Emergency $emergencyNumber' : 'Urgence $emergencyNumber',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xffc8212c), fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterStep extends StatelessWidget {
  const _PosterStep({
    required this.number,
    required this.text,
    required this.illustrationAsset,
  });

  final int number;
  final String text;
  final String illustrationAsset;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xff087f83), shape: BoxShape.circle),
              child: Text(
                number.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9.2, height: 1.1, fontWeight: FontWeight.w700, color: Color(0xff31464b)),
              ),
            ),
            const SizedBox(width: 3),
            SizedBox(
              width: 50,
              height: 52,
              child: SvgPicture.asset(illustrationAsset, fit: BoxFit.contain),
            ),
          ],
        ),
      );
}

class _AdditionalGuides extends StatelessWidget {
  const _AdditionalGuides({required this.guides});
  final List<FirstAidGuide> guides;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Card(
      child: ExpansionTile(
        title: Text(
          en ? 'Additional first-aid guides' : 'Fiches complémentaires',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          en ? '${guides.length} additional situations' : '${guides.length} situations supplémentaires',
        ),
        children: [
          for (final guide in guides)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffe5f3f1),
                child: Icon(Icons.health_and_safety_outlined, color: Color(0xff087f83)),
              ),
              title: Text(t.get(guide.titleKey), style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(t.get(guide.summaryKey), maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FirstAidDetailScreen(guide: guide)),
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

    return Scaffold(
      appBar: AppBar(title: Text(t.get(guide.titleKey))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: ListView(
                padding: EdgeInsets.fromLTRB(wide ? 24 : 14, 4, wide ? 24 : 14, 30),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffeaf6f4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.get(guide.summaryKey),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff087f83),
                            minimumSize: const Size.fromHeight(52),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.menu_book_rounded),
                          label: Text(en ? 'Learn' : 'Apprendre'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FirstAidEmergencyModeScreen(guide: guide),
                            ),
                          ),
                          icon: const Icon(Icons.sos_rounded),
                          label: Text(en ? 'Emergency mode' : 'Mode urgence'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xffffeeee),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xffffcccc)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.phone_in_talk, color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.get('aid_call_now'),
                            style: const TextStyle(fontWeight: FontWeight.w800, height: 1.3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            minimumSize: const Size(62, 42),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                          ),
                          child: Text(emergencyNumber),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...guide.steps.indexed.map(
                    (entry) => _StepCard(
                      number: entry.$1 + 1,
                      step: entry.$2,
                      wide: wide,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_outlined, size: 18, color: Color(0xff087f83)),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          t.get('medicalNotice'),
                          style: const TextStyle(fontSize: 12, color: Color(0xff65747a)),
                        ),
                      ),
                    ],
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

    return Scaffold(
      backgroundColor: const Color(0xfff8fbfa),
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
              minHeight: 5,
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
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xffeaf6f4),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: SvgPicture.asset(step.illustrationAsset, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          flex: 4,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xffdbe8e8)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  en ? 'STEP ${pageIndex + 1}' : 'ÉTAPE ${pageIndex + 1}',
                                  style: const TextStyle(
                                    color: Color(0xff087f83),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: .8,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      _aidText(context, step.textKey),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        height: 1.35,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xff203338),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: index == 0 ? null : () => _go(index - 1),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(en ? 'Previous' : 'Précédent'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      minimumSize: const Size(118, 50),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                    ),
                    icon: const Icon(Icons.call_rounded),
                    label: Text(emergencyNumber),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: index == widget.guide.steps.length - 1
                          ? null
                          : () => _go(index + 1),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(en ? 'Next' : 'Suivant'),
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

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.step,
    required this.wide,
  });

  final int number;
  final FirstAidStep step;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final visual = Container(
      height: wide ? 255 : 220,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
      decoration: BoxDecoration(
        color: const Color(0xffeaf6f4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: SvgPicture.asset(step.illustrationAsset, fit: BoxFit.contain),
    );

    final copy = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffdbe8e8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xff087f83),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                en ? 'Step $number' : 'Étape $number',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xff075e68)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _aidText(context, step.textKey),
            style: const TextStyle(
              fontSize: 16,
              height: 1.42,
              fontWeight: FontWeight.w600,
              color: Color(0xff24363a),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: visual),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: copy),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                visual,
                Transform.translate(offset: const Offset(0, -8), child: copy),
              ],
            ),
    );
  }
}
