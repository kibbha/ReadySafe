import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final items = <_LeaveItem>[
      const _LeaveItem('people', 'Toutes les personnes', 'Compter tout le foyer', Icons.groups_rounded),
      const _LeaveItem('phone', 'Téléphones', 'Téléphone + batterie externe', Icons.phone_android_rounded),
      const _LeaveItem('meds', 'Médicaments', 'Traitements indispensables', Icons.medication_rounded),
      const _LeaveItem('docs', 'Documents', 'Identité, assurance, santé', Icons.folder_copy_rounded),
      const _LeaveItem('water', 'Eau', 'Prendre une réserve immédiatement disponible', Icons.water_drop_rounded),
      const _LeaveItem('bag', 'Sac d’urgence', 'Kit prêt à emporter', Icons.backpack_rounded),
      if ((_family['pets'] ?? 0) > 0)
        const _LeaveItem('pets', 'Animaux', 'Laisse, caisse, eau et nourriture', Icons.pets_rounded),
      const _LeaveItem('meeting', 'Point de rassemblement', 'Confirmer où tout le monde se retrouve', Icons.location_on_rounded),
    ];
    final progress = items.isEmpty ? 0.0 : _done.intersection(items.map((e) => e.id).toSet()).length / items.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Je dois partir maintenant')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffffeded),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xffd92d36),
                  child: Icon(Icons.directions_run_rounded, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Priorité à la sécurité : suivez les consignes officielles et ne retardez jamais une évacuation pour récupérer un objet.',
                    style: TextStyle(fontWeight: FontWeight.w800, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
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
                  backgroundColor: checked ? const Color(0xffdff2ed) : const Color(0xfffff2df),
                  child: Icon(
                    item.icon,
                    color: checked ? const Color(0xff087f83) : const Color(0xffb7833f),
                  ),
                ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(item.subtitle),
              ),
            );
          }),
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
