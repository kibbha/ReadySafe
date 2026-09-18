import 'package:flutter/material.dart';

import '../app/localizations.dart';
import '../services/local_storage_service.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _storage = LocalStorageService();

  Map<String, int> _values = {
    'adults': 1,
    'children': 0,
    'care': 0,
    'pets': 0,
  };

  bool _loading = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await _storage.family();
    if (!mounted) return;

    setState(() {
      _values = values;
      _loading = false;
      _dirty = false;
    });
  }

  void _change(String key, int delta) {
    final current = _values[key] ?? 0;
    final next = (current + delta).clamp(0, 99).toInt();

    setState(() {
      _values = {
        ..._values,
        key: next,
      };
      _dirty = true;
    });
  }

  Future<void> _save() async {
    await _storage.saveFamily(_values);

    if (!mounted) return;

    setState(() => _dirty = false);

    final en = Localizations.localeOf(context).languageCode == 'en';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          en
              ? 'Household profile saved locally.'
              : 'Profil du foyer enregistré localement.',
        ),
      ),
    );
  }

  int get _people =>
      (_values['adults'] ?? 0) +
      (_values['children'] ?? 0) +
      (_values['care'] ?? 0);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';

    final entries = <_FamilyEntry>[
      _FamilyEntry(
        'adults',
        t.get('adults'),
        en
            ? 'Adults able to take part in the household plan.'
            : 'Adultes participant au plan du foyer.',
        Icons.person_rounded,
        const Color(0xff087f83),
      ),
      _FamilyEntry(
        'children',
        t.get('children'),
        en
            ? 'Children who may need age-appropriate supplies and instructions.'
            : 'Enfants pouvant nécessiter du matériel et des consignes adaptés.',
        Icons.child_care_rounded,
        const Color(0xffb7833f),
      ),
      _FamilyEntry(
        'care',
        t.get('care_people'),
        en
            ? 'People who may need help with mobility, treatment or communication.'
            : 'Personnes pouvant nécessiter une aide pour la mobilité, les soins ou la communication.',
        Icons.accessibility_new_rounded,
        const Color(0xff6750a4),
      ),
      _FamilyEntry(
        'pets',
        t.get('pets'),
        en
            ? 'Animals whose transport, water, food and identification must be planned.'
            : 'Animaux dont le transport, l’eau, la nourriture et l’identification doivent être prévus.',
        Icons.pets_rounded,
        const Color(0xff147343),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(t.get('family')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffe4f3f0),
                            Color(0xfffff4e8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xff087f83),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: const Icon(
                              Icons.family_restroom_rounded,
                              color: Colors.white,
                              size: 29,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.get('family_profile'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  en
                                      ? '$_people people · ${_values['pets'] ?? 0} pet(s)'
                                      : '$_people personne(s) · ${_values['pets'] ?? 0} animal(aux)',
                                  style: const TextStyle(
                                    color: Color(0xff65747a),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xff087f83),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              t.get('family_privacy'),
                              style: const TextStyle(
                                height: 1.35,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final entry in entries)
                      _FamilyCounterCard(
                        entry: entry,
                        value: _values[entry.id] ?? 0,
                        onMinus: (_values[entry.id] ?? 0) > 0
                            ? () => _change(entry.id, -1)
                            : null,
                        onPlus: () => _change(entry.id, 1),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xfffff4c7),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calculate_outlined,
                            color: Color(0xff9a6a00),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              en
                                  ? 'This profile is used to adapt kit quantities, evacuation checklists and preparedness scoring to the household.'
                                  : 'Ce profil sert à adapter les quantités du kit, les checklists d’évacuation et le score de préparation au foyer.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _dirty ? _save : null,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        _dirty
                            ? t.get('save_local')
                            : (en
                                ? 'Saved locally'
                                : 'Enregistré localement'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _FamilyCounterCard extends StatelessWidget {
  const _FamilyCounterCard({
    required this.entry,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final _FamilyEntry entry;
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: entry.color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  entry.icon,
                  color: entry.color,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xff65747a),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: '-1',
                onPressed: onMinus,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: '+1',
                onPressed: onPlus,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
      );
}

class _FamilyEntry {
  const _FamilyEntry(
    this.id,
    this.title,
    this.subtitle,
    this.icon,
    this.color,
  );

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
