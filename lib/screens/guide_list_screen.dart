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
    final en = Localizations.localeOf(context).languageCode == 'en';
    final isDisaster = kind == GuideKind.disasters;
    final rawGuides = isDisaster ? disasterGuides : emergencyGuides;
    final guides = rawGuides.map((guide) => _localizedGuide(guide, en)).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(isDisaster ? t.get('disasters') : t.get('emergencies')),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1050
              ? 4
              : width >= 760
                  ? 3
                  : width >= 520
                      ? 2
                      : 1;
          final horizontal = width >= 760 ? 22.0 : 12.0;

          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 28),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: isDisaster
                          ? const Color(0xffd16a32)
                          : const Color(0xff087f83),
                      child: Icon(
                        isDisaster
                            ? Icons.thunderstorm_rounded
                            : Icons.shield_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDisaster
                                ? (en ? 'Risks & disasters' : 'Risques & catastrophes')
                                : (en ? 'Survival actions' : 'Réflexes de survie'),
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isDisaster
                                ? (en
                                    ? 'Short guides for what to do before, during and after a major event.'
                                    : 'Des fiches courtes pour savoir quoi faire avant, pendant et après une situation majeure.')
                                : (en
                                    ? 'Simple actions designed to remain useful when time and attention are limited.'
                                    : 'Des actions simples pour réagir sans chercher l’information au mauvais moment.'),
                            style: const TextStyle(
                              color: Color(0xff65747a),
                              height: 1.32,
                            ),
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
                  mainAxisExtent: columns == 1 ? 112 : 170,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                ),
                itemBuilder: (context, index) {
                  final guide = guides[index];
                  return _GuideCard(
                    guide: guide,
                    color: isDisaster
                        ? const Color(0xffd16a32)
                        : const Color(0xff087f83),
                    compact: columns == 1,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.campaign_outlined,
                      color: Color(0xff087f83),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        en
                            ? 'During a real event, local authorities and emergency services always take priority over general in-app guidance.'
                            : 'En cas d’événement réel, les instructions des autorités locales et des services d’urgence priment toujours sur les conseils généraux de l’application.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
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
  const _GuideCard({
    required this.guide,
    required this.color,
    required this.compact,
  });

  final Guide guide;
  final Color color;
  final bool compact;

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
            child: compact
                ? Row(
                    children: [
                      _iconBox(),
                      const SizedBox(width: 11),
                      Expanded(child: _text()),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xff87969a),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _iconBox(),
                      const Spacer(),
                      _text(),
                    ],
                  ),
          ),
        ),
      );

  Widget _iconBox() => Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(_iconFor(guide.icon), color: color),
      );

  Widget _text() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            guide.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            guide.immediate,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.2,
              color: Color(0xff65747a),
            ),
          ),
        ],
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
                      child: Icon(
                        _GuideCard._iconFor(guide.icon),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide.title,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            guide.immediate,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
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
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entry.$2,
                            style: const TextStyle(
                              height: 1.35,
                              fontWeight: FontWeight.w650,
                            ),
                          ),
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
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(text, style: const TextStyle(height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );
}

Guide _localizedGuide(Guide guide, bool en) {
  if (!en) return guide;

  final data = _englishGuides[guide.id];
  if (data == null) return guide;

  return Guide(
    id: guide.id,
    title: data.title,
    icon: guide.icon,
    immediate: data.immediate,
    avoid: data.avoid,
    steps: data.steps,
    callHelp: data.callHelp,
    evacuate: data.evacuate,
  );
}

class _GuideTranslation {
  const _GuideTranslation({
    required this.title,
    required this.immediate,
    required this.avoid,
    required this.steps,
    required this.callHelp,
    required this.evacuate,
  });

  final String title;
  final String immediate;
  final String avoid;
  final List<String> steps;
  final String callHelp;
  final String evacuate;
}

