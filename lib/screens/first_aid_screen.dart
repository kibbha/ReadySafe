import 'package:flutter/material.dart';
import '../app/localizations.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(t.get(guide.titleKey))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t.get('aid_call_now')),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.get(guide.summaryKey),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...guide.steps.indexed.map(
            (entry) => _StepCard(number: entry.$1 + 1, step: entry.$2),
          ),
          const SizedBox(height: 12),
          Text(t.get('medicalNotice')),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get('step', {'number': '$number'}),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 92,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: step.illustrationAsset == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.draw_outlined),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            t.get('illustration_pending'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    )
                  : Image.asset(step.illustrationAsset!),
            ),
            const SizedBox(height: 12),
            Text(
              t.get(step.textKey),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
