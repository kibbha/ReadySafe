import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';
import 'special_kits_screen.dart';

class PetEmergencyScreen extends StatefulWidget {
  const PetEmergencyScreen({super.key});

  @override
  State<PetEmergencyScreen> createState() => _PetEmergencyScreenState();
}

class _PetEmergencyScreenState extends State<PetEmergencyScreen> {
  final _storage = LocalStorageService();
  Set<String> _done = {};
  bool _loading = true;

  static const _items = <_PetItem>[
    _PetItem(
      'id',
      'Identification',
      'Puce, médaille ou autre identification à jour, avec coordonnées correctes.',
      Icons.badge_outlined,
    ),
    _PetItem(
      'carrier',
      'Transport sécurisé',
      'Caisse, laisse, harnais ou autre moyen adapté immédiatement accessible.',
      Icons.pets_rounded,
    ),
    _PetItem(
      'food_water',
      'Nourriture & eau',
      'Réserve adaptée et récipients prévus dans le kit.',
      Icons.restaurant_outlined,
    ),
    _PetItem(
      'meds',
      'Traitements et besoins particuliers',
      'Médicaments, régime, matériel ou soins spécifiques préparés.',
      Icons.medical_services_outlined,
    ),
    _PetItem(
      'vet',
      'Vétérinaire',
      'Coordonnées du vétérinaire habituel et d’une solution de secours accessibles.',
      Icons.local_hospital_outlined,
    ),
    _PetItem(
      'shelter',
      'Hébergement compatible',
      'Au moins une solution existe si un centre d’hébergement n’accepte pas les animaux.',
      Icons.home_work_outlined,
    ),
    _PetItem(
      'documents',
      'Documents',
      'Carnet, vaccinations, photo récente et informations utiles disponibles.',
      Icons.folder_copy_outlined,
    ),
    _PetItem(
      'sanitation',
      'Hygiène & déchets',
      'Sacs, litière ou autres besoins d’hygiène sont intégrés au départ.',
      Icons.cleaning_services_outlined,
    ),
    _PetItem(
      'buddy',
      'Personne relais',
      'Une personne de confiance peut récupérer ou aider avec l’animal si vous êtes absent.',
      Icons.groups_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = await _storage.completed('pet_emergency_v3');
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
    await _storage.toggle('pet_emergency_v3', id, value);
  }

  Future<void> _openSource() async {
    final uri = Uri.parse('https://www.ready.gov/pets');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final progress = _items.isEmpty ? 0.0 : _done.length / _items.length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Pets in an emergency' : 'Animaux en situation d’urgence'),
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
                      colors: [Color(0xffe8f4f2), Color(0xfffff3df)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xff147343),
                            child: Icon(Icons.pets_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              en
                                  ? 'Plan evacuation and shelter before you need them'
                                  : 'Prévoir évacuation et hébergement avant d’en avoir besoin',
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
                          color: const Color(0xff147343),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        en
                            ? '${_done.length} / ${_items.length} points ready'
                            : '${_done.length} / ${_items.length} points préparés',
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
                              ? 'Pets may not be admitted to every emergency shelter. Service animals are treated differently in many jurisdictions. Check local rules before an emergency.'
                              : 'Les animaux ne sont pas admis dans tous les centres d’hébergement. Les animaux d’assistance relèvent souvent de règles différentes. Vérifiez les règles locales avant une urgence.',
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
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(item.subtitle),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xffe5f2e9),
                      child: Icon(Icons.inventory_2_rounded, color: Color(0xff147343)),
                    ),
                    title: Text(
                      en ? 'Open pet kit' : 'Ouvrir le kit animaux',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      en
                          ? 'Food, water, transport, medicines and hygiene.'
                          : 'Nourriture, eau, transport, traitements et hygiène.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SpecialKitsScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _openSource,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(en ? 'Source: Ready.gov pets' : 'Source : Ready.gov — animaux'),
                ),
              ],
            ),
    );
  }
}

class _PetItem {
  const _PetItem(this.id, this.title, this.subtitle, this.icon);

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
