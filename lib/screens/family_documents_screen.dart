import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';
import 'communication_plan_screen.dart';
import 'emergency_plan_summary_screen.dart';
import 'family_screen.dart';
import 'family_reunification_screen.dart';
import 'medical_continuity_screen.dart';
import 'pet_emergency_screen.dart';
import 'secure_vault_screen.dart';
import 'support_needs_screen.dart';

class FamilyDocumentsScreen extends StatefulWidget {
  const FamilyDocumentsScreen({super.key});

  @override
  State<FamilyDocumentsScreen> createState() => _FamilyDocumentsScreenState();
}

class _FamilyDocumentsScreenState extends State<FamilyDocumentsScreen>
    with SingleTickerProviderStateMixin {
  final _storage = LocalStorageService();
  late final TabController _tabs;

  List<Map<String, String>> _contacts = [];
  List<Map<String, dynamic>> _documents = [];
  Map<String, String> _plan = {
    'meetingPoint': '',
    'backupMeetingPoint': '',
    'notes': '',
  };
  Map<String, int> _family = {'adults': 1, 'children': 0, 'care': 0, 'pets': 0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final contacts = await _storage.familyContacts();
    final docs = await _storage.emergencyDocuments();
    final plan = await _storage.familyPlan();
    final family = await _storage.family();
    if (!mounted) return;
    setState(() {
      _contacts = contacts;
      _documents = docs;
      _plan = plan;
      _family = family;
      _loading = false;
    });
  }

  Future<void> _addContact() async {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final name = TextEditingController();
    final role = TextEditingController();
    final phone = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(en ? 'Add a contact' : 'Ajouter un contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: InputDecoration(labelText: en ? 'Name' : 'Nom')),
            const SizedBox(height: 8),
            TextField(controller: role, decoration: InputDecoration(labelText: en ? 'Role / relationship' : 'Rôle / lien')),
            const SizedBox(height: 8),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: en ? 'Phone' : 'Téléphone'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(en ? 'Cancel' : 'Annuler')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              Navigator.pop(context, {
                'name': name.text.trim(),
                'role': role.text.trim(),
                'phone': phone.text.trim(),
              });
            },
            child: Text(en ? 'Add' : 'Ajouter'),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() => _contacts = [..._contacts, result]);
    await _storage.saveFamilyContacts(_contacts);
  }

  Future<void> _editPlan() async {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final primary = TextEditingController(text: _plan['meetingPoint']);
    final backup = TextEditingController(text: _plan['backupMeetingPoint']);
    final notes = TextEditingController(text: _plan['notes']);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(en ? 'Family plan' : 'Plan familial'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: primary,
                decoration: InputDecoration(
                  labelText: en ? 'Primary meeting point' : 'Point de rassemblement principal',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: backup,
                decoration: InputDecoration(
                  labelText: en ? 'Backup meeting point' : 'Point secondaire',
                  prefixIcon: const Icon(Icons.alt_route_rounded),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notes,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: en ? 'Useful notes' : 'Notes utiles',
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(context, {
              'meetingPoint': primary.text.trim(),
              'backupMeetingPoint': backup.text.trim(),
              'notes': notes.text.trim(),
            }),
            child: Text(en ? 'Save' : 'Enregistrer'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final merged = <String, String>{..._plan, ...result};
    setState(() => _plan = merged);
    await _storage.saveFamilyPlan(merged);
  }

  Future<void> _toggleDocument(int index, bool value) async {
    final next = _documents.map((e) => Map<String, dynamic>.from(e)).toList();
    next[index]['ready'] = value;
    setState(() => _documents = next);
    await _storage.saveEmergencyDocuments(next);
  }

  Future<void> _call(String phone) async {
    if (phone.trim().isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: phone.trim()));
  }

  int get _people =>
      (_family['adults'] ?? 0) + (_family['children'] ?? 0) + (_family['care'] ?? 0);

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final readyDocs = _documents.where((d) => d['ready'] == true).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(en ? 'Family & documents' : 'Famille & documents'),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: en ? 'Family' : 'Famille'),
            Tab(text: en ? 'Documents' : 'Documents'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _familyTab(en),
                _documentsTab(readyDocs, en),
              ],
            ),
    );
  }

  Widget _familyTab(bool en) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _hero(
            icon: Icons.family_restroom_rounded,
            title: en ? 'Your household' : 'Votre foyer',
            subtitle: en ? '$_people people · ${_family['pets'] ?? 0} pets' : '$_people personne(s) · ${_family['pets'] ?? 0} animal(aux)',
            actionLabel: en ? 'Edit' : 'Modifier',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilyScreen()),
              );
              await _load();
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffe4f2f0),
                child: Icon(Icons.assignment_turned_in_rounded, color: Color(0xff087f83)),
              ),
              title: Text(en ? 'My emergency plan' : 'Mon plan d’urgence', style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(en ? 'Household, contacts, meeting points, documents and landmarks' : 'Résumé du foyer, contacts, rassemblement, documents et repères'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyPlanSummaryScreen()),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _sectionTitle(en ? 'Family plan' : 'Plan familial', en ? 'A clear place to reconnect' : 'Un lieu clair où se retrouver'),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _editPlan,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xffe4f2f0),
                      child: Icon(Icons.location_on_rounded, color: Color(0xff087f83)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(en ? 'Meeting point' : 'Point de rassemblement', style: const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(
                            (_plan['meetingPoint'] ?? '').isEmpty
                                ? (en ? 'To define' : 'À définir')
                                : _plan['meetingPoint']!,
                            style: const TextStyle(color: Color(0xff65747a)),
                          ),
                          if ((_plan['backupMeetingPoint'] ?? '').isNotEmpty)
                            Text(
                              en ? 'Alternative: ${_plan['backupMeetingPoint']}' : 'Alternative : ${_plan['backupMeetingPoint']}',
                              style: const TextStyle(fontSize: 12, color: Color(0xff65747a)),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffe4f2f0),
                child: Icon(Icons.family_restroom_rounded, color: Color(0xff087f83)),
              ),
              title: Text(en ? 'Family reunification' : 'Réunification familiale', style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(en ? 'Meeting places, child pickup and family emergency card' : 'Rendez-vous, récupération des enfants et carte famille urgence'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilyReunificationScreen()),
              ).then((_) => _load()),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffe4f2f0),
                child: Icon(Icons.connect_without_contact_rounded, color: Color(0xff087f83)),
              ),
              title: Text(en ? 'Communication plan' : 'Plan de communication', style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(en ? 'Out-of-area contact, school/work, reconnection and safe message' : 'Contact extérieur, école/travail, reconnexion et message « Je suis en sécurité »'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunicationPlanScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffe4f2f0),
                child: Icon(Icons.lock_rounded, color: Color(0xff087f83)),
              ),
              title: Text(en ? 'Secure vault' : 'Coffre sécurisé', style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(en ? 'Encrypted sensitive references and notes on the device' : 'Références et notes sensibles chiffrées sur l’appareil'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecureVaultScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffffe7e8),
                child: Icon(Icons.medical_services_rounded, color: Color(0xffd92d36)),
              ),
              title: Text(en ? 'Medical continuity' : 'Continuité médicale', style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(en ? 'Medicines, devices, refrigeration, consumables and regular care' : 'Traitements, appareils, froid, consommables et soins réguliers'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedicalContinuityScreen()),
              ),
            ),
          ),
          if ((_family['pets'] ?? 0) > 0) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xffe5f2e9),
                  child: Icon(Icons.pets_rounded, color: Color(0xff147343)),
                ),
                title: Text(en ? 'Pet plan' : 'Plan animaux', style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(en ? 'Evacuation, transport, shelter, supplies and veterinarian' : 'Évacuation, transport, hébergement, matériel et vétérinaire'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PetEmergencyScreen()),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffe4f2f0),
                child: Icon(Icons.accessibility_new_rounded, color: Color(0xff087f83)),
              ),
              title: Text(en ? 'Support needs' : 'Besoins spécifiques', style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(en ? 'Mobility, hearing, vision, communication, assistance and power dependence' : 'Mobilité, audition, vision, communication, aide et dépendance électrique'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportNeedsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(en ? 'Emergency contacts' : 'Contacts d’urgence', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              TextButton.icon(onPressed: _addContact, icon: const Icon(Icons.add), label: Text(en ? 'Add' : 'Ajouter')),
            ],
          ),
          const SizedBox(height: 6),
          ..._contacts.indexed.map((entry) {
            final index = entry.$1;
            final contact = entry.$2;
            final phone = contact['phone'] ?? '';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xffe4f2f0),
                  child: Text(
                    (contact['name'] ?? '?').trim().isEmpty
                        ? '?'
                        : (contact['name'] ?? '?').trim()[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xff087f83)),
                  ),
                ),
                title: Text(contact['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(
                  [
                    if ((contact['role'] ?? '').isNotEmpty) contact['role'],
                    if (phone.isNotEmpty) phone,
                  ].join(' · '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (phone.isNotEmpty)
                      IconButton(
                        tooltip: en ? 'Call' : 'Appeler',
                        onPressed: () => _call(phone),
                        icon: const Icon(Icons.call_rounded, color: Color(0xff087f83)),
                      ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value != 'delete') return;
                        final next = [..._contacts]..removeAt(index);
                        setState(() => _contacts = next);
                        await _storage.saveFamilyContacts(next);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'delete', child: Text(en ? 'Delete' : 'Supprimer')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffeaf6f4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.offline_bolt_rounded, color: Color(0xff087f83)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    en ? 'The household profile, plan and contacts are stored locally so they remain available offline.' : 'Le profil familial, le plan et les contacts sont conservés localement pour rester accessibles hors ligne.',
                    style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _documentsTab(int readyDocs, bool en) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _hero(
            icon: Icons.folder_copy_rounded,
            title: en ? 'Essential documents' : 'Documents essentiels',
            subtitle: en ? '$readyDocs / ${_documents.length} categories ready' : '$readyDocs / ${_documents.length} catégories préparées',
            actionLabel: en ? 'Offline' : 'Hors ligne',
            onTap: () {},
          ),
          const SizedBox(height: 14),
          Text(
            en ? 'Check what you have prepared' : 'Cochez ce que vous avez préparé',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            en
                ? 'This checklist is stored locally. No private file is uploaded to a server.'
                : 'Cette version gère la checklist documentaire localement. Aucun fichier privé n’est envoyé à un serveur.',
            style: const TextStyle(color: Color(0xff65747a), height: 1.35),
          ),
          const SizedBox(height: 12),
          ..._documents.indexed.map((entry) {
            final index = entry.$1;
            final doc = entry.$2;
            final ready = doc['ready'] == true;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: ready,
                onChanged: (value) => _toggleDocument(index, value ?? false),
                secondary: CircleAvatar(
                  backgroundColor: ready ? const Color(0xffdff2ed) : const Color(0xfffff2df),
                  child: Icon(
                    _docIcon('${doc['id']}'),
                    color: ready ? const Color(0xff087f83) : const Color(0xffb7833f),
                  ),
                ),
                title: Text(_docTitle('${doc['id']}', en, '${doc['title']}'), style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${_docCategory('${doc['id']}', en, '${doc['category']}')} · ${ready ? (en ? 'Ready offline' : 'Prêt hors ligne') : (en ? 'To prepare' : 'À préparer')}'),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffffeeee),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline_rounded, color: Color(0xffd92d36)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    en
                        ? 'The document checklist stays local. Emergency functions remain accessible without unlocking the vault.'
                        : 'La checklist documentaire est locale. Les fonctions d’urgence restent toujours accessibles sans déverrouillage.',
                    style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _hero({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffe3f3f0), Color(0xfffff4e7)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xff087f83),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Color(0xff65747a))),
                ],
              ),
            ),
            TextButton(onPressed: onTap, child: Text(actionLabel)),
          ],
        ),
      );

  Widget _sectionTitle(String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text(subtitle, style: const TextStyle(color: Color(0xff65747a))),
          ],
        ),
      );

  String _docTitle(String id, bool en, String fallback) {
    if (!en) return fallback;
    switch (id) {
      case 'identity':
        return 'Identity documents';
      case 'health':
        return 'Health documents';
      case 'insurance':
        return 'Insurance';
      case 'home':
        return 'Home documents';
      case 'school':
        return 'School documents';
      case 'vehicle':
        return 'Vehicle documents';
      default:
        return fallback;
    }
  }

  String _docCategory(String id, bool en, String fallback) {
    if (!en) return fallback;
    switch (id) {
      case 'identity':
        return 'Identity';
      case 'health':
        return 'Health';
      case 'insurance':
        return 'Protection';
      case 'home':
        return 'Home';
      case 'school':
        return 'Family';
      case 'vehicle':
        return 'Mobility';
      default:
        return fallback;
    }
  }

  IconData _docIcon(String id) {
    switch (id) {
      case 'identity':
        return Icons.badge_outlined;
      case 'health':
        return Icons.medical_information_outlined;
      case 'insurance':
        return Icons.shield_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'vehicle':
        return Icons.directions_car_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}
