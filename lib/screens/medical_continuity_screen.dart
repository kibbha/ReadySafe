import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';
import 'secure_vault_screen.dart';

class MedicalContinuityScreen extends StatefulWidget {
  const MedicalContinuityScreen({super.key});

  @override
  State<MedicalContinuityScreen> createState() => _MedicalContinuityScreenState();
}

class _MedicalContinuityScreenState extends State<MedicalContinuityScreen> {
  final _storage = LocalStorageService();
  Set<String> _done = {};
  bool _loading = true;

  static const _items = <_MedicalItem>[
    _MedicalItem(
      'med_list',
      'Liste des traitements',
      'Nom des médicaments, dosage, horaires et allergies disponibles sous une forme sûre.',
      Icons.medication_outlined,
    ),
    _MedicalItem(
      'prescriptions',
      'Ordonnances / références',
      'Une copie ou les références utiles sont accessibles en cas de déplacement.',
      Icons.receipt_long_outlined,
    ),
    _MedicalItem(
      'pharmacy',
      'Pharmacie et prescripteur',
      'Coordonnées du pharmacien, médecin ou service habituel connues.',
      Icons.local_pharmacy_outlined,
    ),
    _MedicalItem(
      'reserve',
      'Réserve autorisée',
      'Une réserve adaptée existe lorsque le traitement et la réglementation le permettent.',
      Icons.inventory_2_outlined,
    ),
    _MedicalItem(
      'cold_chain',
      'Plan chaîne du froid',
      'Les médicaments nécessitant du froid ont un plan de conservation et de remplacement.',
      Icons.ac_unit_rounded,
    ),
    _MedicalItem(
      'device_power',
      'Appareils médicaux électriques',
      'Batteries, autonomie, câbles, alimentation de secours et mode manuel sont connus.',
      Icons.electrical_services_rounded,
    ),
    _MedicalItem(
      'consumables',
      'Consommables médicaux',
      'Capteurs, bandelettes, sondes, seringues ou autres consommables nécessaires sont prévus.',
      Icons.medical_information_outlined,
    ),
    _MedicalItem(
      'transport',
      'Transport / traitement régulier',
      'Une solution existe pour rejoindre dialyse, traitement ou consultation indispensable.',
      Icons.local_hospital_outlined,
    ),
    _MedicalItem(
      'backup_location',
      'Lieu de secours',
      'Un lieu pouvant fournir électricité, froid ou soins essentiels est identifié.',
      Icons.location_on_outlined,
    ),
    _MedicalItem(
      'caregiver',
      'Aidant / personne de confiance',
      'Une personne connaît les besoins pratiques et peut aider si nécessaire.',
      Icons.volunteer_activism_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = await _storage.completed('medical_continuity_v3');
    if (!mounted) return;
    setState(() {
      _done = done;
      _loading = false;
    });
  }

  Future<void> _toggle(String id, bool value) async {
    setState(() {
      value ? _done.add(id) : _done.remove(id);
    });
    await _storage.toggle('medical_continuity_v3', id, value);
  }

  Future<void> _openSource() async {
    final uri = Uri.parse('https://www.cdc.gov/prepare-your-health/take-action/');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final validIds = _items.map((item) => item.id).toSet();
    final readyCount = _done.intersection(validIds).length;
    final progress =
        _items.isEmpty ? 0.0 : readyCount / _items.length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Medical continuity' : 'Continuité médicale'),
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
                      colors: [Color(0xffffeeee), Color(0xffe4f3f0)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xffd92d36),
                            child: Icon(Icons.medical_services_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              en
                                  ? 'Keep essential treatment working through an emergency'
                                  : 'Maintenir les soins indispensables pendant une urgence',
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
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
                            ? '$readyCount / ${_items.length} continuity points ready'
                            : '$readyCount / ${_items.length} points de continuité préparés',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff4c7),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xff9a6a00)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          en
                              ? 'Do not change, stop, split or replace a prescribed treatment because of this checklist. Ask the prescriber or pharmacist how your medicines and devices should be handled during an emergency.'
                              : 'Ne modifiez, n’arrêtez, ne fractionnez ou ne remplacez pas un traitement prescrit à cause de cette checklist. Demandez au prescripteur ou au pharmacien comment gérer vos médicaments et appareils en situation d’urgence.',
                          style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ..._items.map((item) {
                  final checked = _done.contains(item.id);
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
                        en ? _medicalTitleEn(item.id) : item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        en ? _medicalSubtitleEn(item.id) : item.subtitle,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xffe9e5f5),
                      child: Icon(Icons.lock_rounded, color: Color(0xff6750a4)),
                    ),
                    title: Text(
                      en ? 'Secure references in the vault' : 'Sécuriser les références dans le coffre',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      en
                          ? 'Keep prescription references, providers and practical notes encrypted on the device.'
                          : 'Conserver références d’ordonnance, soignants et notes pratiques chiffrées sur l’appareil.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecureVaultScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _openSource,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(
                    en
                        ? 'Source: CDC Prepare Your Health'
                        : 'Source : CDC Prepare Your Health',
                  ),
                ),
              ],
            ),
    );
  }
}

String _medicalTitleEn(String id) {
  return const {
        'med_list': 'Treatment list',
        'prescriptions': 'Prescriptions / references',
        'pharmacy': 'Pharmacy & prescriber',
        'reserve': 'Authorized reserve',
        'cold_chain': 'Cold-chain plan',
        'device_power': 'Powered medical devices',
        'consumables': 'Medical consumables',
        'transport': 'Transport / regular treatment',
        'backup_location': 'Backup location',
        'caregiver': 'Caregiver / trusted person',
      }[id] ??
      id;
}

String _medicalSubtitleEn(String id) {
  return const {
        'med_list': 'Medicine names, doses, schedules and allergies are available in a safe form.',
        'prescriptions': 'A copy or useful prescription references are accessible when away from home.',
        'pharmacy': 'Pharmacist, doctor or usual care-service contact details are known.',
        'reserve': 'An appropriate reserve exists when the treatment and local rules allow it.',
        'cold_chain': 'Medicines requiring refrigeration have a storage and replacement plan.',
        'device_power': 'Battery autonomy, cables, backup power and manual options are known.',
        'consumables': 'Sensors, test strips, syringes or other required consumables are planned.',
        'transport': 'A solution exists to reach dialysis, treatment or another essential appointment.',
        'backup_location': 'A place able to provide electricity, refrigeration or essential care is identified.',
        'caregiver': 'A trusted person knows the practical needs and can help when required.',
      }[id] ??
      '';
}

class _MedicalItem {
  const _MedicalItem(this.id, this.title, this.subtitle, this.icon);

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
