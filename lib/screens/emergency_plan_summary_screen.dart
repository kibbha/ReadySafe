import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/local_storage_service.dart';
import '../services/secure_vault_service.dart';

class EmergencyPlanSummaryScreen extends StatefulWidget {
  const EmergencyPlanSummaryScreen({super.key});

  @override
  State<EmergencyPlanSummaryScreen> createState() => _EmergencyPlanSummaryScreenState();
}

class _EmergencyPlanSummaryScreenState extends State<EmergencyPlanSummaryScreen> {
  final _storage = LocalStorageService();
  final _vault = SecureVaultService();

  Map<String, int> _family = const {'adults': 1, 'children': 0, 'care': 0, 'pets': 0};
  List<Map<String, String>> _contacts = [];
  List<Map<String, dynamic>> _documents = [];
  Map<String, String> _plan = {};
  Map<String, String> _communication = {};
  List<Map<String, dynamic>> _markers = [];
  Set<String> _supportNeeds = {};
  Set<String> _homeSafetyChecks = {};
  Set<String> _offlineChecks = {};
  DateTime? _reviewDate;
  int _vaultCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final family = await _storage.family();
    final contacts = await _storage.familyContacts();
    final documents = await _storage.emergencyDocuments();
    final plan = await _storage.familyPlan();
    final communication = await _storage.communicationPlan();
    final markers = await _storage.safetyMarkers();
    final supportNeeds = await _storage.supportNeeds();
    final homeSafetyChecks = await _storage.homeSafetyChecks();
    final offlineChecks = await _storage.offlineReadinessChecks();
    final reviewDate = await _storage.preparednessReviewDate();
    final vaultCount = await _vault.count();

