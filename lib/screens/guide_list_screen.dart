import 'package:flutter/material.dart';

import '../app/localizations.dart';
import '../data/content.dart';
import '../models/guide.dart';

enum GuideKind { emergencies, disasters }

class GuideListScreen extends StatelessWidget {
  const GuideListScreen({super.key, required this.kind});
  final GuideKind kind;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
}

class GuideDetail extends StatelessWidget {
  const GuideDetail({super.key, required this.guide});
  final Guide guide;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(guide.title)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _Block(t.get('do_now'), guide.immediate, Icons.flash_on),
          _Block(t.get('avoid'), guide.avoid, Icons.block),
          const SizedBox(height: 12),
          Text(
            t.get('steps'),
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
          _Block(t.get('when_call'), guide.callHelp, Icons.phone_in_talk),
          _Block(t.get('when_evacuate'), guide.evacuate, Icons.directions_run),
        ],
      ),
    );
  }
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
