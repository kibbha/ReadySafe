import 'package:flutter/material.dart';

import 'first_aid_screen.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final drills = [
      _Drill(
        en ? 'Fire evacuation' : 'Évacuation incendie',
        en ? 'Check exits, meeting point and household roles.' : 'Vérifier les sorties, le point de rassemblement et les rôles.',
        Icons.local_fire_department_outlined,
        [
          en ? 'Identify two possible exits.' : 'Identifier deux sorties possibles.',
          en ? 'Confirm the outside meeting point.' : 'Confirmer le point de rassemblement extérieur.',
          en ? 'Check that everyone knows not to go back inside.' : 'Vérifier que chacun sait qu’il ne faut pas retourner à l’intérieur.',
        ],
      ),
      _Drill(
        en ? 'Power outage' : 'Coupure électrique',
        en ? 'Practise finding light, power and information offline.' : 'S’entraîner à retrouver éclairage, énergie et informations hors ligne.',
        Icons.power_off_outlined,
        [
          en ? 'Locate torches without using mains lighting.' : 'Retrouver les lampes sans utiliser l’éclairage du logement.',
          en ? 'Check the power bank charge.' : 'Vérifier la charge de la batterie externe.',
          en ? 'Confirm where the emergency kit is stored.' : 'Confirmer où se trouve le kit d’urgence.',
        ],
      ),
      _Drill(
        en ? 'Family contact plan' : 'Plan de contact familial',
        en ? 'Make sure everyone knows who to call and where to meet.' : 'Vérifier qui appeler et où se retrouver.',
        Icons.groups_outlined,
        [
          en ? 'Confirm the primary contact.' : 'Confirmer le contact principal.',
          en ? 'Confirm the meeting point.' : 'Confirmer le point de rassemblement.',
          en ? 'Review what to do if mobile data is unavailable.' : 'Revoir quoi faire si les données mobiles sont indisponibles.',
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(en ? 'Training & drills' : 'Entraînement & exercices')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffe2f2ef), Color(0xfffff3df)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.school_outlined, color: Color(0xff087f83), size: 32),
                const SizedBox(height: 10),
                Text(
                  en ? 'Practise before you need it' : 'S’entraîner avant d’en avoir besoin',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  en
                      ? 'Short household drills help make emergency plans easier to use under stress.'
                      : 'De courts exercices familiaux rendent les plans d’urgence plus faciles à appliquer sous stress.',
                  style: const TextStyle(color: Color(0xff5f7074), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...drills.map((drill) => _DrillCard(drill: drill)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              minTileHeight: 70,
              leading: const CircleAvatar(
                backgroundColor: Color(0xffffe7e8),
                child: Icon(Icons.health_and_safety_outlined, color: Color(0xffc92d36)),
              ),
              title: Text(
                en ? 'Review first-aid guides' : 'Réviser les fiches de premiers secours',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                en
                    ? 'Use the validated offline guides for revision.'
                    : 'Utiliser les guides hors ligne validés pour réviser.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FirstAidScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            en
                ? 'These exercises support preparedness and do not replace certified first-aid or emergency training.'
                : 'Ces exercices complètent la préparation et ne remplacent pas une formation certifiée aux premiers secours ou à l’urgence.',
            style: const TextStyle(fontSize: 12, color: Color(0xff6b797d), height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Drill {
  const _Drill(this.title, this.subtitle, this.icon, this.steps);
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> steps;
}

class _DrillCard extends StatelessWidget {
  const _DrillCard({required this.drill});
  final _Drill drill;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xffe4f2f0),
            child: Icon(drill.icon, color: const Color(0xff087f83)),
          ),
          title: Text(drill.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(drill.subtitle),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            for (var i = 0; i < drill.steps.length; i++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 13,
                  backgroundColor: const Color(0xff087f83),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
                title: Text(drill.steps[i]),
              ),
          ],
        ),
      );
}
