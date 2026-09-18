import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';

class FamilyReunificationScreen extends StatefulWidget {
  const FamilyReunificationScreen({super.key});

  @override
  State<FamilyReunificationScreen> createState() => _FamilyReunificationScreenState();
}

class _FamilyReunificationScreenState extends State<FamilyReunificationScreen> {
  final _storage = LocalStorageService();
  final _meeting = TextEditingController();
  final _backup = TextEditingController();
  final _outsideArea = TextEditingController();
  final _authorizedPickup = TextEditingController();
  final _childInstructions = TextEditingController();

  Map<String, String> _communication = {};
  Set<String> _checks = {};
  bool _loading = true;
  bool _saved = false;

  static const _checkItems = <_ReunificationCheck>[
    _ReunificationCheck(
      'written_contacts',
      'Contacts importants disponibles sur papier',
      Icons.contact_page_outlined,
    ),
    _ReunificationCheck(
      'school_plan',
      'Plan école / garde connu',
      Icons.school_outlined,
    ),
    _ReunificationCheck(
      'pickup_person',
      'Personne autorisée à récupérer l’enfant identifiée',
      Icons.badge_outlined,
    ),
    _ReunificationCheck(
      'outside_contact',
      'Contact extérieur au quartier défini',
      Icons.connect_without_contact_rounded,
    ),
    _ReunificationCheck(
      'meeting_places',
      'Points de rendez-vous principal et alternatif connus',
      Icons.location_on_outlined,
    ),
    _ReunificationCheck(
      'practice',
      'Le plan a été expliqué ou testé en famille',
      Icons.family_restroom_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _meeting.dispose();
    _backup.dispose();
    _outsideArea.dispose();
    _authorizedPickup.dispose();
    _childInstructions.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final plan = await _storage.familyPlan();
    final communication = await _storage.communicationPlan();
    final checks = await _storage.completed('family_reunification_v3');
    if (!mounted) return;

    _meeting.text = plan['meetingPoint'] ?? '';
    _backup.text = plan['backupMeetingPoint'] ?? '';
    _outsideArea.text = plan['outsideAreaMeetingPoint'] ?? '';
    _authorizedPickup.text = plan['authorizedPickup'] ?? '';
    _childInstructions.text = plan['childInstructions'] ?? '';

    setState(() {
      _communication = communication;
      _checks = checks;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final current = await _storage.familyPlan();
    await _storage.saveFamilyPlan({
      ...current,
      'meetingPoint': _meeting.text.trim(),
      'backupMeetingPoint': _backup.text.trim(),
      'outsideAreaMeetingPoint': _outsideArea.text.trim(),
      'authorizedPickup': _authorizedPickup.text.trim(),
      'childInstructions': _childInstructions.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saved = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _toggle(String id, bool value) async {
    setState(() {
      value ? _checks.add(id) : _checks.remove(id);
    });
    await _storage.toggle('family_reunification_v3', id, value);
  }

  String _walletCard(bool en) {
    final contact = (_communication['outOfAreaContact'] ?? '').trim();
    final phone = (_communication['outOfAreaPhone'] ?? '').trim();

    return en
        ? '''READYSAFE — FAMILY EMERGENCY CARD
Primary meeting place: ${_meeting.text.trim().isEmpty ? 'To define' : _meeting.text.trim()}
Backup meeting place: ${_backup.text.trim().isEmpty ? 'To define' : _backup.text.trim()}
Outside-area meeting place: ${_outsideArea.text.trim().isEmpty ? 'To define' : _outsideArea.text.trim()}
Out-of-area contact: ${contact.isEmpty ? 'To define' : contact}
Phone: ${phone.isEmpty ? 'To define' : phone}
Authorized pickup: ${_authorizedPickup.text.trim().isEmpty ? 'To define' : _authorizedPickup.text.trim()}
Instructions: ${_childInstructions.text.trim().isEmpty ? 'Follow instructions from the responsible adult and use the family plan.' : _childInstructions.text.trim()}'''
        : '''READYSAFE — CARTE FAMILLE URGENCE
Rendez-vous principal : ${_meeting.text.trim().isEmpty ? 'À définir' : _meeting.text.trim()}
Rendez-vous alternatif : ${_backup.text.trim().isEmpty ? 'À définir' : _backup.text.trim()}
Rendez-vous hors quartier : ${_outsideArea.text.trim().isEmpty ? 'À définir' : _outsideArea.text.trim()}
Contact extérieur : ${contact.isEmpty ? 'À définir' : contact}
Téléphone : ${phone.isEmpty ? 'À définir' : phone}
Personne autorisée : ${_authorizedPickup.text.trim().isEmpty ? 'À définir' : _authorizedPickup.text.trim()}
Consignes : ${_childInstructions.text.trim().isEmpty ? 'Suivre les consignes de l’adulte responsable et le plan familial.' : _childInstructions.text.trim()}''';
  }

  Future<void> _copyCard(bool en) async {
    await _save();
    await Clipboard.setData(ClipboardData(text: _walletCard(en)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          en ? 'Family emergency card copied.' : 'Carte famille urgence copiée.',
        ),
      ),
    );
  }

  Future<void> _openSource() async {
    final uri = Uri.parse(
      'https://www.ready.gov/sites/default/files/2020-03/family-emergency-communication-planning-document.pdf',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final progress = _checkItems.isEmpty ? 0.0 : _checks.length / _checkItems.length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Family reunification' : 'Réunification familiale'),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _save,
            icon: Icon(_saved ? Icons.check_rounded : Icons.save_outlined),
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
                            child: Icon(Icons.family_restroom_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              en
                                  ? 'Know where to meet and who can collect children'
                                  : 'Savoir où se retrouver et qui peut récupérer les enfants',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
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
                            ? '${_checks.length} / ${_checkItems.length} reunification points ready'
                            : '${_checks.length} / ${_checkItems.length} points de réunification préparés',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Field(
                  controller: _meeting,
                  icon: Icons.location_on_rounded,
                  label: en ? 'Primary meeting place' : 'Point de rendez-vous principal',
                  hint: en
                      ? 'Near home, easy to identify'
                      : 'Proche du domicile, simple à identifier',
                ),
                _Field(
                  controller: _backup,
                  icon: Icons.alt_route_rounded,
                  label: en ? 'Backup meeting place' : 'Point alternatif',
                  hint: en
                      ? 'If the main place is inaccessible'
                      : 'Si le point principal est inaccessible',
                ),
                _Field(
                  controller: _outsideArea,
                  icon: Icons.public_rounded,
                  label: en ? 'Outside-area meeting place' : 'Point de rendez-vous hors quartier',
                  hint: en
                      ? 'If the neighbourhood cannot be reached'
                      : 'Si le quartier est inaccessible',
                ),
                _Field(
                  controller: _authorizedPickup,
                  icon: Icons.badge_outlined,
                  label: en ? 'Authorized pickup person' : 'Personne autorisée à récupérer l’enfant',
                  hint: en
                      ? 'Name, relationship, useful details'
                      : 'Nom, lien, informations utiles',
                ),
                _Field(
                  controller: _childInstructions,
                  icon: Icons.child_care_rounded,
                  label: en ? 'Simple instructions for children' : 'Consignes simples pour les enfants',
                  hint: en
                      ? 'Who to follow, where to wait, who to call'
                      : 'Qui suivre, où attendre, qui appeler',
                  lines: 3,
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xffe4f2f0),
                      child: Icon(Icons.connect_without_contact_rounded, color: Color(0xff087f83)),
                    ),
                    title: Text(
                      en ? 'Out-of-area contact' : 'Contact extérieur',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      [
                        _communication['outOfAreaContact'] ?? '',
                        _communication['outOfAreaPhone'] ?? '',
                      ].where((value) => value.trim().isNotEmpty).join(' · ').isEmpty
                          ? (en ? 'Not defined yet' : 'Pas encore défini')
                          : [
                              _communication['outOfAreaContact'] ?? '',
                              _communication['outOfAreaPhone'] ?? '',
                            ].where((value) => value.trim().isNotEmpty).join(' · '),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  en ? 'Reunification checklist' : 'Checklist réunification',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                ..._checkItems.map((item) {
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
                        en ? _english(item.id) : item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => _copyCard(en),
                  icon: const Icon(Icons.copy_all_rounded),
                  label: Text(
                    en ? 'Copy family emergency card' : 'Copier la carte famille urgence',
                  ),
                ),
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
                      const Icon(Icons.school_outlined, color: Color(0xff9a6a00)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          en
                              ? 'Know the emergency and release procedures for school, childcare and workplaces. Children without a phone should know to follow instructions from a responsible adult.'
                              : 'Connaissez les procédures d’urgence et de remise des enfants de l’école, de la garde et du travail. Un enfant sans téléphone doit savoir suivre les consignes d’un adulte responsable.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _openSource,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(
                    en
                        ? 'Source: Ready.gov family communication plan'
                        : 'Source : Ready.gov — plan de communication familiale',
                  ),
                ),
              ],
            ),
    );
  }

  String _english(String id) {
    switch (id) {
      case 'written_contacts':
        return 'Important contacts are available on paper';
      case 'school_plan':
        return 'School / childcare emergency plan is known';
      case 'pickup_person':
        return 'Authorized pickup person is identified';
      case 'outside_contact':
        return 'Out-of-area contact is defined';
      case 'meeting_places':
        return 'Primary and backup meeting places are known';
      case 'practice':
        return 'The plan has been explained or practised';
      default:
        return id;
    }
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.icon,
    required this.label,
    required this.hint,
    this.lines = 1,
  });

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hint;
  final int lines;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: controller,
          maxLines: lines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            alignLabelWithHint: lines > 1,
          ),
        ),
      );
}

class _ReunificationCheck {
  const _ReunificationCheck(this.id, this.title, this.icon);
  final String id;
  final String title;
  final IconData icon;
}
