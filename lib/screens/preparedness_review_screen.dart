import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';
import 'communication_plan_screen.dart';
import 'family_documents_screen.dart';
import 'medical_continuity_screen.dart';
import 'online_maps_screen.dart';
import 'pet_emergency_screen.dart';
import 'survival_hub_screen.dart';

class PreparednessReviewScreen extends StatefulWidget {
  const PreparednessReviewScreen({super.key});

  @override
  State<PreparednessReviewScreen> createState() => _PreparednessReviewScreenState();
}

class _PreparednessReviewScreenState extends State<PreparednessReviewScreen> {
  final _storage = LocalStorageService();
  Set<String> _checked = {};
  DateTime? _lastReview;
  bool _loading = true;

  static const _items = <_ReviewItem>[
    _ReviewItem(
      'contacts',
      'Contacts familiaux',
      'Les numéros principaux et le contact extérieur sont à jour.',
      Icons.contacts_rounded,
    ),
    _ReviewItem(
      'meeting',
      'Points de rassemblement',
      'Le point principal et l’alternative sont connus de tous.',
      Icons.location_on_rounded,
    ),
    _ReviewItem(
      'documents',
      'Documents essentiels',
      'Les documents importants sont identifiés et accessibles.',
      Icons.folder_copy_rounded,
    ),
    _ReviewItem(
      'kit',
      'Kit & réserves',
      'Eau, nourriture, médicaments et matériel ont été vérifiés.',
      Icons.backpack_rounded,
    ),
    _ReviewItem(
      'power',
      'Énergie & radio',
      'Lampes, piles, batterie externe et radio sont prêtes.',
      Icons.battery_charging_full_rounded,
    ),
    _ReviewItem(
      'alerts',
      'Alertes officielles',
      'Les alertes système et les sources officielles sont connues.',
      Icons.campaign_rounded,
    ),
    _ReviewItem(
      'routes',
      'Évacuation',
      'Au moins un itinéraire principal et une alternative sont connus.',
      Icons.route_rounded,
    ),
    _ReviewItem(
      'needs',
      'Besoins particuliers',
      'Enfants, seniors, traitements, handicap et animaux sont pris en compte.',
      Icons.accessible_forward_rounded,
    ),
    _ReviewItem(
      'medical',
      'Continuité médicale',
      'Traitements, appareils, chaîne du froid et soins réguliers ont un plan de secours.',
      Icons.medical_services_rounded,
    ),
    _ReviewItem(
      'pets',
      'Animaux',
      'Transport, identification, matériel et hébergement ont été envisagés si nécessaire.',
      Icons.pets_rounded,
    ),
    _ReviewItem(
      'practice',
      'Exercice familial',
      'Le foyer a revu ou simulé les actions essentielles.',
      Icons.school_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final checked = await _storage.preparednessReviewChecks();
    final date = await _storage.preparednessReviewDate();
    if (!mounted) return;
    setState(() {
      _checked = checked;
      _lastReview = date;
      _loading = false;
    });
  }

  Future<void> _toggle(String id, bool value) async {
    setState(() {
      value ? _checked.add(id) : _checked.remove(id);
    });
    await _storage.savePreparednessReviewChecks(_checked);
  }

  Future<void> _completeReview() async {
    final now = DateTime.now();
    await _storage.savePreparednessReviewDate(now);
    await _storage.savePreparednessReviewChecks(_checked);
    if (!mounted) return;
    setState(() => _lastReview = now);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Revue de préparation enregistrée.')),
    );
  }

  String _formatDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d.$m.${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _items.isEmpty ? 0.0 : _checked.length / _items.length;
    final nextReview = _lastReview == null
        ? null
        : DateTime(_lastReview!.year + 1, _lastReview!.month, _lastReview!.day);

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: const Text('Revue de préparation')),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xff087f83),
                            child: Icon(Icons.fact_check_rounded, color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Passez tout en revue au moins une fois par an',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          backgroundColor: Colors.white,
                          color: const Color(0xff087f83),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${_checked.length} / ${_items.length} points vérifiés',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      if (_lastReview != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Dernière revue : ${_formatDate(_lastReview!)}'
                          '${nextReview == null ? '' : ' · prochaine : ${_formatDate(nextReview)}'}',
                          style: const TextStyle(color: Color(0xff65747a)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ..._items.map((item) {
                  final checked = _checked.contains(item.id);
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
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(item.subtitle),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _checked.length == _items.length ? _completeReview : null,
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('Marquer la revue comme terminée'),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Raccourcis utiles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickLink(
                      'Kit',
                      Icons.backpack_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SurvivalHubScreen()),
                      ),
                    ),
                    _QuickLink(
                      'Famille',
                      Icons.family_restroom_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FamilyDocumentsScreen()),
                      ),
                    ),
                    _QuickLink(
                      'Communication',
                      Icons.connect_without_contact_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CommunicationPlanScreen()),
                      ),
                    ),
                    _QuickLink(
                      'Santé',
                      Icons.medical_services_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MedicalContinuityScreen()),
                      ),
                    ),
                    _QuickLink(
                      'Animaux',
                      Icons.pets_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PetEmergencyScreen()),
                      ),
                    ),
                    _QuickLink(
                      'Repères',
                      Icons.map_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnlineMapsScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ReviewItem {
  const _ReviewItem(this.id, this.title, this.subtitle, this.icon);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _QuickLink extends StatelessWidget {
  const _QuickLink(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        avatar: Icon(icon, size: 18, color: const Color(0xff087f83)),
        label: Text(label),
        onPressed: onTap,
      );
}
