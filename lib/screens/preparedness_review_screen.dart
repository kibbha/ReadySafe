import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';
import 'communication_plan_screen.dart';
import 'family_documents_screen.dart';
import 'family_reunification_screen.dart';
import 'medical_continuity_screen.dart';
import 'online_maps_screen.dart';
import 'pet_emergency_screen.dart';
import 'vehicle_emergency_screen.dart';
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

  List<_ReviewItem> _items(bool en) => <_ReviewItem>[
    _ReviewItem(
      'contacts',
      en ? 'Family contacts' : 'Contacts familiaux',
      en
          ? 'Primary numbers and the out-of-area contact are up to date.'
          : 'Les numéros principaux et le contact extérieur sont à jour.',
      Icons.contacts_rounded,
    ),
    _ReviewItem(
      'meeting',
      en ? 'Meeting points' : 'Points de rassemblement',
      en
          ? 'Everyone knows the primary and backup meeting points.'
          : 'Le point principal et l’alternative sont connus de tous.',
      Icons.location_on_rounded,
    ),
    _ReviewItem(
      'documents',
      en ? 'Essential documents' : 'Documents essentiels',
      en
          ? 'Important documents are identified and accessible.'
          : 'Les documents importants sont identifiés et accessibles.',
      Icons.folder_copy_rounded,
    ),
    _ReviewItem(
      'kit',
      en ? 'Kit & supplies' : 'Kit & réserves',
      en
          ? 'Water, food, medicines and equipment have been checked.'
          : 'Eau, nourriture, médicaments et matériel ont été vérifiés.',
      Icons.backpack_rounded,
    ),
    _ReviewItem(
      'power',
      en ? 'Power & radio' : 'Énergie & radio',
      en
          ? 'Lights, batteries, power banks and radio are ready.'
          : 'Lampes, piles, batterie externe et radio sont prêtes.',
      Icons.battery_charging_full_rounded,
    ),
    _ReviewItem(
      'alerts',
      en ? 'Official alerts' : 'Alertes officielles',
      en
          ? 'System alerts and official information sources are known.'
          : 'Les alertes système et les sources officielles sont connues.',
      Icons.campaign_rounded,
    ),
    _ReviewItem(
      'routes',
      en ? 'Evacuation' : 'Évacuation',
      en
          ? 'At least one main route and one alternative are known.'
          : 'Au moins un itinéraire principal et une alternative sont connus.',
      Icons.route_rounded,
    ),
    _ReviewItem(
      'needs',
      en ? 'Support needs' : 'Besoins particuliers',
      en
          ? 'Children, older adults, medicines, disabilities and pets are considered.'
          : 'Enfants, seniors, traitements, handicap et animaux sont pris en compte.',
      Icons.accessible_forward_rounded,
    ),
    _ReviewItem(
      'reunification',
      en ? 'Family reunification' : 'Réunification familiale',
      en
          ? 'Meeting places, child pickup and the out-of-area contact are ready.'
          : 'Les rendez-vous, la récupération des enfants et le contact extérieur sont prêts.',
      Icons.family_restroom_rounded,
    ),
    _ReviewItem(
      'vehicle',
      en ? 'Vehicle emergency' : 'Urgence véhicule',
      en
          ? 'Vehicle kit, signalling and a backup route have been checked.'
          : 'Le kit véhicule, la signalisation et un itinéraire de secours ont été vérifiés.',
      Icons.directions_car_rounded,
    ),
    _ReviewItem(
      'medical',
      en ? 'Medical continuity' : 'Continuité médicale',
      en
          ? 'Medicines, devices, cold chain and regular care have a backup plan.'
          : 'Traitements, appareils, chaîne du froid et soins réguliers ont un plan de secours.',
      Icons.medical_services_rounded,
    ),
    _ReviewItem(
      'pets',
      en ? 'Pets' : 'Animaux',
      en
          ? 'Transport, identification, supplies and shelter have been considered where relevant.'
          : 'Transport, identification, matériel et hébergement ont été envisagés si nécessaire.',
      Icons.pets_rounded,
    ),
    _ReviewItem(
      'practice',
      en ? 'Household drill' : 'Exercice familial',
      en
          ? 'The household has reviewed or practised the essential actions.'
          : 'Le foyer a revu ou simulé les actions essentielles.',
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
    final en = Localizations.localeOf(context).languageCode == 'en';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(en ? 'Preparedness review saved.' : 'Revue de préparation enregistrée.'),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d.$m.${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final items = _items(en);
    final progress = items.isEmpty ? 0.0 : _checked.length / items.length;
    final nextReview = _lastReview == null
        ? null
        : DateTime(_lastReview!.year + 1, _lastReview!.month, _lastReview!.day);

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(en ? 'Preparedness review' : 'Revue de préparation')),
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
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xff087f83),
                            child: Icon(Icons.fact_check_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              en
                                  ? 'Review everything at least once a year'
                                  : 'Passez tout en revue au moins une fois par an',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                        en
                            ? '${_checked.length} / ${items.length} points checked'
                            : '${_checked.length} / ${items.length} points vérifiés',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      if (_lastReview != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          en
                              ? 'Last review: ${_formatDate(_lastReview!)}'
                                  '${nextReview == null ? '' : ' · next: ${_formatDate(nextReview)}'}'
                              : 'Dernière revue : ${_formatDate(_lastReview!)}'
                                  '${nextReview == null ? '' : ' · prochaine : ${_formatDate(nextReview)}'}',
                          style: const TextStyle(color: Color(0xff65747a)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ...items.map((item) {
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
                  onPressed: _checked.length == items.length ? _completeReview : null,
                  icon: const Icon(Icons.verified_rounded),
                  label: Text(en ? 'Mark review as complete' : 'Marquer la revue comme terminée'),
                ),
                const SizedBox(height: 14),
                Text(
                  en ? 'Useful shortcuts' : 'Raccourcis utiles',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickLink(
                      en ? 'Kit' : 'Kit',
                      Icons.backpack_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SurvivalHubScreen()),
                      ),
                    ),
                    _QuickLink(
                      en ? 'Family' : 'Famille',
                      Icons.family_restroom_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FamilyDocumentsScreen()),
                      ),
                    ),
                    _QuickLink(
                      en ? 'Communication' : 'Communication',
                      Icons.connect_without_contact_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CommunicationPlanScreen()),
                      ),
                    ),
                    _QuickLink(
                      en ? 'Reunification' : 'Réunification',
                      Icons.family_restroom_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FamilyReunificationScreen()),
                      ),
                    ),
                    _QuickLink(
                      en ? 'Vehicle' : 'Véhicule',
                      Icons.directions_car_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VehicleEmergencyScreen()),
                      ),
                    ),
                    _QuickLink(
                      en ? 'Health' : 'Santé',
                      Icons.medical_services_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MedicalContinuityScreen()),
                      ),
                    ),
                    _QuickLink(
                      en ? 'Pets' : 'Animaux',
                      Icons.pets_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PetEmergencyScreen()),
                      ),
                    ),
                    _QuickLink(
                      en ? 'Landmarks' : 'Repères',
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
