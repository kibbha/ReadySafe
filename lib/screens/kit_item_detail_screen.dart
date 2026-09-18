import 'package:flutter/material.dart';

import '../models/checklist_item.dart';

class KitItemDetailScreen extends StatefulWidget {
  const KitItemDetailScreen({
    super.key,
    required this.item,
    required this.initial,
    required this.target,
    required this.unit,
    required this.icon,
    this.displayLabel,
    this.displayNotes,
  });

  final ChecklistItem item;
  final KitStockEntry initial;
  final num? target;
  final String unit;
  final IconData icon;
  final String? displayLabel;
  final String? displayNotes;

  @override
  State<KitItemDetailScreen> createState() => _KitItemDetailScreenState();
}

class _KitItemDetailScreenState extends State<KitItemDetailScreen> {
  late num quantity;
  DateTime? expiry;
  late bool reminder;
  late int reminderDays;
  late final TextEditingController notes;

  @override
  void initState() {
    super.initState();
    quantity = widget.initial.quantityOwned;
    expiry = widget.initial.expiryDate;
    reminder = widget.initial.reminderEnabled;
    reminderDays = widget.initial.reminderDays;
    notes = TextEditingController(text: widget.initial.notes);
  }

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  String date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';

  KitStockEntry value({num? overrideQuantity}) => KitStockEntry(
        itemId: widget.item.id,
        quantityOwned: overrideQuantity ?? quantity,
        expiryDate: expiry,
        updatedAt: DateTime.now(),
        notes: notes.text.trim(),
        reminderEnabled: reminder,
        reminderDays: reminderDays,
      );

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final label = widget.displayLabel ?? widget.item.label;
    final referenceNotes = widget.displayNotes ?? widget.item.notes;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Item details' : 'Détails de l’élément'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              Center(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: const Color(0xffe8f5f5),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 58,
                    color: const Color(0xff087f83),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (widget.target != null) ...[
                const SizedBox(height: 12),
                _panel(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.recommend_outlined,
                        color: Color(0xff087f83),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              en ? 'Recommended quantity' : 'Quantité recommandée',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xff65747a),
                              ),
                            ),
                            Text(
                              '${widget.target} ${widget.unit}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                en ? 'My quantity' : 'Ma quantité',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              _panel(
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => setState(
                        () => quantity = quantity > 0 ? quantity - 1 : 0,
                      ),
                      icon: const Icon(Icons.remove),
                    ),
                    Expanded(
                      child: Text(
                        '$quantity ${widget.unit}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => setState(() => quantity += 1),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              if (widget.item.hasExpiry) ...[
                const SizedBox(height: 18),
                Text(
                  en ? 'Expiry / rotation date' : 'Date de péremption / rotation',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                _panel(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xff087f83),
                    ),
                    title: Text(
                      expiry == null
                          ? (en ? 'Add a date' : 'Ajouter une date')
                          : date(expiry!),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: expiry ??
                            DateTime.now().add(const Duration(days: 180)),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 3650)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 7300)),
                      );
                      if (picked != null) {
                        setState(() => expiry = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _panel(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          en
                              ? 'Reminder before expiry'
                              : 'Rappel avant expiration',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        value: reminder,
                        onChanged: (value) {
                          setState(() => reminder = value);
                        },
                      ),
                      if (reminder)
                        DropdownButtonFormField<int>(
                          initialValue: reminderDays,
                          decoration: InputDecoration(
                            labelText: en ? 'Notify me' : 'Me prévenir',
                          ),
                          items: [7, 14, 30, 60, 90]
                              .map(
                                (days) => DropdownMenuItem(
                                  value: days,
                                  child: Text(
                                    en
                                        ? '$days days before'
                                        : '$days jours avant',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => reminderDays = value);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                en ? 'Notes' : 'Notes',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notes,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: en ? 'Add a note…' : 'Ajouter une note…',
                  alignLabelWithHint: true,
                ),
              ),
              if (referenceNotes != null &&
                  referenceNotes.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xffeaf6f4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 19,
                        color: Color(0xff087f83),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          referenceNotes,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff4f6267),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () =>
                          Navigator.pop(context, value(overrideQuantity: 0)),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(en ? 'Remove' : 'Supprimer'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, value()),
                      icon: const Icon(Icons.check),
                      label: Text(en ? 'Save' : 'Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xfff4f8f8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffe1e9ea)),
        ),
        child: child,
      );
}
