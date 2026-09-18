import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/local_storage_service.dart';

class RecoveryLogScreen extends StatefulWidget {
  const RecoveryLogScreen({super.key});

  @override
  State<RecoveryLogScreen> createState() => _RecoveryLogScreenState();
}

class _RecoveryLogScreenState extends State<RecoveryLogScreen> {
  final _storage = LocalStorageService();

  final _eventDate = TextEditingController();
  final _eventType = TextEditingController();
  final _location = TextEditingController();
  final _peopleStatus = TextEditingController();
  final _damageNotes = TextEditingController();
  final _actionsTaken = TextEditingController();
  final _insurance = TextEditingController();
  final _caseNumber = TextEditingController();
  final _contacts = TextEditingController();
  final _followUp = TextEditingController();

  bool _loading = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in [
      _eventDate,
      _eventType,
      _location,
      _peopleStatus,
      _damageNotes,
      _actionsTaken,
      _insurance,
      _caseNumber,
      _contacts,
      _followUp,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final log = await _storage.recoveryLog();
    if (!mounted) return;
    _eventDate.text = log['eventDate'] ?? '';
    _eventType.text = log['eventType'] ?? '';
    _location.text = log['location'] ?? '';
    _peopleStatus.text = log['peopleStatus'] ?? '';
    _damageNotes.text = log['damageNotes'] ?? '';
    _actionsTaken.text = log['actionsTaken'] ?? '';
    _insurance.text = log['insurance'] ?? '';
    _caseNumber.text = log['caseNumber'] ?? '';
    _contacts.text = log['contacts'] ?? '';
    _followUp.text = log['followUp'] ?? '';
    setState(() => _loading = false);
  }

  Map<String, String> _data() => {
        'eventDate': _eventDate.text.trim(),
        'eventType': _eventType.text.trim(),
        'location': _location.text.trim(),
        'peopleStatus': _peopleStatus.text.trim(),
        'damageNotes': _damageNotes.text.trim(),
        'actionsTaken': _actionsTaken.text.trim(),
        'insurance': _insurance.text.trim(),
        'caseNumber': _caseNumber.text.trim(),
        'contacts': _contacts.text.trim(),
        'followUp': _followUp.text.trim(),
      };

  Future<void> _save() async {
    await _storage.saveRecoveryLog(_data());
    if (!mounted) return;
    setState(() => _saved = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _copy(bool en) async {
    await _save();
    final data = _data();
    final text = en
        ? '''READYSAFE — RECOVERY LOG

Event date: ${data['eventDate']}
Event type: ${data['eventType']}
Location: ${data['location']}

PEOPLE
${data['peopleStatus']}

DAMAGE / LOSSES
${data['damageNotes']}

ACTIONS ALREADY TAKEN
${data['actionsTaken']}

INSURANCE / ASSISTANCE
${data['insurance']}
Case / claim number: ${data['caseNumber']}

CONTACTS
${data['contacts']}

FOLLOW-UP
${data['followUp']}'''
        : '''READYSAFE — JOURNAL APRÈS URGENCE

Date de l’événement : ${data['eventDate']}
Type d’événement : ${data['eventType']}
Lieu : ${data['location']}

PERSONNES
${data['peopleStatus']}

DÉGÂTS / PERTES
${data['damageNotes']}

ACTIONS DÉJÀ EFFECTUÉES
${data['actionsTaken']}

ASSURANCE / ASSISTANCE
${data['insurance']}
Numéro de dossier : ${data['caseNumber']}

CONTACTS
${data['contacts']}

SUIVI À FAIRE
${data['followUp']}''';

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(en ? 'Recovery log copied.' : 'Journal après urgence copié.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Recovery log' : 'Journal après urgence'),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xff087f83),
                        child: Icon(Icons.assignment_outlined, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              en
                                  ? 'Keep one clear record after the emergency'
                                  : 'Garder une trace claire après l’urgence',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              en
                                  ? 'Record practical facts, contacts, damage and follow-up while details are still fresh.'
                                  : 'Notez les faits pratiques, contacts, dégâts et suites à donner pendant que les informations sont encore fraîches.',
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
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _eventDate,
                        label: en ? 'Event date' : 'Date de l’événement',
                        icon: Icons.event_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Field(
                        controller: _eventType,
                        label: en ? 'Event type' : 'Type d’événement',
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                  ],
                ),
                _Field(
                  controller: _location,
                  label: en ? 'Location / affected place' : 'Lieu / zone concernée',
                  icon: Icons.location_on_outlined,
                ),
                _Field(
                  controller: _peopleStatus,
                  label: en ? 'People status' : 'Situation des personnes',
                  icon: Icons.groups_outlined,
                  lines: 3,
                  hint: en
                      ? 'Safe, injured, missing, relocated…'
                      : 'En sécurité, blessé, absent, relogé…',
                ),
                _Field(
                  controller: _damageNotes,
                  label: en ? 'Damage / losses' : 'Dégâts / pertes',
                  icon: Icons.home_work_outlined,
                  lines: 5,
                  hint: en
                      ? 'Rooms, equipment, vehicle, documents, supplies…'
                      : 'Pièces, matériel, véhicule, documents, réserves…',
                ),
                _Field(
                  controller: _actionsTaken,
                  label: en ? 'Actions already taken' : 'Actions déjà effectuées',
                  icon: Icons.task_alt_rounded,
                  lines: 4,
                  hint: en
                      ? 'Emergency services, utility shutdown, temporary repairs…'
                      : 'Secours, coupure d’un réseau, réparation provisoire…',
                ),
                _Field(
                  controller: _insurance,
                  label: en ? 'Insurance / assistance' : 'Assurance / assistance',
                  icon: Icons.shield_outlined,
                ),
                _Field(
                  controller: _caseNumber,
                  label: en ? 'Case / claim number' : 'Numéro de dossier',
                  icon: Icons.numbers_rounded,
                ),
                _Field(
                  controller: _contacts,
                  label: en ? 'Useful contacts' : 'Contacts utiles',
                  icon: Icons.contacts_outlined,
                  lines: 3,
                ),
                _Field(
                  controller: _followUp,
                  label: en ? 'Follow-up / next actions' : 'Suivi / prochaines actions',
                  icon: Icons.next_plan_outlined,
                  lines: 5,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => _copy(en),
                  icon: const Icon(Icons.copy_all_rounded),
                  label: Text(
                    en ? 'Copy recovery summary' : 'Copier le résumé de récupération',
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
                      const Icon(Icons.photo_camera_outlined, color: Color(0xff9a6a00)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          en
                              ? 'When safe, photograph damage before moving or disposing of items when this is useful for insurance or authorities. This screen stores text only.'
                              : 'Lorsque cela peut être fait sans danger, photographiez les dégâts avant de déplacer ou jeter des biens si cela peut servir à l’assurance ou aux autorités. Cet écran stocke uniquement du texte.',
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.lines = 1,
    this.hint,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int lines;
  final String? hint;

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
