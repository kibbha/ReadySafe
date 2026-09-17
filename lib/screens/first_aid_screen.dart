import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/localizations.dart';
import '../app/app_scope.dart';
import 'emergency_screen.dart';
import '../data/first_aid_repository.dart';
import '../models/first_aid_guide.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.get('firstAid'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t.get('medicalNotice')),
            ),
          ),
          const SizedBox(height: 12),
          ...firstAidGuides.map(
            (guide) => Card(
              child: ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: Text(t.get(guide.titleKey)),
                subtitle: Text(t.get(guide.summaryKey)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FirstAidDetailScreen(guide: guide),
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
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.get(guide.titleKey))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // A mobile version of a first-aid teaching sheet: prominent title,
          // immediate action, then numbered illustrated instructions.
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety, color: colors.onPrimary, size: 32),
                const SizedBox(height: 12),
                Text(
                  t.get(guide.titleKey),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimary, fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.get(guide.summaryKey),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: colors.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: colors.onErrorContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(t.get('aid_call_now'),
                      style: TextStyle(color: colors.onErrorContainer,
                        fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyScreen()),
            ),
            icon: const Icon(Icons.phone_in_talk),
            label: Text(
              '${t.get('emergencies')} · ${t.get(AppScope.of(context).activeCountry!.nameKey)}',
            ),
          ),
          const SizedBox(height: 20),
          ...guide.steps.indexed.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _StepCard(number: entry.$1 + 1, step: entry.$2),
            ),
          ),
          const SizedBox(height: 4),
          Text(t.get('medicalNotice'),
            style: Theme.of(context).textTheme.bodySmall),
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
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: colors.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFFE052),
                  child: Text('$number',
                    style: const TextStyle(color: Color(0xFF242424),
                      fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(t.get('step', {'number': '$number'}),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w800))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  image: true,
                  label: '${t.get('illustration_ready')}: ${t.get(step.textKey)}',
                  child: Container(
                    height: 164,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(step.illustrationAsset,
                      fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 14),
                Text(t.get(step.textKey),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.4, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