const _englishGuides = <String, _GuideTranslation>{
  'emergency': _GuideTranslation(
    title: 'General emergency',
    immediate: 'Move to safety, stay calm and assess the immediate danger.',
    avoid: 'Do not expose yourself to danger to retrieve belongings.',
    steps: [
      'Move away from the immediate danger.',
      'Alert emergency services when a life is threatened.',
      'Inform a trusted person when it is safe to do so.',
    ],
    callHelp: 'Call emergency services for life-threatening danger, fire or serious injury.',
    evacuate: 'Evacuate when authorities instruct you to leave or the location becomes unsafe.',
  ),
  'evacuation': _GuideTranslation(
    title: 'Evacuation',
    immediate: 'Leave without delay when instructed and take only what is immediately accessible.',
    avoid: 'Do not wait unnecessarily or return to an evacuated area.',
    steps: [
      'Follow official instructions and marked routes.',
      'Shut off utilities only when instructed and when it can be done safely.',
      'Go to the planned meeting point or designated reception area.',
    ],
    callHelp: 'Report injured, missing or vulnerable people when necessary.',
    evacuate: 'Leave immediately when an evacuation order is issued.',
  ),
  'blackout': _GuideTranslation(
    title: 'Power outage',
    immediate: 'Use safe lighting and preserve phone battery.',
    avoid: 'Never use a generator, charcoal grill or outdoor fuel-burning appliance indoors.',
    steps: [
      'Disconnect sensitive equipment when appropriate.',
      'Keep refrigerator and freezer doors closed.',
      'Follow official local information and utility updates.',
    ],
    callHelp: 'Call for fallen power lines, fire, suspected carbon monoxide or a medical emergency.',
    evacuate: 'Leave if authorities instruct you to or the home becomes unsafe.',
  ),
  'fire': _GuideTranslation(
    title: 'Fire',
    immediate: 'Get out immediately and stay outside.',
    avoid: 'Never re-enter a burning building.',
    steps: [
      'Alert other occupants while leaving if you can do so safely.',
      'Use the safest available exit.',
      'Call the fire service from a safe location outside.',
    ],
    callHelp: 'Call the fire service once you are in a safe place.',
    evacuate: 'Evacuate immediately for smoke, fire or a fire alarm.',
  ),
  'flood': _GuideTranslation(
    title: 'Flood',
    immediate: 'Move to a safer higher location and avoid moving water.',
    avoid: 'Do not walk or drive through floodwater when depth, current or road condition is uncertain.',
    steps: [
      'Follow official alerts and evacuation instructions.',
      'Avoid basements, underpasses and low-lying areas that can fill quickly.',
      'Take the emergency kit only if it is immediately accessible.',
    ],
    callHelp: 'Call when someone is trapped, swept away or in immediate danger.',
    evacuate: 'Leave when ordered or when rising water threatens the location.',
  ),
  'storm': _GuideTranslation(
    title: 'Severe storm',
    immediate: 'Shelter in a sturdy place away from windows.',
    avoid: 'Avoid trees, exposed structures and fallen power lines.',
    steps: [
      'Charge essential devices before conditions worsen when possible.',
      'Secure outdoor objects before the storm if it is safe.',
      'Monitor official weather warnings.',
    ],
    callHelp: 'Call for immediate danger, serious injury or life-threatening damage.',
    evacuate: 'Evacuate when authorities instruct you to leave.',
  ),
  'earthquake': _GuideTranslation(
    title: 'Earthquake',
    immediate: 'Drop, cover and hold on.',
    avoid: 'Do not run outside while strong shaking is occurring.',
    steps: [
      'Protect your head and neck.',
      'After shaking stops, move carefully and watch for damage.',
      'Expect aftershocks and follow official information.',
    ],
    callHelp: 'Call for serious injury, fire, collapse or another immediate danger.',
    evacuate: 'Leave after shaking if the building is damaged or authorities instruct evacuation.',
  ),
  'heat': _GuideTranslation(
    title: 'Extreme heat',
    immediate: 'Hydrate and move to a cooler environment.',
    avoid: 'Never leave a child, dependent person or animal in a parked vehicle.',
    steps: [
      'Drink regularly and use a cooler location when possible.',
      'Reduce strenuous activity during the hottest period.',
      'Check on vulnerable household members and neighbours.',
    ],
    callHelp: 'Call for confusion, collapse, seizures or other signs of severe heat illness.',
    evacuate: 'Move to a cooler safe location if the home becomes dangerously hot.',
  ),
  'cold': _GuideTranslation(
    title: 'Extreme cold',
    immediate: 'Keep warm, dry and protected from prolonged exposure.',
    avoid: 'Do not use unsafe fuel-burning heaters or improvised indoor combustion.',
    steps: [
      'Wear several dry insulating layers.',
      'Protect exposed skin and limit time outdoors.',
      'Check vulnerable people and maintain safe indoor heating.',
    ],
    callHelp: 'Call for suspected hypothermia, frostbite with severe symptoms or carbon-monoxide exposure.',
    evacuate: 'Move to a safer warm location if heating fails or the building becomes unsafe.',
  ),
  'water': _GuideTranslation(
    title: 'Water outage',
    immediate: 'Protect the safe drinking water you still have.',
    avoid: 'Do not drink water declared unsafe or water from an uncertain source without appropriate treatment.',
    steps: [
      'Use stored safe water first.',
      'Follow official drinking-water and sanitation instructions.',
      'Keep clean containers ready for safe water collection or distribution.',
    ],
    callHelp: 'Seek assistance when an essential medical need depends on water access.',
    evacuate: 'Leave only when instructed or when the location is otherwise unsafe.',
  ),
  'shelter': _GuideTranslation(
    title: 'Shelter in place',
    immediate: 'Go indoors and follow the exact shelter instructions issued for the incident.',
    avoid: 'Do not go outside to observe the event.',
    steps: [
      'Monitor official information.',
      'Keep safe water, communication and essential medicines available.',
      'Message a trusted contact when it is safe and useful.',
    ],
    callHelp: 'Call emergency services only for an actual emergency.',
    evacuate: 'Leave the shelter only when authorities instruct you to do so or there is a greater immediate danger.',
  ),
  'wildfire': _GuideTranslation(
    title: 'Wildfire',
    immediate: 'Move away from the fire and be ready to evacuate early.',
    avoid: 'Do not drive through heavy smoke, active fire or closed roads.',
    steps: [
      'Follow evacuation warnings and local instructions.',
      'Close openings only when this does not delay evacuation.',
      'Take people, medicines, pets and the ready emergency kit when ordered to leave.',
    ],
    callHelp: 'Report a new fire or a person in immediate danger according to local procedures.',
    evacuate: 'Evacuate immediately when ordered or when your safety is threatened.',
  ),
  'landslide': _GuideTranslation(
    title: 'Landslide',
    immediate: 'Move away from unstable slopes and the likely path of debris.',
    avoid: 'Do not return to the affected slope or debris area before it is considered safe.',
    steps: [
      'Follow official local instructions.',
      'Avoid gullies, unstable slopes and already damaged ground.',
      'Use an alternative route around the affected area.',
    ],
    callHelp: 'Call when someone is trapped, injured or a structure is at immediate risk of collapse.',
    evacuate: 'Leave the area when an evacuation is ordered or ground movement threatens you.',
  ),
  'industrial': _GuideTranslation(
    title: 'Industrial / chemical incident',
    immediate: 'Move away or shelter according to the specific official instructions for the release.',
    avoid: 'Do not approach an unknown cloud, leak, spill or substance.',
    steps: [
      'Check official alerts and identify whether evacuation or sheltering is advised.',
      'Close doors and windows when sheltering is ordered.',
      'Use only the routes and destinations recommended by authorities.',
    ],
    callHelp: 'Call emergency services for exposure, injury or immediate danger.',
    evacuate: 'Follow the official evacuation route and timing for the incident.',
  ),
  'radiological': _GuideTranslation(
    title: 'Radiological incident',
    immediate: 'Get inside a suitable building and follow official protective instructions.',
    avoid: 'Do not leave shelter to observe the event or retrieve non-essential belongings.',
    steps: [
      'Stay informed through official channels.',
      'Reduce time outdoors and unnecessary exposure.',
      'Follow instructions on ventilation, evacuation, food, water or protective measures.',
    ],
    callHelp: 'Call for a medical emergency or another immediate life-threatening danger.',
    evacuate: 'Evacuate only according to official instructions unless a greater immediate danger requires leaving.',
  ),
  'outbreak': _GuideTranslation(
    title: 'Health outbreak',
    immediate: 'Follow current public-health guidance and protect vulnerable people.',
    avoid: 'Do not rely on unverified medical advice that conflicts with current official guidance.',
    steps: [
      'Keep healthcare contacts and essential treatment information available.',
      'Maintain necessary medicines and household essentials.',
      'Adapt contact, travel and isolation behaviour to the current official recommendations.',
    ],
    callHelp: 'Contact health or emergency services for severe symptoms or when specifically instructed.',
    evacuate: 'Follow official movement, evacuation or isolation instructions for the event.',
  ),
};
