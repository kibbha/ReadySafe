import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

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
    'first_aid_header_body': '10 fiches essentielles, visuelles et disponibles hors ligne',
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
    'first_aid_header_body': '10 essential visual guides available offline',
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
          final columns = width >= 1280
              ? 4
              : width >= 900
                  ? 3
                  : width >= 560
                      ? 2
                      : 1;
          final horizontal = width >= 760 ? 20.0 : 12.0;
          final posterHeight = width >= 1280
              ? 470.0
              : width >= 900
                  ? 485.0
                  : width >= 560
                      ? 500.0
                      : 515.0;

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
                const SizedBox(height: 16),
                _AdditionalGuides(guides: extras),
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
  final String emergencyNumber;

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
    required this.subtitle,
    required this.emergencyNumber,
    required this.onTap,
  });

  final FirstAidGuide guide;
  final int? number;
  final String title;
  final String subtitle;
  final String emergencyNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final steps = guide.steps.take(3).toList();
    final hero = guide.steps.first.illustrationAsset;

    return Material(
      color: const Color(0xfffffcf5),
      elevation: 1.5,
      shadowColor: const Color(0x22000000),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xff7fc7bd), width: 1.3),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(13, 11, 12, 10),
                color: const Color(0xff087f83),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (number != null)
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          number.toString(),
                          style: const TextStyle(
                            color: Color(0xff087f83),
                            fontWeight: FontWeight.w900,
                            fontSize: 21,
                          ),
                        ),
                      ),
                    if (number != null) const SizedBox(width: 10),
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
                              fontSize: 16,
                              height: 1.0,
                              letterSpacing: .2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xffdff7f2),
                              fontSize: 10,
                              letterSpacing: .25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0x22ffffff),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.offline_pin_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 13, 18, 8),
                  decoration: const BoxDecoration(
                    color: Color(0xffeff8f6),
                    border: Border(
                      bottom: BorderSide(color: Color(0xffd6ebe7)),
                    ),
                  ),
                  child: SvgPicture.asset(hero, fit: BoxFit.contain),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  color: const Color(0xfffffcf5),
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
                  child: Column(
                    children: [
                      for (var i = 0; i < steps.length; i++)
                        Expanded(
                          child: _PosterMiniStep(
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                color: const Color(0xffffe61a),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_in_talk_rounded,
                      size: 17,
                      color: Color(0xff9f1d25),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        en
                            ? 'Severe situation: call $emergencyNumber'
                            : 'Situation grave : appeler le $emergencyNumber',
                        style: const TextStyle(
                          fontSize: 11.2,
                          color: Color(0xff9f1d25),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      en ? 'OPEN' : 'OUVRIR',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xff6f161c),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xff6f161c),
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
}

class _PosterMiniStep extends StatelessWidget {
  const _PosterMiniStep({
    required this.number,
    required this.text,
    required this.illustrationAsset,
  });

  final int number;
  final String text;
  final String illustrationAsset;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.fromLTRB(8, 5, 6, 5),
        decoration: BoxDecoration(
          color: number.isOdd ? const Color(0xffffffff) : const Color(0xfff7f1e7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffebe1d1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 27,
              height: 27,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xff087f83),
                shape: BoxShape.circle,
              ),
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.2,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff263b40),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 54,
              height: 54,
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
        leading: const CircleAvatar(
          backgroundColor: Color(0xffe5f3f1),
          child: Icon(Icons.add_circle_outline_rounded, color: Color(0xff087f83)),
        ),
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
              constraints: const BoxConstraints(maxWidth: 980),
              child: ListView(
                padding: EdgeInsets.fromLTRB(wide ? 24 : 12, 4, wide ? 24 : 12, 26),
                children: [
                  _PosterDetailHeader(
                    number: number,
                    title: t.get(guide.titleKey),
                    subtitle: _posterTag(guide.id, en),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffeaf6f4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xff087f83)),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            t.get(guide.summaryKey),
                            style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: const Color(0xffd92d36),
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.call_rounded, color: Colors.white, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                en ? 'EMERGENCY — CALL $emergencyNumber' : 'URGENCE — APPELER LE $emergencyNumber',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  ...guide.steps.indexed.map(
                    (entry) => _DetailStepCard(
                      number: entry.$1 + 1,
                      step: entry.$2,
                      emphasizeCpr: guide.id == 'cpr_adult' && entry.$1 == 2,
                    ),
                  ),
                  const SizedBox(height: 6),
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

class _PosterDetailHeader extends StatelessWidget {
  const _PosterDetailHeader({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final int? number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xff087f83),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            if (number != null)
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(
                  number.toString(),
                  style: const TextStyle(color: Color(0xff087f83), fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
            if (number != null) const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xffdff7f2), fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 30),
          ],
        ),
      );
}

class _DetailStepCard extends StatelessWidget {
  const _DetailStepCard({
    required this.number,
    required this.step,
    required this.emphasizeCpr,
  });

  final int number;
  final FirstAidStep step;
  final bool emphasizeCpr;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xffd3e6e3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 33,
              height: 33,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xff087f83), shape: BoxShape.circle),
              child: Text(
                number.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aidText(context, step.textKey),
                    style: const TextStyle(fontSize: 14.2, height: 1.28, fontWeight: FontWeight.w700),
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
            const SizedBox(width: 8),
            SizedBox(
              width: 112,
              height: 96,
              child: SvgPicture.asset(step.illustrationAsset, fit: BoxFit.contain),
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
                          height: 330,
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
                      label: Text(en ? 'Previous' : 'Précédent'),
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
                    label: Text(emergencyNumber),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: index == widget.guide.steps.length - 1 ? null : () => _go(index + 1),
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
