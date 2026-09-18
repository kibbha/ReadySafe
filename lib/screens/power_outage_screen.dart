import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';
import 'carbon_monoxide_screen.dart';
import 'emergency_food_safety_screen.dart';

class PowerOutageScreen extends StatefulWidget {
  const PowerOutageScreen({super.key});

  @override
  State<PowerOutageScreen> createState() => _PowerOutageScreenState();
}

class _PowerOutageScreenState extends State<PowerOutageScreen> {
  final _storage = LocalStorageService();
  Set<String> _done = {};
  bool _loading = true;

  static const _checks = <_PowerCheck>[
    _PowerCheck(
      'lights',
      'Lampes prêtes',
      'Lampes et piles facilement accessibles.',
      Icons.flashlight_on_rounded,
    ),
    _PowerCheck(
      'battery',
      'Batteries externes chargées',
      'Téléphones et appareils essentiels disposent d’une solution de recharge.',
      Icons.battery_charging_full_rounded,
    ),
    _PowerCheck(
      'radio',
      'Radio autonome',
      'Une radio à piles ou à manivelle est utilisable.',
      Icons.radio_rounded,
    ),
    _PowerCheck(
      'medical',
      'Besoins électriques identifiés',
      'Les appareils indispensables et leurs solutions de secours sont connus.',
      Icons.medical_services_outlined,
    ),
    _PowerCheck(
      'cooling',
      'Plan chaleur / froid',
      'Un lieu alternatif est identifié si le logement devient trop chaud ou trop froid.',
      Icons.thermostat_rounded,
    ),
    _PowerCheck(
      'fridge',
      'Thermomètre réfrigérateur / congélateur',
      'Permet d’évaluer la sécurité des aliments après une coupure.',
      Icons.kitchen_rounded,
    ),
    _PowerCheck(
      'contacts',
      'Réseau de soutien',
      'Une personne peut être contactée si la panne se prolonge.',
      Icons.groups_rounded,
    ),
    _PowerCheck(
      'cash',
      'Moyen de paiement de secours',
      'Un peu de liquide est disponible si les paiements électroniques sont perturbés.',
      Icons.payments_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = await _storage.completed('power_outage_v3');
    if (!mounted) return;
    setState(() {
      _done = done;
      _loading = false;
    });
  }

  Future<void> _toggle(String id, bool value) async {
    setState(() {
      value ? _done.add(id) : _done.remove(id);
    });
    await _storage.toggle('power_outage_v3', id, value);
  }

  Future<void> _openSource() async {
    final uri = Uri.parse(
      'https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/power-outage.html',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _checks.isEmpty ? 0.0 : _done.length / _checks.length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: const Text('Panne électrique')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xfffff3df), Color(0xffe8f4f2)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xffb7833f),
                            child: Icon(Icons.power_off_rounded, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Préparer la continuité sans électricité',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white,
                          color: const Color(0xffb7833f),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_done.length} / ${_checks.length} points préparés',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const _ActionBlock(
                  icon: Icons.bolt_rounded,
                  title: 'Pendant la panne',
                  color: Color(0xff087f83),
                  lines: [
                    'Suivez les alertes officielles et gardez une radio disponible.',
                    'Contactez votre réseau de soutien si la panne se prolonge.',
                    'Utilisez des lampes plutôt que des bougies.',
                    'Débranchez les appareils sensibles si nécessaire pour limiter les dommages au retour du courant.',
                    'Quittez le logement si la température devient dangereuse ou si un équipement essentiel ne peut plus fonctionner.',
                  ],
                ),
                const _ActionBlock(
                  icon: Icons.kitchen_rounded,
                  title: 'Réfrigérateur & congélateur',
                  color: Color(0xff237fc7),
                  lines: [
                    'Évitez d’ouvrir les portes inutilement.',
                    'Repère général Red Cross : un réfrigérateur fermé garde les aliments froids environ 4 h.',
                    'Un congélateur plein fermé tient environ 48 h ; environ 24 h s’il est à moitié plein.',
                    'Utilisez un thermomètre et suivez les recommandations alimentaires locales si la coupure dure.',
                  ],
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xfffff2df),
                      child: Icon(Icons.restaurant_rounded, color: Color(0xffb7833f)),
                    ),
                    title: const Text(
                      'Sécurité des aliments',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: const Text(
                      'Décider quoi conserver ou jeter après une panne ou une inondation.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyFoodSafetyScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xffffe7e8),
                      child: Icon(Icons.warning_amber_rounded, color: Color(0xffd92d36)),
                    ),
                    title: const Text(
                      'Monoxyde de carbone',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: const Text(
                      'Groupes électrogènes, appareils à combustion, détecteurs et suspicion d’intoxication.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CarbonMonoxideScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Checklist de préparation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                ..._checks.map((item) {
                  final checked = _done.contains(item.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: checked,
                      onChanged: (value) => _toggle(item.id, value ?? false),
                      secondary: CircleAvatar(
                        backgroundColor: checked
                            ? const Color(0xffdff2ed)
                            : const Color(0xfffff2df),
                        child: Icon(
                          item.icon,
                          color: checked
                              ? const Color(0xff087f83)
                              : const Color(0xffb7833f),
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(item.subtitle),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _openSource,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Source : American Red Cross'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Les règles locales, les consignes du fournisseur d’électricité et les instructions des autorités priment toujours.',
                  style: TextStyle(fontSize: 12, color: Color(0xff65747a), height: 1.35),
                ),
              ],
            ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({
    required this.icon,
    required this.title,
    required this.color,
    required this.lines,
  });

  final IconData icon;
  final String title;
  final Color color;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: .12),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 18, color: color),
                      const SizedBox(width: 7),
                      Expanded(child: Text(line, style: const TextStyle(height: 1.32))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
}

class _PowerCheck {
  const _PowerCheck(this.id, this.title, this.subtitle, this.icon);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
