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
    final isDisaster = kind == GuideKind.disasters;
    final guides = isDisaster ? disasterGuides : emergencyGuides;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(isDisaster ? t.get('disasters') : t.get('emergencies')),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final columns = wide ? 3 : 2;
          return ListView(
            padding: EdgeInsets.fromLTRB(wide ? 22 : 12, 4, wide ? 22 : 12, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDisaster
                        ? const [Color(0xffffeee5), Color(0xfffff7e7)]
                        : const [Color(0xffe5f4f1), Color(0xfffff5e8)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: isDisaster ? const Color(0xffd16a32) : const Color(0xff087f83),
                      child: Icon(
                        isDisaster ? Icons.thunderstorm_rounded : Icons.shield_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDisaster ? 'Risques & catastrophes' : 'Réflexes de survie',
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isDisaster
                                ? 'Des fiches courtes pour savoir quoi faire avant, pendant et après une situation majeure.'
                                : 'Des actions simples pour réagir sans chercher l’information au mauvais moment.',
                            style: const TextStyle(color: Color(0xff65747a), height: 1.32),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: guides.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: wide ? 170 : 158,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                ),
                itemBuilder: (context, index) {
                  final guide = guides[index];
                  return _GuideCard(
                    guide: guide,
                    color: isDisaster ? const Color(0xffd16a32) : const Color(0xff087f83),
                  );
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xffeaf6f4),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.campaign_outlined, color: Color(0xff087f83)),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'En cas d’événement réel, les instructions des autorités locales et des services d’urgence priment toujours sur les conseils généraux de l’application.',
                        style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
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
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide, required this.color});
  final Guide guide;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GuideDetail(guide: guide)),
          ),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xffdce7e7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_iconFor(guide.icon), color: color),
                ),
                const Spacer(),
                Text(
                  guide.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, height: 1.08),
                ),
                const SizedBox(height: 4),
                Text(
                  guide.immediate,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, height: 1.2, color: Color(0xff65747a)),
                ),
              ],
            ),
          ),
        ),
      );

  static IconData _iconFor(String name) {
    switch (name) {
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'water':
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'landscape':
      case 'terrain':
        return Icons.terrain_rounded;
      case 'wb_sunny':
        return Icons.wb_sunny_rounded;
      case 'ac_unit':
        return Icons.ac_unit_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'forest':
        return Icons.forest_rounded;
      case 'factory':
        return Icons.factory_rounded;
      case 'power_off':
        return Icons.power_off_rounded;
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'coronavirus':
        return Icons.coronavirus_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }
}

class GuideDetail extends StatelessWidget {
  const GuideDetail({super.key, required this.guide});
  final Guide guide;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(guide.title)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffe4f3f0), Color(0xfffff4e8)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xff087f83),
                      child: Icon(_GuideCard._iconFor(guide.icon), color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guide.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(
                            guide.immediate,
                            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _Block(
                t.get('do_now'),
                guide.immediate,
                Icons.flash_on_rounded,
                const Color(0xff087f83),
              ),
              _Block(
                t.get('avoid'),
                guide.avoid,
                Icons.block_rounded,
                const Color(0xffd92d36),
              ),
              const SizedBox(height: 6),
              Text(
                t.get('steps'),
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              ...guide.steps.indexed.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffdbe6e7)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xff087f83),
                        child: Text(
                          '${entry.$1 + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(entry.$2, style: const TextStyle(height: 1.35, fontWeight: FontWeight.w650)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _Block(
                t.get('when_call'),
                guide.callHelp,
                Icons.phone_in_talk_rounded,
                const Color(0xffd92d36),
              ),
              _Block(
                t.get('when_evacuate'),
                guide.evacuate,
                Icons.directions_run_rounded,
                const Color(0xffd16a32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block(this.title, this.text, this.icon, this.color);
  final String title;
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffdbe6e7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
                  const SizedBox(height: 4),
                  Text(text, style: const TextStyle(height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );
}
