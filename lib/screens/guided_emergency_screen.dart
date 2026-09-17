import 'package:flutter/material.dart';

import '../app/localizations.dart';
import '../data/first_aid_repository.dart';
import '../models/first_aid_guide.dart';
import 'emergency_screen.dart';
import 'first_aid_screen.dart';

class GuidedEmergencyScreen extends StatelessWidget {
  const GuidedEmergencyScreen({super.key});

  FirstAidGuide _guide(String id) =>
      firstAidGuides.firstWhere((guide) => guide.id == id);

  void _openGuide(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FirstAidDetailScreen(guide: _guide(id)),
      ),
    );
  }

  Future<void> _openPaediatricChoices(BuildContext context) async {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final id = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                en ? 'Child or infant emergency' : 'Urgence enfant ou nourrisson',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                en
                    ? 'Choose the situation you can identify. If you are unsure, open emergency numbers and follow the operator’s instructions.'
                    : 'Choisissez la situation que vous identifiez. En cas de doute, ouvrez les numéros d’urgence et suivez les instructions de l’opérateur.',
                style: const TextStyle(color: Color(0xff607075), height: 1.35),
              ),
              const SizedBox(height: 14),
              _ChoiceButton(
                icon: Icons.favorite_rounded,
                label: en ? 'Child CPR' : 'RCP enfant',
                onTap: () => Navigator.pop(sheetContext, 'cpr_child'),
              ),
              _ChoiceButton(
                icon: Icons.child_care_rounded,
                label: en ? 'Infant CPR' : 'RCP nourrisson',
                onTap: () => Navigator.pop(sheetContext, 'cpr_infant'),
              ),
              _ChoiceButton(
                icon: Icons.air_rounded,
                label: en ? 'Child choking' : 'Étouffement enfant',
                onTap: () => Navigator.pop(sheetContext, 'choking_child'),
              ),
              _ChoiceButton(
                icon: Icons.baby_changing_station_rounded,
                label: en ? 'Infant choking' : 'Étouffement nourrisson',
                onTap: () => Navigator.pop(sheetContext, 'choking_infant'),
              ),
            ],
          ),
        ),
      ),
    );
    if (id != null && context.mounted) _openGuide(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final t = AppLocalizations.of(context);

    final situations = <_Situation>[
      _Situation(
        en ? 'Not responding' : 'Ne répond pas',
        en ? 'Unconscious or difficult to wake' : 'Inconscient ou difficile à réveiller',
        Icons.person_off_rounded,
        'unconscious',
      ),
      _Situation(
        en ? 'Not breathing normally' : 'Ne respire pas normalement',
        en ? 'Open CPR guidance immediately' : 'Ouvrir immédiatement le guidage RCP',
        Icons.favorite_rounded,
        'cpr_adult',
      ),
      _Situation(
        en ? 'Choking' : 'S’étouffe',
        en ? 'Cannot speak, cough or breathe' : 'Ne peut plus parler, tousser ou respirer',
        Icons.air_rounded,
        'choking_adult',
      ),
      _Situation(
        en ? 'Heavy bleeding' : 'Saigne beaucoup',
        en ? 'Severe or uncontrolled bleeding' : 'Hémorragie importante ou incontrôlée',
        Icons.bloodtype_rounded,
        'bleeding',
      ),
      _Situation(
        en ? 'Severe allergy' : 'Allergie grave',
        en ? 'Breathing difficulty, swelling or collapse' : 'Difficulté respiratoire, gonflement ou malaise',
        Icons.medication_liquid_rounded,
        'anaphylaxis',
      ),
      _Situation(
        en ? 'Burn' : 'Brûlure',
        en ? 'Thermal, chemical or electrical' : 'Thermique, chimique ou électrique',
        Icons.local_fire_department_rounded,
        'burn',
      ),
      _Situation(
        en ? 'Drowning' : 'Noyade',
        en ? 'Person in difficulty or rescued from water' : 'Personne en difficulté ou sortie de l’eau',
        Icons.water_rounded,
        'drowning',
      ),
      _Situation(
        en ? 'Seizure' : 'Convulsions',
        en ? 'Convulsive episode or uncontrolled movements' : 'Crise convulsive ou mouvements incontrôlés',
        Icons.monitor_heart_rounded,
        'seizure',
      ),
      _Situation(
        en ? 'Accident / fall' : 'Accident / chute',
        en ? 'Trauma, fracture or serious fall' : 'Traumatisme, fracture ou chute importante',
        Icons.personal_injury_rounded,
        'trauma',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(en ? 'Emergency — guide me' : 'Urgence — guidez-moi'),
        actions: [
          IconButton(
            tooltip: t.get('emergencies'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmergencyScreen()),
            ),
            icon: const Icon(Icons.phone_in_talk_rounded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final horizontal = wide ? 28.0 : 16.0;
          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xffffeded),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xffffcfd2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.sos_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          en ? 'What is happening?' : 'Que se passe-t-il ?',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(
                      en
                          ? 'Choose the closest situation. For immediate danger or uncertainty, contact emergency services first.'
                          : 'Choisissez la situation la plus proche. En cas de danger immédiat ou de doute, contactez d’abord les secours.',
                      style: const TextStyle(color: Color(0xff5f686b), height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                        ),
                        icon: const Icon(Icons.call_rounded),
                        label: Text(
                          en ? 'Emergency numbers' : 'Numéros d’urgence',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                en ? 'Choose a situation' : 'Choisissez une situation',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: situations.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: wide ? 3 : 2,
                  childAspectRatio: wide ? 1.35 : 1.02,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  if (index == situations.length) {
                    return _SituationCard(
                      title: en ? 'Child / infant' : 'Enfant / bébé',
                      subtitle: en ? 'Paediatric emergency guidance' : 'Guidage pédiatrique',
                      icon: Icons.child_friendly_rounded,
                      onTap: () => _openPaediatricChoices(context),
                    );
                  }
                  final item = situations[index];
                  return _SituationCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    onTap: () => _openGuide(context, item.guideId),
                  );
                },
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffeef6f5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.offline_bolt_rounded, color: Color(0xff087f83)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        en
                            ? 'Essential guidance is stored on the device and remains available without a network connection.'
                            : 'Les guides essentiels sont stockés sur l’appareil et restent disponibles sans connexion réseau.',
                        style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
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

class _Situation {
  const _Situation(this.title, this.subtitle, this.icon, this.guideId);
  final String title;
  final String subtitle;
  final IconData icon;
  final String guideId;
}

class _SituationCard extends StatelessWidget {
  const _SituationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xffdde7e5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xffe5f3f1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xff087f83)),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, height: 1.08),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xff65747a), height: 1.2),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Align(alignment: Alignment.centerLeft, child: Text(label)),
        ),
      );
}
