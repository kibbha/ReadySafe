import 'package:flutter/material.dart';

import '../data/content.dart';
import '../models/checklist_item.dart';
import '../services/local_storage_service.dart';
import 'checklist_screen.dart';
import 'preparedness_review_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _storage = LocalStorageService();

  Map<String, KitStockEntry> _stock = {};
  Map<String, DateTime> _dates = {};
  DateTime? _reviewDate;
  bool _loading = true;

  static const _tasks = <_MaintenanceTask>[
    _MaintenanceTask(
      'powerbank',
      'Batteries externes',
      'Rechargez les batteries de secours et vérifiez les câbles.',
      Icons.battery_charging_full_rounded,
      30,
    ),
    _MaintenanceTask(
      'radio',
      'Radio & piles',
      'Testez la radio et remplacez les piles si nécessaire.',
      Icons.radio_rounded,
      90,
    ),
    _MaintenanceTask(
      'water',
      'Réserve d’eau',
      'Vérifiez contenants, rotation et état de la réserve.',
      Icons.water_drop_outlined,
      90,
    ),
    _MaintenanceTask(
      'firstaid',
      'Trousse de premiers secours',
      'Contrôlez le contenu et les consommables à remplacer.',
      Icons.medical_services_outlined,
      90,
    ),
    _MaintenanceTask(
      'documents',
      'Documents & contacts',
      'Vérifiez que références, contacts et copies restent à jour.',
      Icons.folder_copy_outlined,
      180,
    ),
    _MaintenanceTask(
      'routes',
      'Itinéraires & rassemblement',
      'Revalidez sortie principale, alternative et point de rendez-vous.',
      Icons.route_outlined,
      180,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stock = await _storage.kitStock();
    final dates = await _storage.maintenanceDates();
    final review = await _storage.preparednessReviewDate();
    if (!mounted) return;
    setState(() {
      _stock = stock;
      _dates = dates;
      _reviewDate = review;
      _loading = false;
    });
  }

  Future<void> _markNow(String id) async {
    final now = DateTime.now();
    await _storage.saveMaintenanceDate(id, now);
    if (!mounted) return;
    setState(() => _dates[id] = now);
  }

  bool _due(_MaintenanceTask task) {
    final last = _dates[task.id];
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= task.intervalDays;
  }

  int _daysUntilExpiry(KitStockEntry entry) {
    final date = entry.expiryDate;
    if (date == null) return 999999;
    return date.difference(DateTime.now()).inDays;
  }

  List<MapEntry<ChecklistItem, KitStockEntry>> get _expiryItems {
    final items = <MapEntry<ChecklistItem, KitStockEntry>>[];
    for (final item in kitItems) {
      final entry = _stock[item.id];
      if (entry?.expiryDate == null) continue;
      if (entry!.isExpired ||
          entry.expiresWithin(entry.reminderEnabled ? entry.reminderDays : 30)) {
        items.add(MapEntry(item, entry));
      }
    }
    items.sort(
      (a, b) => (a.value.expiryDate ?? DateTime(9999))
          .compareTo(b.value.expiryDate ?? DateTime(9999)),
    );
    return items;
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final expiryItems = _expiryItems;
    final dueTasks = _tasks.where(_due).length;
    final reviewDue = _reviewDate == null ||
        DateTime.now().difference(_reviewDate!).inDays >= 365;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(en ? 'Maintenance & reminders' : 'Entretien & rappels')),
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
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xffb7833f),
                        child: Icon(Icons.event_repeat_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              en ? 'Preparedness only works when it stays current' : 'Une préparation utile doit rester à jour',
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              en
                                  ? '$dueTasks check(s) due · ${expiryItems.length} item(s) to review'
                                  : '$dueTasks vérification(s) à faire · ${expiryItems.length} élément(s) à surveiller',
                              style: const TextStyle(
                                color: Color(0xff65747a),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (expiryItems.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          en ? 'Kit expiry dates' : 'Péremptions du kit',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChecklistScreen(kit: true),
                          ),
                        ).then((_) => _load()),
                        child: Text(en ? 'Open kit' : 'Ouvrir le kit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...expiryItems.take(8).map((entry) {
                    final days = _daysUntilExpiry(entry.value);
                    final expired = entry.value.isExpired;
                    final remaining = days < 0 ? 0 : days;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: expired
                              ? const Color(0xffffe5e7)
                              : const Color(0xfffff2df),
                          child: Icon(
                            expired ? Icons.error_outline_rounded : Icons.schedule_rounded,
                            color: expired
                                ? const Color(0xffd92d36)
                                : const Color(0xffb7833f),
                          ),
                        ),
                        title: Text(
                          _kitLabel(entry.key, en),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(
                          en
                              ? 'Expiry: ${_date(entry.value.expiryDate!)} · '
                                  '${expired ? 'expired' : 'in $remaining day(s)'}'
                              : 'DLC : ${_date(entry.value.expiryDate!)} · '
                                  '${expired ? 'dépassée' : 'dans $remaining jour(s)'}',
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                ],
                Text(
                  en ? 'Periodic checks' : 'Vérifications périodiques',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                ..._tasks.map((task) {
                  final last = _dates[task.id];
                  final due = _due(task);
                  final lastLabel = last == null
                      ? (en ? 'Never checked' : 'Jamais vérifié')
                      : (en
                          ? 'Last checked: ${_date(last)}'
                          : 'Dernière vérification : ${_date(last)}');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      minTileHeight: 78,
                      leading: CircleAvatar(
                        backgroundColor: due
                            ? const Color(0xfffff2df)
                            : const Color(0xffdff2ed),
                        child: Icon(
                          task.icon,
                          color: due
                              ? const Color(0xffb7833f)
                              : const Color(0xff087f83),
                        ),
                      ),
                      title: Text(
                        _taskTitle(task, en),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text('${_taskSubtitle(task, en)}\n$lastLabel'),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: en ? 'Checked today' : 'Vérifié aujourd’hui',
                        onPressed: () => _markNow(task.id),
                        icon: Icon(
                          due ? Icons.check_circle_outline_rounded : Icons.check_circle_rounded,
                          color: const Color(0xff087f83),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: reviewDue
                          ? const Color(0xfffff2df)
                          : const Color(0xffdff2ed),
                      child: Icon(
                        Icons.fact_check_rounded,
                        color: reviewDue
                            ? const Color(0xffb7833f)
                            : const Color(0xff087f83),
                      ),
                    ),
                    title: Text(
                      en ? 'Full preparedness review' : 'Revue globale du plan',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      _reviewDate == null
                          ? (en ? 'No full review saved yet.' : 'Aucune revue complète enregistrée.')
                          : (en ? 'Last review: ${_date(_reviewDate!)}' : 'Dernière revue : ${_date(_reviewDate!)}'),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PreparednessReviewScreen(),
                      ),
                    ).then((_) => _load()),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xffeaf6f4),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notifications_none_rounded, color: Color(0xff087f83)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          en
                              ? 'These reminders are stored in ReadySafe and remain available offline. Review this screen regularly for expiry dates and items that need renewal.'
                              : 'Ces rappels sont enregistrés dans ReadySafe et restent disponibles hors ligne. Consultez régulièrement cet écran pour vérifier les échéances et les éléments à renouveler.',
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

String _taskTitle(_MaintenanceTask task, bool en) {
  if (!en) return task.title;
  return const {
        'powerbank': 'Power banks',
        'radio': 'Radio & batteries',
        'water': 'Water reserve',
        'firstaid': 'First-aid kit',
        'documents': 'Documents & contacts',
        'routes': 'Routes & meeting points',
      }[task.id] ??
      task.title;
}

String _taskSubtitle(_MaintenanceTask task, bool en) {
  if (!en) return task.subtitle;
  return const {
        'powerbank': 'Recharge backup batteries and check charging cables.',
        'radio': 'Test the radio and replace batteries when needed.',
        'water': 'Check containers, rotation and the condition of the water reserve.',
        'firstaid': 'Review contents and replace expired or used supplies.',
        'documents': 'Confirm references, contacts and copies are still current.',
        'routes': 'Reconfirm the primary exit, alternative route and meeting point.',
      }[task.id] ??
      task.subtitle;
}

String _kitLabel(ChecklistItem item, bool en) {
  if (!en) return item.label;
  return const {
        'water': 'Drinking water',
        'food': 'Long-life food',
        'pet_food': 'Pet food',
        'medication': 'Essential personal medicines',
        'firstaid': 'First-aid kit',
        'disinfectant': 'Antiseptic / disinfectant',
        'batteries': 'Spare batteries',
        'children': 'Baby / child supplies',
      }[item.id] ??
      item.label;
}

class _MaintenanceTask {
  const _MaintenanceTask(
    this.id,
    this.title,
    this.subtitle,
    this.icon,
    this.intervalDays,
  );

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int intervalDays;
}
