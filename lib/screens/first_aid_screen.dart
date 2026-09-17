import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../data/first_aid_repository.dart';
import '../models/first_aid_guide.dart';
import 'emergency_screen.dart';

String _aidText(BuildContext context, String key) {
  final t = AppLocalizations.of(context);
  final en = Localizations.localeOf(context).languageCode == 'en';
  const fr = <String, String>{
    'first_aid_search': 'Rechercher un geste de secours',
    'first_aid_empty': 'Aucun geste correspondant',
    'first_aid_all': 'Tous',
    'first_aid_adult': 'Adulte',
    'first_aid_child': 'Enfant',
    'first_aid_infant': 'Nourrisson',
    'first_aid_header': 'Les bons gestes, au bon moment',
    'first_aid_header_body': 'Des instructions visuelles, simples et rapides à suivre.',
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
    'first_aid_search': 'Search first-aid guidance',
    'first_aid_empty': 'No matching first-aid guidance',
    'first_aid_all': 'All',
    'first_aid_adult': 'Adult',
    'first_aid_child': 'Child',
    'first_aid_infant': 'Infant',
    'first_aid_header': 'The right action, at the right time',
    'first_aid_header_body': 'Visual instructions designed to be quick and easy to follow.',
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final guides = firstAidGuides.where((g) {
      if (!_matchesAge(g.id)) return false;
      if (q.isEmpty) return true;
      return t.get(g.titleKey).toLowerCase().contains(q) || t.get(g.summaryKey).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t.get('firstAid'))),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        return ListView(
          padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 4, wide ? 28 : 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xffe9f7f4), Color(0xfff5fbf9)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(children: [
                Container(width: 58, height: 58, decoration: BoxDecoration(color: const Color(0xff087f83), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 32)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_aidText(context, 'first_aid_header'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(_aidText(context, 'first_aid_header_body'), style: const TextStyle(color: Color(0xff65747a), height: 1.3)),
                ])),
              ]),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(hintText: _aidText(context, 'first_aid_search'), prefixIcon: const Icon(Icons.search), isDense: true),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
              _filterChip('all', _aidText(context, 'first_aid_all')),
              _filterChip('adult', _aidText(context, 'first_aid_adult')),
              _filterChip('child', _aidText(context, 'first_aid_child')),
              _filterChip('infant', _aidText(context, 'first_aid_infant')),
            ])),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xffffeeee), borderRadius: BorderRadius.circular(15)),
              child: Row(children: [Icon(Icons.emergency_outlined, color: Theme.of(context).colorScheme.error), const SizedBox(width: 10), Expanded(child: Text(t.get('medicalNotice'), style: const TextStyle(fontWeight: FontWeight.w700)))]),
            ),
            const SizedBox(height: 12),
            if (guides.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(vertical: 36), child: Center(child: Text(_aidText(context, 'first_aid_empty'))))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: guides.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: wide ? 430 : 700, mainAxisExtent: 102, crossAxisSpacing: 12, mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  final g = guides[index];
                  return _GuideCard(guide: g, title: t.get(g.titleKey), summary: t.get(g.summaryKey), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FirstAidDetailScreen(guide: g))));
                },
              ),
          ],
        );
      }),
    );
  }

  Widget _filterChip(String value, String label) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(label), selected: _filter == value, showCheckmark: false, onSelected: (_) => setState(() => _filter = value)));
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide, required this.title, required this.summary, required this.onTap});
  final FirstAidGuide guide;
  final String title;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final illustration = guide.steps.isNotEmpty ? guide.steps.first.illustrationAsset : null;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), child: Row(children: [
        Container(width: 82, height: 76, padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: const Color(0xfff2f8f8), borderRadius: BorderRadius.circular(16)), child: illustration == null ? const Icon(Icons.health_and_safety_outlined, color: Color(0xff087f83)) : SvgPicture.asset(illustration, fit: BoxFit.contain)),
        const SizedBox(width: 12),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(height: 1.25, color: Color(0xff65747a)))])),
        const Icon(Icons.chevron_right, color: Color(0xff65747a)),
      ]))),
    );
  }
}

class FirstAidDetailScreen extends StatelessWidget {
  const FirstAidDetailScreen({super.key, required this.guide});
  final FirstAidGuide guide;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.get(guide.titleKey))),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        return ListView(padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 4, wide ? 28 : 16, 30), children: [
          Text(t.get(guide.summaryKey), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), decoration: BoxDecoration(color: const Color(0xffffeeee), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xffffcccc))), child: Row(children: [
            Icon(Icons.phone_in_talk, color: Theme.of(context).colorScheme.error), const SizedBox(width: 10), Expanded(child: Text(t.get('aid_call_now'), style: const TextStyle(fontWeight: FontWeight.w800))),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, minimumSize: const Size(72, 40)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())), child: Text(AppScope.of(context).activeCountry!.isoCode)),
          ])),
          const SizedBox(height: 14),
          ...guide.steps.indexed.map((e) => _StepCard(number: e.$1 + 1, step: e.$2, wide: wide)),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.verified_outlined, size: 18, color: Color(0xff087f83)), const SizedBox(width: 7), Expanded(child: Text(t.get('medicalNotice'), style: const TextStyle(fontSize: 12, color: Color(0xff65747a))))]),
        ]);
      }),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.step, required this.wide});
  final int number;
  final FirstAidStep step;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final image = Container(
      height: wide ? 210 : 170,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xfff2f8f8), borderRadius: BorderRadius.circular(18)),
      child: Semantics(image: true, label: t.get('illustration_ready'), child: SvgPicture.asset(step.illustrationAsset, fit: BoxFit.contain)),
    );
    final text = Text(_aidText(context, step.textKey), style: const TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w600));
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 30, height: 30, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xff087f83), shape: BoxShape.circle), child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), const SizedBox(width: 9), Text(t.get('step', {'number': '$number'}), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 12),
        if (wide) Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 5, child: image), const SizedBox(width: 20), Expanded(flex: 6, child: text)]) else ...[image, const SizedBox(height: 12), text],
      ])),
    );
  }
}
