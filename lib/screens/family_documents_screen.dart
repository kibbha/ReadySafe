import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';
import 'communication_plan_screen.dart';
import 'emergency_plan_summary_screen.dart';
import 'family_screen.dart';
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
    final name = TextEditingController();
    final role = TextEditingController();
    final phone = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom')),
            const SizedBox(height: 8),
            TextField(controller: role, decoration: const InputDecoration(labelText: 'Rôle / lien')),
            const SizedBox(height: 8),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              Navigator.pop(context, {
                'name': name.text.trim(),
                'role': role.text.trim(),
                'phone': phone.text.trim(),
              });
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() => _contacts = [..._contacts, result]);
    await _storage.saveFamilyContacts(_contacts);
  }

  Future<void> _editPlan() async {
    final primary = TextEditingController(text: _plan['meetingPoint']);
    final backup = TextEditingController(text: _plan['backupMeetingPoint']);
    final notes = TextEditingController(text: _plan['notes']);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan familial'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: primary,
                decoration: const InputDecoration(
                  labelText: 'Point de rassemblement principal',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: backup,
                decoration: const InputDecoration(
                  labelText: 'Point secondaire',
                  prefixIcon: Icon(Icons.alt_route_rounded),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes utiles',
                  prefixIcon: Icon(Icons.notes_rounded),
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
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() => _plan = result);
    await _storage.saveFamilyPlan(result);
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
    final readyDocs = _documents.where((d) => d['ready'] == true).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Famille & documents'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Famille'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _familyTab(),
                _documentsTab(readyDocs),
              ],
            ),
    );
  }

  Widget _familyTab() => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _hero(
            icon: Icons.family_restroom_rounded,
            title: 'Votre foyer',
            subtitle: '$_people personne(s) · ${_family['pets'] ?? 0} animal(aux)',
            actionLabel: 'Modifier',
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
              title: const Text('Mon plan d’urgence', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Résumé du foyer, contacts, rassemblement, documents et repères'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyPlanSummaryScreen()),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _sectionTitle('Plan familial', 'Un lieu clair où se retrouver'),
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
                          const Text('Point de rassemblement', style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(
                            (_plan['meetingPoint'] ?? '').isEmpty
                                ? 'À définir'
                                : _plan['meetingPoint']!,
                            style: const TextStyle(color: Color(0xff65747a)),
                          ),
                          if ((_plan['backupMeetingPoint'] ?? '').isNotEmpty)
                            Text(
                              'Alternative : ${_plan['backupMeetingPoint']}',
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
                child: Icon(Icons.connect_without_contact_rounded, color: Color(0xff087f83)),
              ),
              title: const Text('Plan de communication', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Contact extérieur, école/travail, reconnexion et message « Je suis en sécurité »'),
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
              title: const Text('Coffre sécurisé', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Références et notes sensibles chiffrées sur l’appareil'),
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
              title: const Text('Continuité médicale', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Traitements, appareils, froid, consommables et soins réguliers'),
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
                title: const Text('Plan animaux', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Évacuation, transport, hébergement, matériel et vétérinaire'),
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
              title: const Text('Besoins spécifiques', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Mobilité, audition, vision, communication, aide et dépendance électrique'),
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
              const Expanded(
                child: Text('Contacts d’urgence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              TextButton.icon(onPressed: _addContact, icon: const Icon(Icons.add), label: const Text('Ajouter')),
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
                        tooltip: 'Appeler',
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
                        PopupMenuItem(value: 'delete', child: Text('Supprimer')),
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
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.offline_bolt_rounded, color: Color(0xff087f83)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Le profil familial, le plan et les contacts sont conservés localement pour rester accessibles hors ligne.',
                    style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _documentsTab(int readyDocs) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _hero(
            icon: Icons.folder_copy_rounded,
            title: 'Documents essentiels',
            subtitle: '$readyDocs / ${_documents.length} catégories préparées',
            actionLabel: 'Hors ligne',
            onTap: () {},
          ),
          const SizedBox(height: 14),
          const Text(
            'Cochez ce que vous avez préparé',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cette version gère la checklist documentaire localement. Aucun fichier privé n’est envoyé à un serveur.',
            style: TextStyle(color: Color(0xff65747a), height: 1.35),
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
                title: Text('${doc['title']}', style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${doc['category']} · ${ready ? 'Prêt hors ligne' : 'À préparer'}'),
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
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, color: Color(0xffd92d36)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'La checklist documentaire est locale. Les fonctions d’urgence restent toujours accessibles sans déverrouillage.',
                    style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
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
