import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../data/first_aid_repository.dart';
import '../models/first_aid_guide.dart';
import 'emergency_screen.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  String _query = '';
  String _filter = 'all';

  IconData _icon(String id) {
    if (id.contains('cpr')) return Icons.favorite_outline;
    if (id.contains('choking')) return Icons.air;
    if (id.contains('bleeding')) return Icons.bloodtype_outlined;
    if (id.contains('burn')) return Icons.local_fire_department_outlined;
    if (id.contains('poison')) return Icons.science_outlined;
    if (id.contains('aed')) return Icons.monitor_heart_outlined;
    return Icons.health_and_safety_outlined;
  }

  bool _matchesAge(String id) {
    if (_filter == 'all') return true;
    if (_filter == 'child') return id.contains('child');
    if (_filter == 'infant') return id.contains('infant');
    if (_filter == 'adult') {
      return !id.contains('child') && !id.contains('infant');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final guides = firstAidGuides.where((g) {
      if (!_matchesAge(g.id)) return false;
      if (q.isEmpty) return true;
      final title = t.get(g.titleKey).toLowerCase();
      final summary = t.get(g.summaryKey).toLowerCase();
      return title.contains(q) || summary.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t.get('firstAid'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Rechercher un geste de secours',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', 'Tous'),
                _filterChip('adult', 'Adulte'),
                _filterChip('child', 'Enfant'),
                _filterChip('infant', 'Nourrisson'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffffeeee),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.emergency_outlined,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.get('medicalNotice'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (guides.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: Text('Aucun geste correspondant')),
            ),
          ...guides.map(
            (g) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xffe8f5f5),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(_icon(g.id), color: const Color(0xff087f83)),
                ),
                title: Text(
                  t.get(g.titleKey),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  t.get(g.summaryKey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FirstAidDetailScreen(guide: g),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        showCheckmark: false,
        onSelected: (_) => setState(() => _filter = value),
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
    return Scaffold(
      appBar: AppBar(title: Text(t.get(guide.titleKey))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
        children: [
          Text(
            t.get(guide.summaryKey),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xffffeeee),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xffffcccc)),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_in_talk,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.get('aid_call_now'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    minimumSize: const Size(72, 40),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                  ),
                  child: Text(AppScope.of(context).activeCountry!.isoCode),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...guide.steps.indexed.map(
            (e) => _StepCard(number: e.$1 + 1, step: e.$2),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_outlined,
                  size: 18, color: Color(0xff087f83)),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  t.get('medicalNotice'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff65747a),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.step});
  final int number;
  final FirstAidStep step;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 118,
              child: Column(
                children: [
                  Row(
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
                          '$number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          t.get('step', {'number': '$number'}),
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 108,
                    width: 118,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xfff2f8f8),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Semantics(
                      image: true,
                      label: t.get('illustration_ready'),
                      child: SvgPicture.asset(
                        step.illustrationAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  t.get(step.textKey),
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
