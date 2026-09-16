import 'package:flutter/material.dart';

import '../app/localizations.dart';
import '../data/content.dart';
import '../models/guide.dart';

enum GuideKind { emergencies, disasters, firstAid }

class GuideListScreen extends StatelessWidget {
  const GuideListScreen({super.key, required this.kind});
  final GuideKind kind;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (kind == GuideKind.firstAid) return _firstAid(context, t);
    final guides = kind == GuideKind.disasters
        ? disasterGuides
        : emergencyGuides;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kind == GuideKind.disasters
              ? t.get('disasters')
              : t.get('emergencies'),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: guides.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded),
            title: Text(guides[i].title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GuideDetail(guide: guides[i])),
            ),
          ),
        ),
      ),
    );
  }

  Widget _firstAid(BuildContext context, AppLocalizations t) => Scaffold(
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
        const SizedBox(height: 10),
        ...firstAid.map(
          (name) => Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: Text(name),
              subtitle: const Text(
                'Évaluer, protéger, alerter et suivre les consignes des secours.',
              ),
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(name),
                  content: Text(
                    '${t.get('medicalNotice')}\n\nEn cas de danger vital, appelez les secours. Ne donnez pas de médicament ni de nourriture à une personne inconsciente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class GuideDetail extends StatelessWidget {
  const GuideDetail({super.key, required this.guide});
  final Guide guide;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(guide.title)),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _Block('À faire immédiatement', guide.immediate, Icons.flash_on),
        _Block('À éviter', guide.avoid, Icons.block),
        const SizedBox(height: 12),
        Text(
          'Étapes',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        ...guide.steps.indexed.map(
          (entry) => ListTile(
            leading: CircleAvatar(child: Text('${entry.$1 + 1}')),
            title: Text(entry.$2),
          ),
        ),
        _Block(
          'Quand appeler les secours',
          guide.callHelp,
          Icons.phone_in_talk,
        ),
        _Block('Quand évacuer', guide.evacuate, Icons.directions_run),
      ],
    ),
  );
}

class _Block extends StatelessWidget {
  const _Block(this.title, this.text, this.icon);
  final String title, text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    ),
  );
}
