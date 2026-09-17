import 'package:flutter/material.dart';

import '../app/localizations.dart';
import '../data/content.dart';
import '../models/checklist_item.dart';
import '../services/local_storage_service.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key, required this.kit});
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
    final savedStock =
        widget.kit ? await store.kitStock() : <String, KitStockEntry>{};
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
    if (unit.contains('/ enfant')) return base * (family['children'] ?? 0);
    if (unit.contains('/ animal')) return base * pets;
    return base;
  }

  String _unit(ChecklistItem item) => (item.unit ?? '')
      .replaceAll(' / personne', '')
      .replaceAll(' / enfant', '')
      .replaceAll(' / animal', '')
      .replaceAll('par personne', '')
      .trim();

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';

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

  Future<void> _edit(ChecklistItem item) async {
    final current = stock[item.id] ?? KitStockEntry(itemId: item.id);
    final controller =
        TextEditingController(text: current.quantityOwned.toString());
    DateTime? expiry = current.expiryDate;

    final result = await showModalBottomSheet<KitStockEntry>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xffe7f5f5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(_icon(item), color: const Color(0xff087f83)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (_target(item) != null)
                          Text(
                            'Recommandé : ${_target(item)} ${_unit(item)}',
                            style: const TextStyle(color: Color(0xff65747a)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Ma quantité',
                  suffixText: _unit(item),
                ),
              ),
              if (item.hasExpiry) ...[
                const SizedBox(height: 14),
                ListTile(
                  tileColor: const Color(0xfff2f6f7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: Text(
                    expiry == null ? 'Ajouter une date de péremption' : _date(expiry!),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: expiry ??
                          DateTime.now().add(const Duration(days: 180)),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 3650)),
                      lastDate: DateTime.now().add(const Duration(days: 7300)),
                    );
                    if (picked != null) {
                      setSheetState(() => expiry = picked);
                    }
                  },
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    sheetContext,
                    KitStockEntry(
                      itemId: item.id,
                      quantityOwned: num.tryParse(
                            controller.text.replaceAll(',', '.'),
                          ) ??
                          0,
                      expiryDate: expiry,
                      updatedAt: DateTime.now(),
                    ),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (result != null) {
      await store.saveKitStockEntry(result);
      if (mounted) setState(() => stock[item.id] = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final all = widget.kit
        ? kitItems
        : scenarioLists.entries
            .expand(
              (entry) => entry.value.map(
                (label) => ChecklistItem(
                  id: '${entry.key}-$label',
                  label: label,
                  category: entry.key,
                ),
              ),
            )
            .toList();
    final visible = !widget.kit
        ? all
        : all.where((item) {
            if (filter == 1) return !done.contains(item.id);
            if (filter == 2) return item.hasExpiry;
            return true;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kit ? 'Kit d’urgence' : strings.get('checklists')),
      ),
      body: Column(
        children: [
          if (widget.kit)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Column(
                children: [
                  Row(
                    children: List.generate(3, (index) {
                      const labels = ['Tous', 'Manquants', 'Avec DLC'];
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
                    value: all.isEmpty ? 0 : done.length / all.length,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${done.length} / ${all.length} éléments prêts',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '$people pers. • $pets animal(aux)',
                        style: const TextStyle(
                          color: Color(0xff65747a),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            LinearProgressIndicator(
              value: all.isEmpty ? 0 : done.length / all.length,
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final item = visible[index];
                final checked = done.contains(item.id);
                final entry = stock[item.id];
                final target = _target(item);
                final unit = _unit(item);
                final expired = entry?.isExpired ?? false;
                final soon = item.hasExpiry &&
                    (entry?.expiresWithin(item.expiryReminderDays) ?? false);
                final quantity = entry?.quantityOwned ?? 0;
                final quantityText = target == null
                    ? '$quantity $unit'
                    : '$quantity $unit / $target $unit';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: widget.kit ? () => _edit(item) : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
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
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (widget.kit)
                                  Text(
                                    quantityText.trim(),
                                    style: const TextStyle(
                                      color: Color(0xff65747a),
                                    ),
                                  )
                                else
                                  Text(
                                    item.category,
                                    style: const TextStyle(
                                      color: Color(0xff65747a),
                                    ),
                                  ),
                                if (entry?.expiryDate != null)
                                  Text(
                                    '${expired ? 'DLC dépassée' : 'DLC'} : ${_date(entry!.expiryDate!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: expired || soon
                                          ? Theme.of(context).colorScheme.error
                                          : const Color(0xff65747a),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: checked,
                            onChanged: (value) async {
                              final next = value ?? false;
                              setState(() {
                                if (next) {
                                  done.add(item.id);
                                } else {
                                  done.remove(item.id);
                                }
                              });
                              await store.toggle(key, item.id, next);
                            },
                          ),
                          if (widget.kit)
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xff87969a),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
