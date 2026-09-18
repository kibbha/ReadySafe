import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';
import 'special_kits_screen.dart';

class VehicleEmergencyScreen extends StatefulWidget {
  const VehicleEmergencyScreen({super.key});

  @override
  State<VehicleEmergencyScreen> createState() => _VehicleEmergencyScreenState();
}

class _VehicleEmergencyScreenState extends State<VehicleEmergencyScreen> {
  final _storage = LocalStorageService();
  Set<String> _done = {};
  bool _loading = true;

  static const _items = <_VehicleCheck>[
    _VehicleCheck(
      'phone',
      'Téléphone + chargeur voiture',
      'Le téléphone peut être rechargé pendant le trajet.',
      Icons.phone_android_rounded,
    ),
    _VehicleCheck(
      'warning',
      'Triangle / signalisation',
      'Le matériel obligatoire ou recommandé localement est accessible.',
      Icons.warning_amber_rounded,
    ),
    _VehicleCheck(
      'firstaid',
      'Trousse de premiers secours',
      'Trousse accessible et contenu vérifié.',
      Icons.medical_services_outlined,
    ),
    _VehicleCheck(
      'light',
      'Lampe',
      'Une lampe fonctionne sans dépendre du véhicule.',
      Icons.flashlight_on_rounded,
    ),
    _VehicleCheck(
      'water_food',
      'Eau & aliments',
      'Une petite réserve existe pour une immobilisation prolongée.',
      Icons.local_drink_outlined,
    ),
    _VehicleCheck(
      'warmth',
      'Protection météo',
      'Couverture, vêtements adaptés et protection pluie/froid.',
      Icons.ac_unit_rounded,
    ),
    _VehicleCheck(
      'maps',
      'Carte / itinéraire de secours',
      'Une solution existe si le réseau mobile ou la navigation tombe.',
      Icons.map_outlined,
    ),
    _VehicleCheck(
      'tools',
      'Matériel du véhicule',
      'Cric, roue/kit anti-crevaison, câbles et outils utiles vérifiés.',
      Icons.handyman_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = await _storage.completed('vehicle_emergency_v3');
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
    await _storage.toggle('vehicle_emergency_v3', id, value);
  }

  Future<void> _openReadySource() async {
    final uri = Uri.parse('https://www.ready.gov/car');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openNhtsaSource() async {
    final uri = Uri.parse('https://www.nhtsa.gov/summer-driving-tips');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final progress = _items.isEmpty ? 0.0 : _done.length / _items.length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Vehicle emergency' : 'Urgence véhicule'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xfffff3df), Color(0xffe4f3f0)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xffb7833f),
                            child: Icon(Icons.directions_car_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              en
                                  ? 'Be ready for breakdowns, severe weather and blocked roads'
                                  : 'Être prêt pour panne, météo sévère ou route bloquée',
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
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
                        en
                            ? '${_done.length} / ${_items.length} vehicle items ready'
                            : '${_done.length} / ${_items.length} points véhicule prêts',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _VehicleCard(
                  icon: Icons.car_crash_outlined,
                  color: const Color(0xffd92d36),
                  title: en ? 'If you are involved in a crash' : 'En cas d’accident',
                  lines: en
                      ? const [
                          'Move out of immediate danger only when it is safe and lawful to do so.',
                          'Call emergency services for injuries, fire, dangerous traffic conditions or other immediate hazards.',
                          'Do not move an injured person unless remaining in place creates a greater danger.',
                          'Use warning equipment according to local road rules and only if you can deploy it safely.',
                        ]
                      : const [
                          'Éloignez-vous du danger immédiat uniquement si cela peut se faire sans risque et conformément aux règles locales.',
                          'Appelez les secours en cas de blessure, incendie, circulation dangereuse ou autre danger immédiat.',
                          'Ne déplacez pas une personne blessée sauf si rester sur place crée un danger supérieur.',
                          'Utilisez la signalisation de sécurité selon les règles routières locales et seulement si vous pouvez la mettre en place sans vous exposer.',
                        ],
                ),
                _VehicleCard(
                  icon: Icons.build_circle_outlined,
                  color: const Color(0xff087f83),
                  title: en ? 'If the vehicle breaks down' : 'Si le véhicule tombe en panne',
                  lines: en
                      ? const [
                          'Get as far away from moving traffic as is safely possible.',
                          'Turn on hazard lights and follow local roadside-safety rules.',
                          'Stay in a safer location rather than standing close to moving traffic.',
                          'Call roadside assistance or emergency services when the location or conditions make the situation dangerous.',
                        ]
                      : const [
                          'Éloignez le véhicule de la circulation autant que cela peut être fait en sécurité.',
                          'Allumez les feux de détresse et suivez les règles locales de sécurité routière.',
                          'Restez dans l’endroit le plus sûr disponible plutôt que près de la circulation.',
                          'Appelez l’assistance ou les secours si l’emplacement ou les conditions rendent la situation dangereuse.',
                        ],
                ),
                _VehicleCard(
                  icon: Icons.ac_unit_rounded,
                  color: const Color(0xff237fc7),
                  title: en ? 'Stranded in cold weather' : 'Bloqué par temps froid',
                  lines: en
                      ? const [
                          'Stay with the vehicle when it provides the safest shelter and rescuers can locate it.',
                          'Use warm clothing and blankets before becoming cold.',
                          'If the engine is used for warmth, ensure the exhaust pipe is clear and avoid carbon-monoxide exposure.',
                          'Never run the vehicle inside an enclosed or poorly ventilated space.',
                        ]
                      : const [
                          'Restez avec le véhicule s’il constitue l’abri le plus sûr et permet aux secours de vous localiser.',
                          'Utilisez vêtements chauds et couvertures avant d’avoir froid.',
                          'Si le moteur est utilisé pour se chauffer, vérifiez que l’échappement n’est pas obstrué et évitez tout risque de monoxyde de carbone.',
                          'Ne faites jamais tourner le véhicule dans un espace fermé ou mal ventilé.',
                        ],
                ),
                _VehicleCard(
                  icon: Icons.flood_rounded,
                  color: const Color(0xff237fc7),
                  title: en ? 'Flooded road' : 'Route inondée',
                  lines: en
                      ? const [
                          'Do not drive into floodwater when depth, current or road condition is uncertain.',
                          'Turn around and use another route.',
                          'If authorities order evacuation, follow the designated route and avoid closed roads.',
                        ]
                      : const [
                          'Ne vous engagez pas dans une route inondée si la profondeur, le courant ou l’état de la chaussée sont incertains.',
                          'Faites demi-tour et cherchez un autre itinéraire.',
                          'En cas d’ordre d’évacuation, suivez l’itinéraire indiqué et respectez les routes fermées.',
                        ],
                ),
                const SizedBox(height: 10),
                Text(
                  en ? 'Vehicle readiness checklist' : 'Checklist véhicule',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                ..._items.map((item) {
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
                        en ? _english(item.id) : item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(en ? _englishSubtitle(item.id) : item.subtitle),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xfffff2df),
                      child: Icon(Icons.inventory_2_rounded, color: Color(0xffb7833f)),
                    ),
                    title: Text(
                      en ? 'Open vehicle kit' : 'Ouvrir le kit véhicule',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      en
                          ? 'Keep a dedicated emergency kit in the vehicle.'
                          : 'Conserver un kit d’urgence dédié dans le véhicule.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SpecialKitsScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _openReadySource,
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Ready.gov'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openNhtsaSource,
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('NHTSA'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  String _english(String id) {
    switch (id) {
      case 'phone':
        return 'Phone + vehicle charger';
      case 'warning':
        return 'Warning triangle / signalling';
      case 'firstaid':
        return 'First-aid kit';
      case 'light':
        return 'Flashlight';
      case 'water_food':
        return 'Water & food';
      case 'warmth':
        return 'Weather protection';
      case 'maps':
        return 'Backup map / route';
      case 'tools':
        return 'Vehicle tools';
      default:
        return id;
    }
  }

  String _englishSubtitle(String id) {
    switch (id) {
      case 'phone':
        return 'The phone can be recharged during the journey.';
      case 'warning':
        return 'Locally required or recommended warning equipment is accessible.';
      case 'firstaid':
        return 'The kit is accessible and its contents have been checked.';
      case 'light':
        return 'A light works without relying on vehicle power.';
      case 'water_food':
        return 'A small reserve is available for a prolonged stop.';
      case 'warmth':
        return 'Blanket, weather protection and appropriate clothing are available.';
      case 'maps':
        return 'A backup exists if mobile data or navigation fails.';
      case 'tools':
        return 'Jack, tyre kit, cables and useful tools have been checked.';
      default:
        return '';
    }
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final Color color;
  final String title;
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
                      Expanded(child: Text(line, style: const TextStyle(height: 1.33))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
}

class _VehicleCheck {
  const _VehicleCheck(this.id, this.title, this.subtitle, this.icon);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
