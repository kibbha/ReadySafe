import 'package:flutter/material.dart';

import '../app/localizations.dart';
import '../data/content.dart';
import '../models/checklist_item.dart';
import '../services/local_storage_service.dart';
import 'kit_item_detail_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({
    super.key,
    required this.kit,
  });

  final bool kit;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final store = LocalStorageService();

  Set<String> done = {};
  Map<String, KitStockEntry> stock = {};
  Map<String, int> family = const {
    'adults': 1,
    'children': 0,
    'care': 0,
    'pets': 0,
  };

  int filter = 0;
  late final String key;

  @override
  void initState() {
    super.initState();
    key = widget.kit ? 'kit72' : 'scenarios';
    _load();
  }

  Future<void> _load() async {
    final completed = await store.completed(key);
    final savedStock = widget.kit
        ? await store.kitStock()
        : <String, KitStockEntry>{};
    final savedFamily = widget.kit ? await store.family() : family;

    if (!mounted) return;
    setState(() {
      done = completed;
      stock = savedStock;
      family = savedFamily;
    });
  }

  int get people =>
      (family['adults'] ?? 0) +
      (family['children'] ?? 0) +
      (family['care'] ?? 0);

  int get pets => family['pets'] ?? 0;

  num? _target(ChecklistItem item) {
    final base = item.recommendedQuantity;
    if (base == null) return null;

    final unit = item.unit ?? '';
    if (unit.contains('/ personne') || unit.contains('par personne')) {
      return base * (people == 0 ? 1 : people);
    }
    if (unit.contains('/ enfant')) {
      return base * (family['children'] ?? 0);
    }
    if (unit.contains('/ animal')) {
      return base * pets;
    }
    return base;
  }

  String _rawUnit(ChecklistItem item) => (item.unit ?? '')
      .replaceAll(' / personne', '')
      .replaceAll(' / enfant', '')
      .replaceAll(' / animal', '')
      .replaceAll('par personne', '')
      .trim();

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';

  bool _ready(ChecklistItem item) {
    final entry = stock[item.id];
    if (entry == null || entry.isExpired) return false;

    final target = _target(item);
    if (target == null) {
      return entry.quantityOwned > 0 || done.contains(item.id);
    }
    return entry.quantityOwned >= target;
  }

  IconData _icon(ChecklistItem item) {
    final text = item.label.toLowerCase();
    if (text.contains('eau')) return Icons.water_drop_outlined;
    if (text.contains('nourrit') || text.contains('aliment')) {
      return Icons.lunch_dining_outlined;
    }
    if (text.contains('lampe')) return Icons.flashlight_on_outlined;
    if (text.contains('batter') || text.contains('power')) {
      return Icons.battery_charging_full;
    }
    if (text.contains('radio')) return Icons.radio_outlined;
    if (text.contains('médic')) return Icons.medication_outlined;
    if (text.contains('document')) return Icons.description_outlined;
    if (text.contains('hygiène')) return Icons.sanitizer_outlined;
    return Icons.inventory_2_outlined;
  }

  IconData _categoryIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('eau') || c.contains('nour')) {
      return Icons.restaurant_outlined;
    }
    if (c.contains('lumi') || c.contains('énerg')) {
      return Icons.bolt_outlined;
    }
    if (c.contains('commun')) return Icons.cell_tower_outlined;
    if (c.contains('sant') || c.contains('secour')) {
      return Icons.medical_services_outlined;
    }
    if (c.contains('document')) return Icons.folder_copy_outlined;
    if (c.contains('hygi')) return Icons.clean_hands_outlined;
    return Icons.inventory_2_outlined;
  }

  Future<void> _edit(ChecklistItem item, bool en) async {
    final current = stock[item.id] ??
        KitStockEntry(
          itemId: item.id,
          reminderDays: item.expiryReminderDays,
        );

    final result = await Navigator.of(context).push<KitStockEntry>(
      MaterialPageRoute(
        builder: (_) => KitItemDetailScreen(
          item: item,
          initial: current,
          target: _target(item),
          unit: _displayUnit(item, en),
          icon: _icon(item),
          displayLabel: _kitLabel(item, en),
          displayNotes: _kitNotes(item, en),
        ),
      ),
    );

    if (result == null) return;
    await store.saveKitStockEntry(result);
    if (!mounted) return;

    setState(() => stock[item.id] = result);
  }

  List<ChecklistItem> _scenarioItems(bool en) {
    final items = <ChecklistItem>[];
    for (final entry in scenarioLists.entries) {
      for (final label in entry.value) {
        items.add(
          ChecklistItem(
            id: '${entry.key}-$label',
            label: en ? _scenarioItemEnglish[label] ?? label : label,
            category:
                en ? _scenarioCategoryEnglish[entry.key] ?? entry.key : entry.key,
          ),
        );
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';

    if (!widget.kit) {
      final all = _scenarioItems(en);
      final complete = done.intersection(all.map((item) => item.id).toSet()).length;

      return Scaffold(
        backgroundColor: const Color(0xfff7faf9),
        appBar: AppBar(title: Text(strings.get('checklists'))),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          en
                              ? '$complete / ${all.length} scenario checks complete'
                              : '$complete / ${all.length} points scénario vérifiés',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        '${all.isEmpty ? 0 : ((complete / all.length) * 100).round()}%',
                        style: const TextStyle(
                          color: Color(0xff087f83),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                    value: all.isEmpty ? 0 : complete / all.length,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                itemCount: all.length,
                itemBuilder: (context, index) {
                  final item = all[index];
                  final checked = done.contains(item.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 7),
                    child: CheckboxListTile(
                      value: checked,
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
                      title: Text(
                        item.label,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(item.category),
                      onChanged: (value) async {
                        final next = value ?? false;
                        setState(() {
                          next ? done.add(item.id) : done.remove(item.id);
                        });
                        await store.toggle(key, item.id, next);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    final all = kitItems;
    final readyCount = all.where(_ready).length;
    final visible = all.where((item) {
      if (filter == 1) return !_ready(item);
      if (filter == 2) return item.hasExpiry;
      return true;
    }).toList();

    final categories = <String, List<ChecklistItem>>{};
    for (final item in visible) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Emergency kit' : 'Kit d’urgence'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: Column(
              children: [
                Row(
                  children: List.generate(3, (index) {
                    final labels = en
                        ? const ['All', 'Missing', 'With expiry']
                        : const ['Tous', 'Manquants', 'Avec DLC'];

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < 2 ? 6 : 0),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Center(child: Text(labels[index])),
                          selected: filter == index,
                          onSelected: (_) => setState(() => filter = index),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: all.isEmpty ? 0 : readyCount / all.length,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        en
                            ? '$readyCount / ${all.length} items ready'
                            : '$readyCount / ${all.length} éléments prêts',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      en
                          ? '$people people · $pets pets'
                          : '$people pers. · $pets animal(aux)',
                      style: const TextStyle(
                        color: Color(0xff65747a),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 24),
              children: [
                for (final group in categories.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 12, 5, 7),
                    child: Row(
                      children: [
                        Icon(
                          _categoryIcon(group.key),
                          size: 19,
                          color: const Color(0xff087f83),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          _categoryLabel(group.key, en),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff33454b),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...group.value.map((item) {
                    final entry = stock[item.id];
                    final target = _target(item);
                    final unit = _displayUnit(item, en);
                    final expired = entry?.isExpired ?? false;
                    final soon = item.hasExpiry &&
                        (entry?.expiresWithin(entry.reminderDays) ?? false);
                    final quantity = entry?.quantityOwned ?? 0;
                    final ready = _ready(item);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 7),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _edit(item, en),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: expired || soon
                                      ? const Color(0xffffeeee)
                                      : const Color(0xffe8f5f5),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  _icon(item),
                                  color: expired || soon
                                      ? Theme.of(context).colorScheme.error
                                      : const Color(0xff087f83),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _kitLabel(item, en),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      target == null
                                          ? '$quantity $unit'
                                          : '$quantity $unit / $target $unit',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff65747a),
                                      ),
                                    ),
                                    if (entry?.expiryDate != null)
                                      Text(
                                        '${expired ? (en ? 'Expired' : 'DLC dépassée') : (en ? 'Expiry' : 'DLC')} : ${_date(entry!.expiryDate!)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: expired || soon
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .error
                                              : const Color(0xff65747a),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: ready
                                      ? const Color(0xff087f83)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ready
                                        ? const Color(0xff087f83)
                                        : const Color(0xffb8c6c9),
                                    width: 2,
                                  ),
                                ),
                                child: ready
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xff87969a),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _kitLabel(ChecklistItem item, bool en) {
    if (!en) return item.label;
    return _kitLabelsEn[item.id] ?? item.label;
  }

  String? _kitNotes(ChecklistItem item, bool en) {
    if (!en) return item.notes;
    return _kitNotesEn[item.id] ?? item.notes;
  }

  String _categoryLabel(String category, bool en) {
    if (!en) return category;
    return _categoryEnglish[category] ?? category;
  }

  String _displayUnit(ChecklistItem item, bool en) {
    final raw = _rawUnit(item);
    if (!en) return raw;
    return _unitEnglish[raw] ?? raw;
  }
}

const _scenarioCategoryEnglish = <String, String>{
  'Évacuation': 'Evacuation',
  'Incendie': 'Fire',
  'Panne électrique': 'Power outage',
  'Voyage': 'Travel',
  'Catastrophe naturelle': 'Natural disaster',
  'Voiture': 'Vehicle',
  'Maison': 'Home',
  'Famille': 'Family',
};

const _scenarioItemEnglish = <String, String>{
  'Kit d’urgence': 'Emergency kit',
  'Documents': 'Documents',
  'Médicaments': 'Medicines',
  'Itinéraire': 'Route',
  'Sorties identifiées': 'Exits identified',
  'Détecteurs testés': 'Alarms tested',
  'Point de rassemblement': 'Meeting point',
  'Lampes': 'Lights',
  'Batteries': 'Batteries',
  'Réfrigérateur fermé': 'Refrigerator kept closed',
  'Assurance': 'Insurance',
  'Copies de documents': 'Document copies',
  'Kit voiture': 'Vehicle kit',
  'Alertes activées': 'Alerts enabled',
  'Eau': 'Water',
  'Plan familial': 'Family plan',
  'Carburant': 'Fuel',
  'Gilet réfléchissant': 'Reflective vest',
  'Trousse': 'First-aid kit',
  'Extincteur': 'Fire extinguisher',
  'Détecteurs': 'Alarms',
  'Coupures connues': 'Utility shutoffs known',
  'Contacts': 'Contacts',
  'Point de rencontre': 'Meeting point',
  'Besoins particuliers': 'Special needs',
};

const _categoryEnglish = <String, String>{
  'Eau': 'Water',
  'Nourriture': 'Food',
  'Santé': 'Health',
  'Éclairage': 'Lighting',
  'Énergie': 'Power',
  'Communication': 'Communication',
  'Documents & argent': 'Documents & cash',
  'Hygiène': 'Hygiene',
  'Protection': 'Protection',
  'Outils': 'Tools',
  'Signalisation': 'Signalling',
  'Abri': 'Shelter',
  'Orientation': 'Navigation',
  'Besoins spécifiques': 'Support needs',
  'Enfants': 'Children',
  'Animaux': 'Pets',
};

const _unitEnglish = <String, String>{
  'L': 'L',
  'jours': 'days',
  'réserve': 'reserve',
  'trousse': 'kit',
  'flacon': 'bottle',
  'lampe': 'light',
  'jeu': 'set',
  'batterie': 'power bank',
  'radio': 'radio',
  'liste': 'list',
  'kit': 'kit',
  'paire': 'pair',
  'outil': 'tool',
  'rouleau': 'roll',
  'sifflet': 'whistle',
  'rouleau / bâche': 'sheet / roll',
};

const _kitLabelsEn = <String, String>{
  'water': 'Drinking water',
  'food': 'Long-life food',
  'pet_food': 'Pet food',
  'medication': 'Essential personal medicines',
  'firstaid': 'First-aid kit',
  'disinfectant': 'Suitable antiseptic / disinfectant',
  'light': 'Flashlight or headlamp',
  'batteries': 'Suitable spare batteries',
  'powerbank': 'Charged power bank',
  'cables': 'Essential charging cables',
  'radio': 'Battery or hand-crank radio',
  'cash': 'Cash in small denominations',
  'docs': 'Protected copies of essential documents',
  'contacts': 'Paper list of important contacts',
  'hygiene': 'Personal hygiene kit',
  'toilet_paper': 'Toilet paper and strong bags',
  'clothes': 'Warm spare clothing',
  'blanket': 'Blanket or sleeping bag',
  'rain': 'Rain protection',
  'gloves': 'Work gloves',
  'multitool': 'Multi-tool',
  'tape': 'Strong adhesive tape',
  'whistle': 'Emergency whistle',
  'masks': 'Protective masks appropriate to the situation',
  'plastic_sheeting': 'Strong plastic sheeting or tarp',
  'wrench': 'Utility shutoff wrench or pliers',
  'can_opener': 'Manual can opener',
  'paper_maps': 'Paper maps of the local area',
  'spare_keys': 'Spare essential keys',
  'assistive': 'Personal assistive items and spare batteries',
  'lighter': 'Moisture-protected ignition source',
  'children': 'Baby / child-specific supplies',
  'pet_gear': 'Lead, carrier and pet-specific supplies',
};

const _kitNotesEn = <String, String>{
  'water': 'Basic drinking-water reserve for roughly three days.',
  'medication': 'Store according to the label and prescription. Do not change treatment without professional advice.',
  'wrench': 'Use utility shutoff tools only if you know how to isolate the service safely.',
  'assistive': 'Glasses, hearing aids, communication devices or other personal support items.',
};
