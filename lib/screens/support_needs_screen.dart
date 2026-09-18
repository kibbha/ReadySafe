import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class SupportNeedsScreen extends StatefulWidget {
  const SupportNeedsScreen({super.key});

  @override
  State<SupportNeedsScreen> createState() => _SupportNeedsScreenState();
}

class _SupportNeedsScreenState extends State<SupportNeedsScreen> {
  final _storage = LocalStorageService();
  final _notes = TextEditingController();

  Set<String> _selected = {};
  bool _loading = true;
  bool _saved = false;

  static const _needs = <_SupportNeed>[
    _SupportNeed(
      'mobility',
      'Mobilité',
      'Prévoir aide au déplacement, accès sans obstacle et solution d’évacuation.',
      Icons.accessible_forward_rounded,
    ),
    _SupportNeed(
      'vision',
      'Vision',
      'Prévoir repères tactiles, contraste, lunettes et consignes adaptées.',
      Icons.visibility_outlined,
    ),
    _SupportNeed(
      'hearing',
      'Audition',
      'Prévoir alertes visuelles, aides auditives et batteries de rechange.',
      Icons.hearing_rounded,
    ),
    _SupportNeed(
      'communication',
      'Communication',
      'Prévoir un moyen simple pour expliquer les besoins ou demander de l’aide.',
      Icons.record_voice_over_outlined,
    ),
    _SupportNeed(
      'cognitive',
      'Compréhension / mémoire',
      'Prévoir des consignes courtes, écrites et répétables.',
      Icons.psychology_alt_outlined,
    ),
    _SupportNeed(
      'power',
      'Équipement dépendant de l’électricité',
      'Prévoir autonomie, batteries et solution de secours adaptée.',
      Icons.electrical_services_rounded,
    ),
    _SupportNeed(
      'caregiver',
      'Aide d’un proche / aidant',
      'Prévoir qui peut aider et comment le contacter rapidement.',
      Icons.volunteer_activism_outlined,
    ),
    _SupportNeed(
      'service_animal',
      'Animal d’assistance',
      'Prévoir nourriture, eau, harnais, documents et solution d’accueil.',
      Icons.pets_rounded,
    ),
    _SupportNeed(
      'language',
      'Barrière de langue',
      'Prévoir quelques phrases essentielles et informations écrites.',
      Icons.translate_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final selected = await _storage.supportNeeds();
    final notes = await _storage.supportNeedsNotes();
    if (!mounted) return;
    _notes.text = notes;
    setState(() {
      _selected = selected;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await _storage.saveSupportNeeds(_selected);
    await _storage.saveSupportNeedsNotes(_notes.text.trim());
    if (!mounted) return;
    setState(() => _saved = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: const Text('Besoins spécifiques'),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _save,
            icon: Icon(_saved ? Icons.check_rounded : Icons.save_outlined),
            label: Text(_saved ? 'Enregistré' : 'Enregistrer'),
          ),
        ],
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
                      colors: [Color(0xffe4f3f0), Color(0xfffff4e8)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xff087f83),
                        child: Icon(Icons.accessibility_new_rounded, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Préparer l’urgence pour tout le monde',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sélectionnez les besoins à prendre en compte dans votre organisation. ReadySafe conserve ces choix uniquement sur l’appareil.',
                              style: TextStyle(color: Color(0xff65747a), height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ..._needs.map((need) {
                  final selected = _selected.contains(need.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: selected,
                      onChanged: (value) {
                        setState(() {
                          (value ?? false)
                              ? _selected.add(need.id)
                              : _selected.remove(need.id);
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundColor: selected
                            ? const Color(0xffdff2ed)
                            : const Color(0xfffff2df),
                        child: Icon(
                          need.icon,
                          color: selected
                              ? const Color(0xff087f83)
                              : const Color(0xffb7833f),
                        ),
                      ),
                      title: Text(
                        need.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(need.subtitle),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Text(
                  'Notes pratiques',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: _notes,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Ex. où se trouve le fauteuil, qui peut aider, matériel à prendre…',
                    prefixIcon: Icon(Icons.notes_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff4c7),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: Color(0xff9a6a00)),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Évitez d’enregistrer ici des diagnostics détaillés, ordonnances ou données médicales sensibles. Utilisez seulement les informations pratiques nécessaires à la préparation.',
                          style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
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

class _SupportNeed {
  const _SupportNeed(this.id, this.title, this.subtitle, this.icon);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
