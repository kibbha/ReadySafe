import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class SpecialKitsScreen extends StatelessWidget {
  const SpecialKitsScreen({super.key});

  static const _kits = <_KitDefinition>[
    _KitDefinition(
      'evacuation',
      'Sac d’évacuation',
      'À emporter rapidement si vous devez quitter le logement.',
      Icons.directions_run_rounded,
      Color(0xffd92d36),
      [
        _KitEntry('water', 'Eau facilement transportable', 'Eau'),
        _KitEntry('food', 'Aliments prêts à consommer', 'Nourriture'),
        _KitEntry('meds', 'Médicaments personnels', 'Santé'),
        _KitEntry('firstaid', 'Petite trousse de premiers secours', 'Santé'),
        _KitEntry('phone', 'Téléphone, câble et batterie externe', 'Énergie'),
        _KitEntry('light', 'Lampe compacte', 'Éclairage'),
        _KitEntry('radio', 'Radio portable si disponible', 'Communication'),
        _KitEntry('docs', 'Copies des documents essentiels', 'Documents'),
        _KitEntry('cash', 'Argent liquide', 'Documents'),
        _KitEntry('clothes', 'Vêtements de rechange et protection météo', 'Protection'),
        _KitEntry('hygiene', 'Hygiène minimale', 'Hygiène'),
        _KitEntry('keys', 'Clés essentielles', 'Documents'),
      ],
    ),
    _KitDefinition(
      'vehicle',
      'Kit véhicule',
      'Pour panne, immobilisation ou déplacement difficile.',
      Icons.directions_car_rounded,
      Color(0xffb7833f),
      [
        _KitEntry('vest', 'Gilet réfléchissant', 'Sécurité'),
        _KitEntry('triangle', 'Triangle de signalisation', 'Sécurité'),
        _KitEntry('firstaid', 'Trousse de premiers secours', 'Santé'),
        _KitEntry('water', 'Eau', 'Eau'),
        _KitEntry('food', 'En-cas longue conservation', 'Nourriture'),
        _KitEntry('blanket', 'Couverture / protection thermique', 'Protection'),
        _KitEntry('light', 'Lampe', 'Éclairage'),
        _KitEntry('power', 'Batterie externe et câble', 'Énergie'),
        _KitEntry('charger', 'Chargeur véhicule', 'Énergie'),
        _KitEntry('gloves', 'Gants de travail', 'Outils'),
        _KitEntry('weather', 'Protection pluie / froid', 'Protection'),
        _KitEntry('map', 'Carte ou itinéraire de secours hors ligne', 'Orientation'),
      ],
    ),
    _KitDefinition(
      'travel',
      'Kit voyage',
      'Documents, santé et continuité lors d’un déplacement.',
      Icons.luggage_rounded,
      Color(0xff6750a4),
      [
        _KitEntry('identity', 'Pièces d’identité et copies', 'Documents'),
        _KitEntry('insurance', 'Assurance et assistance', 'Documents'),
        _KitEntry('meds', 'Médicaments + ordonnances utiles', 'Santé'),
        _KitEntry('contacts', 'Contacts importants hors ligne', 'Communication'),
        _KitEntry('power', 'Batterie externe et adaptateurs', 'Énergie'),
        _KitEntry('cash', 'Moyen de paiement de secours', 'Documents'),
        _KitEntry('water', 'Gourde / eau selon trajet', 'Eau'),
        _KitEntry('light', 'Petite lampe', 'Éclairage'),
        _KitEntry('map', 'Carte hors ligne de la destination', 'Orientation'),
        _KitEntry('embassy', 'Coordonnées consulaires si nécessaire', 'Communication'),
      ],
    ),
    _KitDefinition(
      'children',
      'Kit bébé / enfant',
      'Adapter les réserves au rythme et aux besoins de l’enfant.',
      Icons.child_care_rounded,
      Color(0xffd16a76),
      [
        _KitEntry('food', 'Alimentation adaptée et snacks', 'Nourriture'),
        _KitEntry('water', 'Eau adaptée aux besoins', 'Eau'),
        _KitEntry('diapers', 'Couches / changes si nécessaire', 'Hygiène'),
        _KitEntry('wipes', 'Lingettes et hygiène', 'Hygiène'),
        _KitEntry('clothes', 'Vêtements de rechange', 'Protection'),
        _KitEntry('meds', 'Médicaments prescrits / habituels', 'Santé'),
        _KitEntry('comfort', 'Objet de réconfort', 'Bien-être'),
        _KitEntry('identity', 'Informations et contacts responsables', 'Documents'),
        _KitEntry('carrier', 'Moyen de transport adapté', 'Mobilité'),
      ],
    ),
    _KitDefinition(
      'pets',
      'Kit animaux',
      'Préparer l’évacuation et l’autonomie des animaux du foyer.',
      Icons.pets_rounded,
      Color(0xff147343),
      [
        _KitEntry('food', 'Nourriture habituelle', 'Nourriture'),
        _KitEntry('water', 'Eau supplémentaire', 'Eau'),
        _KitEntry('bowls', 'Gamelles / contenants', 'Nourriture'),
        _KitEntry('lead', 'Laisse, harnais ou caisse de transport', 'Mobilité'),
        _KitEntry('meds', 'Traitements éventuels', 'Santé'),
        _KitEntry('docs', 'Identification / carnet / coordonnées vétérinaires', 'Documents'),
        _KitEntry('waste', 'Sacs et matériel d’hygiène', 'Hygiène'),
        _KitEntry('blanket', 'Couverture ou objet familier', 'Protection'),
      ],
    ),
    _KitDefinition(
      'outdoor',
      'Kit extérieur',
      'Pour randonnée, activité isolée ou déplacement hors réseau.',
      Icons.hiking_rounded,
      Color(0xff4c6d72),
      [
        _KitEntry('water', 'Eau et moyen de traitement adapté', 'Eau'),
        _KitEntry('food', 'Réserve énergétique', 'Nourriture'),
        _KitEntry('navigation', 'Carte, boussole ou navigation hors ligne', 'Orientation'),
        _KitEntry('light', 'Lampe frontale', 'Éclairage'),
        _KitEntry('weather', 'Protection pluie / froid / soleil', 'Protection'),
        _KitEntry('firstaid', 'Trousse de premiers secours', 'Santé'),
        _KitEntry('whistle', 'Sifflet de signalisation', 'Signalisation'),
        _KitEntry('power', 'Batterie externe', 'Énergie'),
        _KitEntry('contacts', 'Itinéraire communiqué à un proche', 'Communication'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(en ? 'Specialized kits' : 'Kits spécialisés')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          return ListView(
            padding: EdgeInsets.fromLTRB(wide ? 22 : 12, 4, wide ? 22 : 12, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffe3f3f0), Color(0xfffff4e8)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xff087f83),
                      child: Icon(Icons.inventory_2_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            en
                                ? 'A different kit for each context'
                                : 'Un kit différent pour chaque contexte',
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            en
                                ? 'The home kit remains the foundation. These lists add evacuation, vehicle, travel, child, pet and outdoor needs.'
                                : 'Le kit domicile reste la base. Ces listes complètent la préparation pour évacuation, voiture, voyage, enfants, animaux et extérieur.',
                            style: const TextStyle(color: Color(0xff65747a), height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _kits.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: wide ? 3 : 2,
                  mainAxisExtent: wide ? 172 : 165,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                ),
                itemBuilder: (context, index) {
                  final kit = _kits[index];
                  return _KitCard(
                    kit: kit,
                    en: en,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => _SpecialKitDetailScreen(kit: kit)),
                    ),
                  );
                },
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
                    const Icon(Icons.tune_rounded, color: Color(0xff9a6a00)),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        en
                            ? 'These lists are starting points. Always add prescribed treatment, assistive equipment, special food and household-specific needs.'
                            : 'Ces listes sont des bases à personnaliser. Ajoutez toujours les traitements, aides techniques, aliments spécifiques et contraintes propres à votre foyer.',
                        style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SpecialKitDetailScreen extends StatefulWidget {
  const _SpecialKitDetailScreen({required this.kit});
  final _KitDefinition kit;

  @override
  State<_SpecialKitDetailScreen> createState() => _SpecialKitDetailScreenState();
}

class _SpecialKitDetailScreenState extends State<_SpecialKitDetailScreen> {
  final _storage = LocalStorageService();
  Set<String> _done = {};

  String get _key => 'special_kit_${widget.kit.id}_v3';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = await _storage.completed(_key);
    if (!mounted) return;
    setState(() => _done = done);
  }

  Future<void> _toggle(String id, bool value) async {
    setState(() {
      value ? _done.add(id) : _done.remove(id);
    });
    await _storage.toggle(_key, id, value);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final ready = widget.kit.items.where((item) => _done.contains(item.id)).length;
    final progress = widget.kit.items.isEmpty ? 0.0 : ready / widget.kit.items.length;

    final grouped = <String, List<_KitEntry>>{};
    for (final item in widget.kit.items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(_kitTitle(widget.kit, en))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: widget.kit.color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: widget.kit.color,
                  child: Icon(widget.kit.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _kitTitle(widget.kit, en),
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(_kitSubtitle(widget.kit, en), style: const TextStyle(color: Color(0xff65747a))),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white,
                          color: widget.kit.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        en ? '$ready / ${widget.kit.items.length} ready' : '$ready / ${widget.kit.items.length} prêts',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final group in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
              child: Text(
                _categoryLabel(group.key, en),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            ...group.value.map((item) {
              final checked = _done.contains(item.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 7),
                child: CheckboxListTile(
                  value: checked,
                  onChanged: (value) => _toggle(item.id, value ?? false),
                  secondary: CircleAvatar(
                    backgroundColor: checked
                        ? const Color(0xffdff2ed)
                        : const Color(0xfffff2df),
                    child: Icon(
                      _categoryIcon(item.category),
                      color: checked
                          ? const Color(0xff087f83)
                          : const Color(0xffb7833f),
                    ),
                  ),
                  title: Text(_itemLabel(widget.kit.id, item, en), style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('eau')) return Icons.water_drop_rounded;
    if (c.contains('nour')) return Icons.restaurant_rounded;
    if (c.contains('sant')) return Icons.medical_services_rounded;
    if (c.contains('énerg')) return Icons.battery_charging_full_rounded;
    if (c.contains('commun')) return Icons.cell_tower_rounded;
    if (c.contains('document')) return Icons.folder_copy_rounded;
    if (c.contains('hygi')) return Icons.clean_hands_rounded;
    if (c.contains('orient')) return Icons.explore_rounded;
    if (c.contains('mobil')) return Icons.directions_walk_rounded;
    if (c.contains('protection')) return Icons.shield_outlined;
    return Icons.inventory_2_outlined;
  }
}

class _KitCard extends StatelessWidget {
  const _KitCard({
    required this.kit,
    required this.en,
    required this.onTap,
  });

  final _KitDefinition kit;
  final bool en;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xffdbe6e7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: kit.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(kit.icon, color: kit.color),
                ),
                const Spacer(),
                Text(
                  _kitTitle(kit, en),
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  _kitSubtitle(kit, en),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xff65747a), height: 1.2),
                ),
              ],
            ),
          ),
        ),
      );
}

String _kitTitle(_KitDefinition kit, bool en) {
  if (!en) return kit.title;
  return const {
        'evacuation': 'Evacuation bag',
        'vehicle': 'Vehicle kit',
        'travel': 'Travel kit',
        'children': 'Baby / child kit',
        'pets': 'Pet kit',
        'outdoor': 'Outdoor kit',
      }[kit.id] ??
      kit.title;
}

String _kitSubtitle(_KitDefinition kit, bool en) {
  if (!en) return kit.subtitle;
  return const {
        'evacuation': 'Ready to grab quickly when you need to leave home.',
        'vehicle': 'For breakdowns, blocked roads or difficult journeys.',
        'travel': 'Documents, health and continuity while away from home.',
        'children': 'Adapt supplies to the child’s age, routine and needs.',
        'pets': 'Prepare evacuation and short-term autonomy for household pets.',
        'outdoor': 'For hiking, isolated activities or travel without network coverage.',
      }[kit.id] ??
      kit.subtitle;
}

String _categoryLabel(String category, bool en) {
  if (!en) return category;
  return const {
        'Eau': 'Water',
        'Nourriture': 'Food',
        'Santé': 'Health',
        'Énergie': 'Power',
        'Éclairage': 'Lighting',
        'Communication': 'Communication',
        'Documents': 'Documents',
        'Protection': 'Protection',
        'Hygiène': 'Hygiene',
        'Sécurité': 'Safety',
        'Outils': 'Tools',
        'Orientation': 'Navigation',
        'Mobilité': 'Mobility',
        'Bien-être': 'Comfort',
        'Signalisation': 'Signalling',
      }[category] ??
      category;
}

String _itemLabel(String kitId, _KitEntry item, bool en) {
  if (!en) return item.label;
  return _itemEnglish['$kitId.${item.id}'] ?? item.label;
}

const _itemEnglish = <String, String>{
  'evacuation.water': 'Portable drinking water',
  'evacuation.food': 'Ready-to-eat food',
  'evacuation.meds': 'Personal medicines',
  'evacuation.firstaid': 'Compact first-aid kit',
  'evacuation.phone': 'Phone, cable and power bank',
  'evacuation.light': 'Compact flashlight',
  'evacuation.radio': 'Portable radio if available',
  'evacuation.docs': 'Copies of essential documents',
  'evacuation.cash': 'Cash',
  'evacuation.clothes': 'Spare clothing and weather protection',
  'evacuation.hygiene': 'Basic hygiene supplies',
  'evacuation.keys': 'Essential keys',
  'vehicle.vest': 'Reflective vest',
  'vehicle.triangle': 'Warning triangle',
  'vehicle.firstaid': 'First-aid kit',
  'vehicle.water': 'Water',
  'vehicle.food': 'Long-life snacks',
  'vehicle.blanket': 'Blanket / thermal protection',
  'vehicle.light': 'Flashlight',
  'vehicle.power': 'Power bank and cable',
  'vehicle.charger': 'Vehicle charger',
  'vehicle.gloves': 'Work gloves',
  'vehicle.weather': 'Rain / cold protection',
  'vehicle.map': 'Offline map or backup route',
  'travel.identity': 'Identity documents and copies',
  'travel.insurance': 'Insurance and assistance',
  'travel.meds': 'Medicines and useful prescriptions',
  'travel.contacts': 'Important offline contacts',
  'travel.power': 'Power bank and adapters',
  'travel.cash': 'Backup payment method',
  'travel.water': 'Water bottle / water for the journey',
  'travel.light': 'Small flashlight',
  'travel.map': 'Offline destination map',
  'travel.embassy': 'Consular contact details when relevant',
  'children.food': 'Age-appropriate food and snacks',
  'children.water': 'Water appropriate to the child’s needs',
  'children.diapers': 'Diapers / changing supplies if needed',
  'children.wipes': 'Wipes and hygiene supplies',
  'children.clothes': 'Spare clothing',
  'children.meds': 'Prescribed / usual medicines',
  'children.comfort': 'Comfort item',
  'children.identity': 'Responsible-adult contacts and child information',
  'children.carrier': 'Suitable transport method',
  'pets.food': 'Usual pet food',
  'pets.water': 'Additional water',
  'pets.bowls': 'Bowls / containers',
  'pets.lead': 'Lead, harness or carrier',
  'pets.meds': 'Required treatment',
  'pets.docs': 'Identification, records and veterinarian contacts',
  'pets.waste': 'Waste bags and hygiene supplies',
  'pets.blanket': 'Blanket or familiar item',
  'outdoor.water': 'Water and suitable treatment method',
  'outdoor.food': 'Energy reserve',
  'outdoor.navigation': 'Map, compass or offline navigation',
  'outdoor.light': 'Headlamp',
  'outdoor.weather': 'Rain / cold / sun protection',
  'outdoor.firstaid': 'First-aid kit',
  'outdoor.whistle': 'Emergency whistle',
  'outdoor.power': 'Power bank',
  'outdoor.contacts': 'Route shared with a trusted person',
};

class _KitDefinition {
  const _KitDefinition(
    this.id,
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.items,
  );

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<_KitEntry> items;
}

class _KitEntry {
  const _KitEntry(this.id, this.label, this.category);
  final String id;
  final String label;
  final String category;
}
