import 'package:flutter/material.dart';

import '../models/checklist_item.dart';

class KitItemDetailScreen extends StatefulWidget {
  const KitItemDetailScreen({super.key, required this.item, required this.initial, required this.target, required this.unit, required this.icon});
  final ChecklistItem item;
  final KitStockEntry initial;
  final num? target;
  final String unit;
  final IconData icon;

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
  void dispose() { notes.dispose(); super.dispose(); }

  String date(DateTime value) => '${value.day.toString().padLeft(2,'0')}.${value.month.toString().padLeft(2,'0')}.${value.year}';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de l’élément')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Center(child: Container(
            width: 112, height: 112,
            decoration: BoxDecoration(color: const Color(0xffe8f5f5), borderRadius: BorderRadius.circular(28)),
            child: Icon(widget.icon, size: 58, color: const Color(0xff087f83)),
          )),
          const SizedBox(height: 14),
          Text(widget.item.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          if (widget.target != null) ...[
            const SizedBox(height: 12),
            _panel(child: Row(children: [
              const Icon(Icons.recommend_outlined, color: Color(0xff087f83)), const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Quantité recommandée', style: TextStyle(fontSize: 12, color: Color(0xff65747a))),
                Text('${widget.target} ${widget.unit}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ])),
            ])),
          ],
          const SizedBox(height: 18),
          const Text('Ma quantité', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _panel(child: Row(children: [
            IconButton.filledTonal(onPressed: () => setState(() => quantity = quantity > 0 ? quantity - 1 : 0), icon: const Icon(Icons.remove)),
            Expanded(child: Text('$quantity ${widget.unit}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
            IconButton.filled(onPressed: () => setState(() => quantity += 1), icon: const Icon(Icons.add)),
          ])),
          if (widget.item.hasExpiry) ...[
            const SizedBox(height: 18),
            const Text('Date de péremption / rotation', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _panel(child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_outlined, color: Color(0xff087f83)),
              title: Text(expiry == null ? 'Ajouter une date' : date(expiry!)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: expiry ?? DateTime.now().add(const Duration(days: 180)), firstDate: DateTime.now().subtract(const Duration(days: 3650)), lastDate: DateTime.now().add(const Duration(days: 7300)));
                if (picked != null) setState(() => expiry = picked);
              },
            )),
            const SizedBox(height: 10),
            _panel(child: Column(children: [
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Rappel avant expiration', style: TextStyle(fontWeight: FontWeight.w800)), value: reminder, onChanged: (v) => setState(() => reminder = v)),
              if (reminder) DropdownButtonFormField<int>(
                value: reminderDays,
                decoration: const InputDecoration(labelText: 'Me prévenir'),
                items: const [7,14,30,60,90].map((d) => DropdownMenuItem(value: d, child: Text('$d jours avant'))).toList(),
                onChanged: (v) { if (v != null) setState(() => reminderDays = v); },
              ),
            ])),
          ],
          const SizedBox(height: 18),
          const Text('Notes', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          TextField(controller: notes, minLines: 3, maxLines: 5, decoration: const InputDecoration(hintText: 'Ajouter une note…', alignLabelWithHint: true)),
          if (widget.item.notes != null && widget.item.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 8), Text(widget.item.notes!, style: const TextStyle(fontSize: 12, color: Color(0xff65747a))),
          ],
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, value(overrideQuantity: 0)),
              icon: const Icon(Icons.delete_outline), label: const Text('Supprimer'),
            )),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: FilledButton.icon(
              onPressed: () => Navigator.pop(context, value()),
              icon: const Icon(Icons.check), label: const Text('Enregistrer'),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(color: const Color(0xfff4f8f8), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xffe1e9ea))),
    child: child,
  );
}
