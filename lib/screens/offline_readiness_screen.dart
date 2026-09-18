import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class OfflineReadinessScreen extends StatefulWidget {
  const OfflineReadinessScreen({super.key});

  @override
  State<OfflineReadinessScreen> createState() => _OfflineReadinessScreenState();
}

class _OfflineReadinessScreenState extends State<OfflineReadinessScreen> {
  final _storage = LocalStorageService();
  Set<String> _checks = {};
  bool _loading = true;

  static const _manualChecks = <_OfflineCheck>[
    _OfflineCheck(
      'paper_contacts',
      'Contacts importants sur papier',
      'Au moins un exemplaire existe hors du téléphone.',
      Icons.contact_page_outlined,
    ),
    _OfflineCheck(
      'paper_plan',
      'Plan familial sur papier',
      'Point de rassemblement, contact extérieur et consignes principales.',
      Icons.description_outlined,
    ),
    _OfflineCheck(
      'paper_map',
      'Carte ou itinéraire hors ligne',
      'Une solution existe si la carte en ligne est inaccessible.',
      Icons.map_outlined,
    ),
    _OfflineCheck(
      'radio',
      'Radio autonome',
      'Une radio à piles, dynamo ou autre source autonome est disponible.',
      Icons.radio_rounded,
    ),
    _OfflineCheck(
      'power',
      'Batterie externe',
      'Une batterie externe chargée et les câbles utiles sont disponibles.',
      Icons.battery_charging_full_rounded,
    ),
    _OfflineCheck(
      'emergency_numbers',
      'Numéros d’urgence connus',
      'Les numéros essentiels sont connus ou notés hors ligne.',
      Icons.phone_in_talk_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final checks = await _storage.offlineReadinessChecks();
    if (!mounted) return;
    setState(() {
      _checks = checks;
      _loading = false;
    });
  }

  Future<void> _toggle(String id, bool value) async {
    setState(() {
      value ? _checks.add(id) : _checks.remove(id);
    });
    await _storage.saveOfflineReadinessChecks(_checks);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final validIds = _manualChecks.map((item) => item.id).toSet();
    final readyCount = _checks.intersection(validIds).length;
    final progress =
        _manualChecks.isEmpty ? 0.0 : readyCount / _manualChecks.length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(en ? 'Offline readiness' : 'Préparation hors ligne')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xff087f83),
                            child: Icon(Icons.offline_bolt_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              en
                                  ? 'ReadySafe should remain useful when networks fail'
                                  : 'ReadySafe doit rester utile quand le réseau tombe',
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
                          color: const Color(0xff087f83),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        en
                            ? '$readyCount / ${_manualChecks.length} offline backups ready'
                            : '$readyCount / ${_manualChecks.length} sauvegardes externes prêtes',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  en ? 'Available directly in the app' : 'Disponible directement dans l’application',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                _Capability(
                  icon: Icons.health_and_safety_rounded,
                  title: en ? 'First aid' : 'Premiers secours',
                  subtitle: en ? 'Guides, illustrations and step-by-step mode are bundled.' : 'Fiches, illustrations et mode pas à pas embarqués.',
                  available: true,
                ),
                _Capability(
                  icon: Icons.backpack_rounded,
                  title: en ? 'Kits & checklists' : 'Kits & check-lists',
                  subtitle: en ? 'Lists and progress are stored locally.' : 'Listes et progression stockées localement.',
                  available: true,
                ),
                _Capability(
                  icon: Icons.family_restroom_rounded,
                  title: en ? 'Family, contacts & plans' : 'Famille, contacts et plans',
                  subtitle: en ? 'Information is stored locally on the device.' : 'Informations enregistrées localement sur l’appareil.',
                  available: true,
                ),
                _Capability(
                  icon: Icons.inventory_2_rounded,
                  title: en ? 'Specialized kits' : 'Kits spécialisés',
                  subtitle: en ? 'Evacuation, vehicle, travel, children, pets and outdoor.' : 'Évacuation, voiture, voyage, enfants, animaux et extérieur.',
                  available: true,
                ),
                _Capability(
                  icon: Icons.warning_amber_rounded,
                  title: en ? 'Risk & disaster guides' : 'Guides risques & catastrophes',
                  subtitle: en ? 'General guidance is bundled in the app.' : 'Consignes générales embarquées dans l’application.',
                  available: true,
                ),
                const SizedBox(height: 12),
                Text(
                  en ? 'May require connectivity' : 'Peut nécessiter une connexion',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                _Capability(
                  icon: Icons.map_rounded,
                  title: en ? 'Map background' : 'Fond de carte',
                  subtitle: en ? 'Personal landmarks remain saved, but map tiles can require Internet access.' : 'Les repères personnels restent enregistrés, mais les tuiles cartographiques peuvent nécessiter Internet.',
                  available: false,
                ),
                _Capability(
                  icon: Icons.campaign_rounded,
                  title: en ? 'Official alerts & sources' : 'Alertes & sources officielles',
                  subtitle: en ? 'Official links generally need connectivity for current information.' : 'Les liens officiels nécessitent généralement une connexion pour obtenir l’information à jour.',
                  available: false,
                ),
                const SizedBox(height: 14),
                Text(
                  en ? 'Backup outside the phone' : 'Plan B hors téléphone',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                ..._manualChecks.map((item) {
                  final checked = _checks.contains(item.id);
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
                        en ? _checkTitle(item.id) : item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(en ? _checkSubtitle(item.id) : item.subtitle),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff4c7),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xff9a6a00)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          en
                              ? 'Offline mode does not replace a radio, paper copies, a charged power bank or the phone’s government alert systems.'
                              : 'Le mode hors ligne ne remplace pas une radio, des copies papier, une batterie externe ni les systèmes d’alerte gouvernementaux du téléphone.',
                          style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

String _checkTitle(String id) {
  return const {
        'paper_contacts': 'Important contacts on paper',
        'paper_plan': 'Family plan on paper',
        'paper_map': 'Offline map or route',
        'radio': 'Independent radio',
        'power': 'Power bank',
        'emergency_numbers': 'Emergency numbers known',
      }[id] ??
      id;
}

String _checkSubtitle(String id) {
  return const {
        'paper_contacts': 'At least one copy exists outside the phone.',
        'paper_plan': 'Meeting point, out-of-area contact and core instructions are written down.',
        'paper_map': 'A backup exists if the online map cannot be used.',
        'radio': 'A battery, hand-crank or other independent radio is available.',
        'power': 'A charged power bank and useful cables are ready.',
        'emergency_numbers': 'Essential numbers are known or written down offline.',
      }[id] ??
      '';
}

class _Capability extends StatelessWidget {
  const _Capability({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.available,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool available;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: available
                ? const Color(0xffdff2ed)
                : const Color(0xfffff2df),
            child: Icon(
              icon,
              color: available
                  ? const Color(0xff087f83)
                  : const Color(0xffb7833f),
            ),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(subtitle),
          trailing: Icon(
            available ? Icons.offline_pin_rounded : Icons.wifi_rounded,
            color: available ? const Color(0xff087f83) : const Color(0xffb7833f),
          ),
        ),
      );
}

class _OfflineCheck {
  const _OfflineCheck(this.id, this.title, this.subtitle, this.icon);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
