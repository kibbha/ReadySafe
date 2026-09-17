import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../data/first_aid_repository.dart';
import '../models/first_aid_guide.dart';
import 'emergency_screen.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  IconData _icon(String id) {
    if (id.contains('cpr')) return Icons.favorite_outline;
    if (id.contains('choking')) return Icons.air;
    if (id.contains('bleeding')) return Icons.bloodtype_outlined;
    if (id.contains('burn')) return Icons.local_fire_department_outlined;
    if (id.contains('poison')) return Icons.science_outlined;
    if (id.contains('aed')) return Icons.monitor_heart_outlined;
    return Icons.health_and_safety_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.get('firstAid'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffffeeee),
              borderRadius: BorderRadius.circular(16),
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
          const SizedBox(height: 14),
          ...firstAidGuides.map(
            (g) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
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
                    fontWeight: FontWeight.w650,
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