    if (!mounted) return;
    setState(() {
      _family = family;
      _contacts = contacts;
      _documents = documents;
      _plan = plan;
      _communication = communication;
      _markers = markers;
      _supportNeeds = supportNeeds;
      _homeSafetyChecks = homeSafetyChecks;
      _offlineChecks = offlineChecks;
      _reviewDate = reviewDate;
      _vaultCount = vaultCount;
      _loading = false;
    });
  }

  String _textExport() {
    final readyDocs = _documents.where((doc) => doc['ready'] == true).length;
    final buffer = StringBuffer()
      ..writeln('READYSAFE — PLAN D’URGENCE')
      ..writeln()
      ..writeln('FOYER')
      ..writeln('Adultes : ${_family['adults'] ?? 0}')
      ..writeln('Enfants : ${_family['children'] ?? 0}')
      ..writeln('Personnes avec besoins de soins : ${_family['care'] ?? 0}')
      ..writeln('Animaux : ${_family['pets'] ?? 0}')
      ..writeln()
      ..writeln('RASSEMBLEMENT')
      ..writeln('Principal : ${(_plan['meetingPoint'] ?? '').isEmpty ? 'À définir' : _plan['meetingPoint']}')
      ..writeln('Alternative : ${(_plan['backupMeetingPoint'] ?? '').isEmpty ? 'À définir' : _plan['backupMeetingPoint']}');

    final notes = (_plan['notes'] ?? '').trim();
    if (notes.isNotEmpty) buffer.writeln('Notes : $notes');

    buffer
      ..writeln()
      ..writeln('COMMUNICATION')
      ..writeln('Contact extérieur : ${(_communication['outOfAreaContact'] ?? '').isEmpty ? 'À définir' : _communication['outOfAreaContact']}')
      ..writeln('Téléphone : ${(_communication['outOfAreaPhone'] ?? '').isEmpty ? 'À définir' : _communication['outOfAreaPhone']}');

    final reconnect = (_communication['reconnectNotes'] ?? '').trim();
    if (reconnect.isNotEmpty) buffer.writeln('Reconnexion : $reconnect');

    buffer
      ..writeln()
      ..writeln('CONTACTS');
    for (final contact in _contacts) {
      final name = (contact['name'] ?? '').trim();
      if (name.isEmpty) continue;
      buffer.writeln('- $name · ${contact['role'] ?? ''} · ${contact['phone'] ?? ''}');
    }

    buffer
      ..writeln()
      ..writeln('DOCUMENTS')
      ..writeln('$readyDocs / ${_documents.length} catégories préparées')
      ..writeln()
      ..writeln('REPÈRES PERSONNELS');

    if (_markers.isEmpty) {
      buffer.writeln('- Aucun repère personnel enregistré');
    } else {
      for (final marker in _markers) {
        buffer.writeln('- ${marker['name'] ?? 'Repère'} · ${marker['kind'] ?? 'personal'}');
      }
    }

    buffer
      ..writeln()
      ..writeln('PRÉPARATION COMPLÉMENTAIRE')
      ..writeln('Besoins spécifiques pris en compte : ${_supportNeeds.length}')
      ..writeln('Sécurité domicile : ${_homeSafetyChecks.length} point(s) vérifié(s)')
      ..writeln('Plan B hors ligne : ${_offlineChecks.length} point(s) prêt(s)')
      ..writeln('Entrées du coffre sécurisé : $_vaultCount')
      ..writeln('Dernière revue : ${_reviewDate == null ? 'Non renseignée' : _formatDate(_reviewDate!)}')
      ..writeln()
      ..writeln('Message rapide : ${_communication['safeMessage'] ?? 'Je suis en sécurité.'}')
      ..writeln()
      ..writeln('Les consignes officielles et celles des services d’urgence priment toujours.');

    return buffer.toString();
  }

  String _formatDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d.$m.${value.year}';
  }

  Future<void> _copyPlan() async {
    await Clipboard.setData(ClipboardData(text: _textExport()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan d’urgence copié.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readyDocs = _documents.where((doc) => doc['ready'] == true).length;
    final phoneContacts = _contacts.where((contact) => (contact['phone'] ?? '').trim().isNotEmpty).length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: const Text('Mon plan d’urgence'),
        actions: [
          IconButton(
            tooltip: 'Copier le plan',
            onPressed: _loading ? null : _copyPlan,
            icon: const Icon(Icons.copy_all_rounded),
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
                      colors: [Color(0xffe3f3f0), Color(0xfffff4e8)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xff087f83),
                        child: Icon(Icons.assignment_turned_in_rounded, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Une vue unique pour agir plus vite',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ce résumé rassemble uniquement les informations préparées dans ReadySafe et reste stocké localement sur l’appareil.',
                              style: TextStyle(color: Color(0xff65747a), height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SummaryCard(
                  icon: Icons.family_restroom_rounded,
                  title: 'Foyer',
                  value:
                      '${(_family['adults'] ?? 0) + (_family['children'] ?? 0) + (_family['care'] ?? 0)} personne(s) · ${_family['pets'] ?? 0} animal(aux)',
                  color: const Color(0xff087f83),
                ),
                _SummaryCard(
                  icon: Icons.location_on_rounded,
                  title: 'Point de rassemblement',
                  value: (_plan['meetingPoint'] ?? '').isEmpty
                      ? 'À définir'
                      : _plan['meetingPoint']!,
                  color: const Color(0xff147343),
                ),
                _SummaryCard(
                  icon: Icons.contacts_rounded,
                  title: 'Contacts joignables',
                  value: '$phoneContacts contact(s) avec téléphone',
                  color: const Color(0xff6750a4),
                ),
                _SummaryCard(
                  icon: Icons.folder_copy_rounded,
                  title: 'Documents préparés',
                  value: '$readyDocs / ${_documents.length} catégories',
                  color: const Color(0xffb7833f),
                ),
                _SummaryCard(
                  icon: Icons.map_rounded,
                  title: 'Repères personnels',
                  value: '${_markers.length} repère(s) enregistré(s)',
                  color: const Color(0xff237fc7),
                ),
                _SummaryCard(
                  icon: Icons.accessibility_new_rounded,
                  title: 'Besoins spécifiques',
                  value: _supportNeeds.isEmpty
                      ? 'Aucun besoin particulier enregistré'
                      : '${_supportNeeds.length} besoin(s) pris en compte',
                  color: const Color(0xff6750a4),
                ),
                _SummaryCard(
                  icon: Icons.home_work_rounded,
                  title: 'Sécurité domicile',
                  value: '${_homeSafetyChecks.length} point(s) vérifié(s)',
                  color: const Color(0xff4c6d72),
                ),
                _SummaryCard(
                  icon: Icons.offline_bolt_rounded,
                  title: 'Plan B hors ligne',
                  value: '${_offlineChecks.length} sauvegarde(s) externe(s) prête(s)',
                  color: const Color(0xff087f83),
                ),
                _SummaryCard(
                  icon: Icons.lock_rounded,
                  title: 'Coffre sécurisé',
                  value: '$_vaultCount entrée(s) chiffrée(s)',
                  color: const Color(0xff6750a4),
                ),
                _SummaryCard(
                  icon: Icons.fact_check_rounded,
                  title: 'Dernière revue',
                  value: _reviewDate == null
                      ? 'Non renseignée'
                      : _formatDate(_reviewDate!),
                  color: const Color(0xff147343),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Communication',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Line(
                          label: 'Contact extérieur',
                          value: (_communication['outOfAreaContact'] ?? '').isEmpty
                              ? 'À définir'
                              : _communication['outOfAreaContact']!,
                        ),
                        _Line(
                          label: 'Téléphone',
                          value: (_communication['outOfAreaPhone'] ?? '').isEmpty
                              ? 'À définir'
                              : _communication['outOfAreaPhone']!,
                        ),
                        _Line(
                          label: 'Message rapide',
                          value: (_communication['safeMessage'] ?? '').isEmpty
                              ? 'À définir'
                              : _communication['safeMessage']!,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _copyPlan,
                  icon: const Icon(Icons.copy_all_rounded),
                  label: const Text('Copier le plan complet'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vous pouvez ensuite coller ce résumé dans un message, une note sécurisée ou l’imprimer depuis un autre outil.',
                  style: TextStyle(fontSize: 12, color: Color(0xff65747a), height: 1.35),
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
                      Icon(Icons.lock_outline_rounded, color: Color(0xff9a6a00)),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'N’ajoutez pas de données médicales sensibles à ce résumé tant que le coffre chiffré ReadySafe n’est pas activé.',
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(value),
        ),
      );
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xff65747a)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
