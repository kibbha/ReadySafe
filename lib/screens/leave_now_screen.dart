import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';
import 'emergency_screen.dart';

class LeaveNowScreen extends StatefulWidget {
  const LeaveNowScreen({super.key});

  @override
  State<LeaveNowScreen> createState() => _LeaveNowScreenState();
}

class _LeaveNowScreenState extends State<LeaveNowScreen> {
  final _storage = LocalStorageService();
  Set<String> _done = {};
  Map<String, int> _family = {'adults': 1, 'children': 0, 'care': 0, 'pets': 0};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = await _storage.completed('leave_now_v3');
    final family = await _storage.family();
    if (!mounted) return;
    setState(() {
      _done = done;
      _family = family;
    });
  }

  Future<void> _clear(List<_LeaveItem> items) async {
    for (final item in items) {
      await _storage.toggle('leave_now_v3', item.id, false);
    }
    if (!mounted) return;
    setState(() => _done.clear());
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    final items = <_LeaveItem>[
      _LeaveItem(
        'people',
        en ? 'Everyone in the household' : 'Toutes les personnes',
        en ? 'Count everyone before leaving' : 'Compter tout le foyer',
        Icons.groups_rounded,
      ),
      _LeaveItem(
        'phone',
        en ? 'Phones & backup power' : 'Téléphones',
        en ? 'Phone, cable and power bank' : 'Téléphone + batterie externe',
        Icons.phone_android_rounded,
      ),
      _LeaveItem(
        'meds',
        en ? 'Essential medicines' : 'Médicaments',
        en ? 'Take essential prescribed treatment' : 'Traitements indispensables',
        Icons.medication_rounded,
      ),
      _LeaveItem(
        'docs',
        en ? 'Identity & essential references' : 'Documents',
        en ? 'Identity, insurance and essential references' : 'Identité, assurance, santé',
        Icons.folder_copy_rounded,
      ),
      _LeaveItem(
        'water',
        en ? 'Water' : 'Eau',
        en ? 'Take the safe water immediately available' : 'Prendre une réserve immédiatement disponible',
        Icons.water_drop_rounded,
      ),
      _LeaveItem(
        'bag',
        en ? 'Emergency bag' : 'Sac d’urgence',
        en ? 'Take the ready go-bag if it is immediately accessible' : 'Kit prêt à emporter',
        Icons.backpack_rounded,
      ),
      if ((_family['pets'] ?? 0) > 0)
        _LeaveItem(
          'pets',
          en ? 'Pets' : 'Animaux',
          en ? 'Lead/carrier, water and essential supplies' : 'Laisse, caisse, eau et nourriture',
          Icons.pets_rounded,
        ),
      _LeaveItem(
        'meeting',
        en ? 'Meeting point' : 'Point de rassemblement',
        en ? 'Confirm where the household will reconnect' : 'Confirmer où tout le monde se retrouve',
        Icons.location_on_rounded,
      ),
    ];

    final relevantIds = items.map((item) => item.id).toSet();
    final completed = _done.intersection(relevantIds).length;
    final progress = items.isEmpty ? 0.0 : completed / items.length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'I must leave now' : 'Je dois partir maintenant'),
        actions: [
          IconButton(
            tooltip: en ? 'Emergency numbers' : 'Numéros d’urgence',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyScreen()),
            ),
            icon: const Icon(Icons.phone_in_talk_rounded),
          ),
          IconButton(
            tooltip: en ? 'Reset checklist' : 'Réinitialiser la checklist',
            onPressed: completed == 0 ? null : () => _clear(items),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffffeded),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xffffcfd2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xffd92d36),
                  child: Icon(Icons.directions_run_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    en
                        ? 'Safety first: follow official instructions and never delay an evacuation to retrieve an object.'
                        : 'Priorité à la sécurité : suivez les consignes officielles et ne retardez jamais une évacuation pour récupérer un objet.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  en
                      ? '$completed / ${items.length} immediate points checked'
                      : '$completed / ${items.length} points immédiats vérifiés',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xff087f83),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xff087f83),
            backgroundColor: const Color(0xffe4ecec),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final checked = _done.contains(item.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: checked,
                onChanged: (value) async {
                  final next = value ?? false;
                  setState(() {
                    next ? _done.add(item.id) : _done.remove(item.id);
                  });
                  await _storage.toggle('leave_now_v3', item.id, next);
                },
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
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xffeaf6f4),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xff087f83)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    en
                        ? 'This checklist is intentionally short. If authorities say to leave immediately, leave even when boxes are still unchecked.'
                        : 'Cette checklist est volontairement courte. Si les autorités demandent un départ immédiat, partez même si certaines cases ne sont pas cochées.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
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

class _LeaveItem {
  const _LeaveItem(this.id, this.title, this.subtitle, this.icon);

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
