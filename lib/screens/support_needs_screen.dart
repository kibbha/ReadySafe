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
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Support needs' : 'Besoins spécifiques'),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _save,
            icon: Icon(
              _saved ? Icons.check_rounded : Icons.save_outlined,
            ),
            label: Text(
              _saved
                  ? (en ? 'Saved' : 'Enregistré')
                  : (en ? 'Save' : 'Enregistrer'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xff087f83),
                            child: Icon(
                              Icons.accessibility_new_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  en
                                      ? 'Prepare emergency access for everyone'
                                      : 'Préparer l’urgence pour tout le monde',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  en
                                      ? 'Select practical needs that should be considered in household plans. ReadySafe stores these selections locally on the device.'
                                      : 'Sélectionnez les besoins à prendre en compte dans votre organisation. ReadySafe conserve ces choix uniquement sur l’appareil.',
                                  style: const TextStyle(
                                    color: Color(0xff65747a),
                                    height: 1.35,
                                  ),
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
                            en ? _titleEn(need.id) : need.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(
                            en ? _subtitleEn(need.id) : need.subtitle,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Text(
                      en ? 'Practical notes' : 'Notes pratiques',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _notes,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: en
                            ? 'E.g. wheelchair location, who can help, equipment to take…'
                            : 'Ex. où se trouve le fauteuil, qui peut aider, matériel à prendre…',
                        prefixIcon: const Icon(Icons.notes_rounded),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.privacy_tip_outlined,
                            color: Color(0xff9a6a00),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              en
                                  ? 'Avoid entering detailed diagnoses, prescriptions or sensitive medical information here. Store only practical preparedness information; sensitive references belong in the secure vault.'
                                  : 'Évitez d’enregistrer ici des diagnostics détaillés, ordonnances ou données médicales sensibles. Utilisez seulement les informations pratiques nécessaires à la préparation ; les références sensibles doivent rester dans le coffre sécurisé.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _titleEn(String id) {
    return const {
          'mobility': 'Mobility',
          'vision': 'Vision',
          'hearing': 'Hearing',
          'communication': 'Communication',
          'cognitive': 'Understanding / memory',
          'power': 'Electricity-dependent equipment',
          'caregiver': 'Family / caregiver assistance',
          'service_animal': 'Service animal',
          'language': 'Language barrier',
        }[id] ??
        id;
  }

  String _subtitleEn(String id) {
    return const {
          'mobility':
              'Plan movement assistance, step-free access and a safe evacuation method.',
          'vision':
              'Plan tactile cues, contrast, glasses and adapted instructions.',
          'hearing':
              'Plan visual alerts, hearing devices and spare batteries.',
          'communication':
              'Keep a simple way to explain needs or request assistance.',
          'cognitive':
              'Use short, written and repeatable instructions.',
          'power':
              'Plan battery autonomy, backup power and an alternative safe location.',
          'caregiver':
              'Identify who can assist and how to contact them quickly.',
          'service_animal':
              'Plan food, water, harness, documents and a suitable reception location.',
          'language':
              'Prepare a few essential phrases and written emergency information.',
        }[id] ??
        '';
  }
}

class _SupportNeed {
  const _SupportNeed(
    this.id,
    this.title,
    this.subtitle,
    this.icon,
  );

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
