import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/local_storage_service.dart';
import '../services/secure_vault_service.dart';

class EmergencyPlanSummaryScreen extends StatefulWidget {
  const EmergencyPlanSummaryScreen({super.key});

  @override
  State<EmergencyPlanSummaryScreen> createState() =>
      _EmergencyPlanSummaryScreenState();
}

class _EmergencyPlanSummaryScreenState
    extends State<EmergencyPlanSummaryScreen> {
  final _storage = LocalStorageService();
  final _vault = SecureVaultService();

  Map<String, int> _family = const {
    'adults': 1,
    'children': 0,
    'care': 0,
    'pets': 0,
  };
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
  int _medicalReady = 0;
  int _petReady = 0;
  bool _vaultAvailable = true;
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
    final medicalReady =
        (await _storage.completed('medical_continuity_v3')).length;
    final petReady =
        (await _storage.completed('pet_emergency_v3')).length;

    var vaultCount = 0;
    var vaultAvailable = true;

    try {
      vaultCount = await _vault.count();
    } catch (_) {
      vaultAvailable = false;
    }

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
      _vaultAvailable = vaultAvailable;
      _medicalReady = medicalReady;
      _petReady = petReady;
      _loading = false;
    });
  }

  String _defined(String? value, bool en) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return en ? 'To define' : 'À définir';
    return text;
  }

  String _textExport(bool en) {
    final readyDocs =
        _documents.where((doc) => doc['ready'] == true).length;
    final buffer = StringBuffer();

    if (en) {
      buffer
        ..writeln('READYSAFE — EMERGENCY PLAN')
        ..writeln()
        ..writeln('HOUSEHOLD')
        ..writeln('Adults: ${_family['adults'] ?? 0}')
        ..writeln('Children: ${_family['children'] ?? 0}')
        ..writeln(
          'People with care needs: ${_family['care'] ?? 0}',
        )
        ..writeln('Pets: ${_family['pets'] ?? 0}')
        ..writeln()
        ..writeln('MEETING POINTS')
        ..writeln(
          'Primary: ${_defined(_plan['meetingPoint'], true)}',
        )
        ..writeln(
          'Backup: ${_defined(_plan['backupMeetingPoint'], true)}',
        )
        ..writeln(
          'Outside area: ${_defined(_plan['outsideAreaMeetingPoint'], true)}',
        )
        ..writeln(
          'Authorized child pickup: ${_defined(_plan['authorizedPickup'], true)}',
        );
    } else {
      buffer
        ..writeln('READYSAFE — PLAN D’URGENCE')
        ..writeln()
        ..writeln('FOYER')
        ..writeln('Adultes : ${_family['adults'] ?? 0}')
        ..writeln('Enfants : ${_family['children'] ?? 0}')
        ..writeln(
          'Personnes avec besoins de soins : ${_family['care'] ?? 0}',
        )
        ..writeln('Animaux : ${_family['pets'] ?? 0}')
        ..writeln()
        ..writeln('RASSEMBLEMENT')
        ..writeln(
          'Principal : ${_defined(_plan['meetingPoint'], false)}',
        )
        ..writeln(
          'Alternative : ${_defined(_plan['backupMeetingPoint'], false)}',
        )
        ..writeln(
          'Hors quartier : ${_defined(_plan['outsideAreaMeetingPoint'], false)}',
        )
        ..writeln(
          'Personne autorisée enfant : ${_defined(_plan['authorizedPickup'], false)}',
        );
    }

    final notes = (_plan['notes'] ?? '').trim();
    if (notes.isNotEmpty) {
      buffer.writeln(en ? 'Notes: $notes' : 'Notes : $notes');
    }

    buffer
      ..writeln()
      ..writeln(en ? 'COMMUNICATION' : 'COMMUNICATION')
      ..writeln(
        en
            ? 'Out-of-area contact: ${_defined(_communication['outOfAreaContact'], true)}'
            : 'Contact extérieur : ${_defined(_communication['outOfAreaContact'], false)}',
      )
      ..writeln(
        en
            ? 'Phone: ${_defined(_communication['outOfAreaPhone'], true)}'
            : 'Téléphone : ${_defined(_communication['outOfAreaPhone'], false)}',
      );

    final reconnect =
        (_communication['reconnectNotes'] ?? '').trim();
    if (reconnect.isNotEmpty) {
      buffer.writeln(
        en ? 'Reconnection: $reconnect' : 'Reconnexion : $reconnect',
      );
    }

    final childInstructions =
        (_plan['childInstructions'] ?? '').trim();
    if (childInstructions.isNotEmpty) {
      buffer.writeln(
        en
            ? 'Child instructions: $childInstructions'
            : 'Consignes enfants : $childInstructions',
      );
    }

    buffer
      ..writeln()
      ..writeln(en ? 'CONTACTS' : 'CONTACTS');

    for (final contact in _contacts) {
      final name = (contact['name'] ?? '').trim();
      if (name.isEmpty) continue;

      buffer.writeln(
        '- $name · ${contact['role'] ?? ''} · ${contact['phone'] ?? ''}',
      );
    }

    buffer
      ..writeln()
      ..writeln(en ? 'DOCUMENTS' : 'DOCUMENTS')
      ..writeln(
        en
            ? '$readyDocs / ${_documents.length} categories ready'
            : '$readyDocs / ${_documents.length} catégories préparées',
      )
      ..writeln()
      ..writeln(
        en ? 'PERSONAL LANDMARKS' : 'REPÈRES PERSONNELS',
      );

    if (_markers.isEmpty) {
      buffer.writeln(
        en
            ? '- No personal landmark saved'
            : '- Aucun repère personnel enregistré',
      );
    } else {
      for (final marker in _markers) {
        buffer.writeln(
          '- ${marker['name'] ?? (en ? 'Landmark' : 'Repère')} · '
          '${marker['kind'] ?? 'personal'}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln(
        en
            ? 'ADDITIONAL PREPAREDNESS'
            : 'PRÉPARATION COMPLÉMENTAIRE',
      )
      ..writeln(
        en
            ? 'Support needs considered: ${_supportNeeds.length}'
            : 'Besoins spécifiques pris en compte : ${_supportNeeds.length}',
      )
      ..writeln(
        en
            ? 'Home safety: ${_homeSafetyChecks.length} point(s) checked'
            : 'Sécurité domicile : ${_homeSafetyChecks.length} point(s) vérifié(s)',
      )
      ..writeln(
        en
            ? 'Offline backup: ${_offlineChecks.length} point(s) ready'
            : 'Plan B hors ligne : ${_offlineChecks.length} point(s) prêt(s)',
      )
      ..writeln(
        en
            ? 'Secure-vault entries: ${_vaultAvailable ? _vaultCount : 'unavailable'}'
            : 'Entrées du coffre sécurisé : ${_vaultAvailable ? _vaultCount : 'indisponible'}',
      )
      ..writeln(
        en
            ? 'Medical continuity: $_medicalReady point(s) ready'
            : 'Continuité médicale : $_medicalReady point(s) préparé(s)',
      )
      ..writeln(
        en
            ? 'Pet plan: $_petReady point(s) ready'
            : 'Plan animaux : $_petReady point(s) préparé(s)',
      )
      ..writeln(
        en
            ? 'Last review: ${_reviewDate == null ? 'Not recorded' : _formatDate(_reviewDate!)}'
            : 'Dernière revue : ${_reviewDate == null ? 'Non renseignée' : _formatDate(_reviewDate!)}',
      )
      ..writeln()
      ..writeln(
        en
            ? 'Quick message: ${_communication['safeMessage'] ?? 'I am safe.'}'
            : 'Message rapide : ${_communication['safeMessage'] ?? 'Je suis en sécurité.'}',
      )
      ..writeln()
      ..writeln(
        en
            ? 'Official instructions and emergency-service directions always take priority.'
            : 'Les consignes officielles et celles des services d’urgence priment toujours.',
      );

    return buffer.toString();
  }

  String _formatDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d.$m.${value.year}';
  }

  Future<void> _copyPlan(bool en) async {
    await Clipboard.setData(
      ClipboardData(text: _textExport(en)),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          en ? 'Emergency plan copied.' : 'Plan d’urgence copié.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final readyDocs =
        _documents.where((doc) => doc['ready'] == true).length;
    final phoneContacts = _contacts
        .where(
          (contact) =>
              (contact['phone'] ?? '').trim().isNotEmpty,
        )
        .length;
    final people = (_family['adults'] ?? 0) +
        (_family['children'] ?? 0) +
        (_family['care'] ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(
          en ? 'My emergency plan' : 'Mon plan d’urgence',
        ),
        actions: [
          IconButton(
            tooltip:
                en ? 'Copy plan' : 'Copier le plan',
            onPressed:
                _loading ? null : () => _copyPlan(en),
            icon: const Icon(Icons.copy_all_rounded),
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
                  padding:
                      const EdgeInsets.fromLTRB(14, 4, 14, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffe3f3f0),
                            Color(0xfffff4e8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xff087f83),
                            child: Icon(
                              Icons.assignment_turned_in_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  en
                                      ? 'One operational view for faster action'
                                      : 'Une vue unique pour agir plus vite',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  en
                                      ? 'This summary only uses information prepared in ReadySafe and remains stored locally on the device.'
                                      : 'Ce résumé rassemble uniquement les informations préparées dans ReadySafe et reste stocké localement sur l’appareil.',
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
                    _SummaryCard(
                      icon: Icons.family_restroom_rounded,
                      title: en ? 'Household' : 'Foyer',
                      value: en
                          ? '$people people · ${_family['pets'] ?? 0} pets'
                          : '$people personne(s) · ${_family['pets'] ?? 0} animal(aux)',
                      color: const Color(0xff087f83),
                    ),
                    _SummaryCard(
                      icon: Icons.location_on_rounded,
                      title: en
                          ? 'Meeting point'
                          : 'Point de rassemblement',
                      value: _defined(
                        _plan['meetingPoint'],
                        en,
                      ),
                      color: const Color(0xff147343),
                    ),
                    _SummaryCard(
                      icon: Icons.contacts_rounded,
                      title: en
                          ? 'Reachable contacts'
                          : 'Contacts joignables',
                      value: en
                          ? '$phoneContacts contact(s) with phone number'
                          : '$phoneContacts contact(s) avec téléphone',
                      color: const Color(0xff6750a4),
                    ),
                    _SummaryCard(
                      icon: Icons.folder_copy_rounded,
                      title: en
                          ? 'Documents ready'
                          : 'Documents préparés',
                      value: en
                          ? '$readyDocs / ${_documents.length} categories'
                          : '$readyDocs / ${_documents.length} catégories',
                      color: const Color(0xffb7833f),
                    ),
                    _SummaryCard(
                      icon: Icons.map_rounded,
                      title: en
                          ? 'Personal landmarks'
                          : 'Repères personnels',
                      value: en
                          ? '${_markers.length} landmark(s) saved'
                          : '${_markers.length} repère(s) enregistré(s)',
                      color: const Color(0xff237fc7),
                    ),
                    _SummaryCard(
                      icon: Icons.accessibility_new_rounded,
                      title: en
                          ? 'Support needs'
                          : 'Besoins spécifiques',
                      value: _supportNeeds.isEmpty
                          ? (en
                              ? 'No specific support need saved'
                              : 'Aucun besoin particulier enregistré')
                          : (en
                              ? '${_supportNeeds.length} need(s) considered'
                              : '${_supportNeeds.length} besoin(s) pris en compte'),
                      color: const Color(0xff6750a4),
                    ),
                    _SummaryCard(
                      icon: Icons.home_work_rounded,
                      title:
                          en ? 'Home safety' : 'Sécurité domicile',
                      value: en
                          ? '${_homeSafetyChecks.length} point(s) checked'
                          : '${_homeSafetyChecks.length} point(s) vérifié(s)',
                      color: const Color(0xff4c6d72),
                    ),
                    _SummaryCard(
                      icon: Icons.offline_bolt_rounded,
                      title: en
                          ? 'Offline backup'
                          : 'Plan B hors ligne',
                      value: en
                          ? '${_offlineChecks.length} backup point(s) ready'
                          : '${_offlineChecks.length} sauvegarde(s) externe(s) prête(s)',
                      color: const Color(0xff087f83),
                    ),
                    _SummaryCard(
                      icon: Icons.lock_rounded,
                      title:
                          en ? 'Secure vault' : 'Coffre sécurisé',
                      value: !_vaultAvailable
                          ? (en
                              ? 'Secure storage unavailable'
                              : 'Stockage sécurisé indisponible')
                          : (en
                              ? '$_vaultCount encrypted entrie(s)'
                              : '$_vaultCount entrée(s) chiffrée(s)'),
                      color: const Color(0xff6750a4),
                    ),
                    _SummaryCard(
                      icon: Icons.medical_services_rounded,
                      title: en
                          ? 'Medical continuity'
                          : 'Continuité médicale',
                      value: en
                          ? '$_medicalReady point(s) ready'
                          : '$_medicalReady point(s) préparé(s)',
                      color: const Color(0xffd92d36),
                    ),
                    if ((_family['pets'] ?? 0) > 0)
                      _SummaryCard(
                        icon: Icons.pets_rounded,
                        title:
                            en ? 'Pet plan' : 'Plan animaux',
                        value: en
                            ? '$_petReady point(s) ready'
                            : '$_petReady point(s) préparé(s)',
                        color: const Color(0xff147343),
                      ),
                    _SummaryCard(
                      icon: Icons.fact_check_rounded,
                      title:
                          en ? 'Last review' : 'Dernière revue',
                      value: _reviewDate == null
                          ? (en
                              ? 'Not recorded'
                              : 'Non renseignée')
                          : _formatDate(_reviewDate!),
                      color: const Color(0xff147343),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      en ? 'Communication' : 'Communication',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _Line(
                              label: en
                                  ? 'Out-of-area contact'
                                  : 'Contact extérieur',
                              value: _defined(
                                _communication[
                                    'outOfAreaContact'],
                                en,
                              ),
                            ),
                            _Line(
                              label:
                                  en ? 'Phone' : 'Téléphone',
                              value: _defined(
                                _communication[
                                    'outOfAreaPhone'],
                                en,
                              ),
                            ),
                            _Line(
                              label: en
                                  ? 'Outside-area point'
                                  : 'Hors quartier',
                              value: _defined(
                                _plan[
                                    'outsideAreaMeetingPoint'],
                                en,
                              ),
                            ),
                            _Line(
                              label: en
                                  ? 'Authorized pickup'
                                  : 'Personne autorisée',
                              value: _defined(
                                _plan['authorizedPickup'],
                                en,
                              ),
                            ),
                            _Line(
                              label: en
                                  ? 'Quick message'
                                  : 'Message rapide',
                              value: _defined(
                                _communication['safeMessage'],
                                en,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _copyPlan(en),
                      icon: const Icon(Icons.copy_all_rounded),
                      label: Text(
                        en
                            ? 'Copy complete plan'
                            : 'Copier le plan complet',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      en
                          ? 'You can paste this operational summary into a message, a secure note or print it using another tool.'
                          : 'Vous pouvez ensuite coller ce résumé dans un message, une note sécurisée ou l’imprimer depuis un autre outil.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff65747a),
                        height: 1.35,
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xff9a6a00),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              en
                                  ? 'This summary is intentionally limited to operational information. Medical references and other sensitive data should remain in the secure vault, not in exported text.'
                                  : 'Ce résumé reste volontairement limité aux informations opérationnelles. Les références médicales et autres données sensibles doivent rester dans le coffre sécurisé, pas dans le texte exporté.',
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
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(value),
        ),
      );
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 128,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xff65747a),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}
