import 'package:flutter/material.dart';
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
  late final String key;
  @override
  void initState() {
    super.initState();
    key = widget.kit ? 'kit72' : 'scenarios';
    store.completed(key).then((v) {
      if (mounted) setState(() => done = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.kit
        ? kitItems
        : scenarioLists.entries
              .expand(
                (e) => e.value.map(
                  (x) => ChecklistItem(
                    id: '${e.key}-$x',
                    label: x,
                    category: e.key,
                  ),
                ),
              )
              .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kit ? 'Kit d’urgence 72 h' : 'Check-lists'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: items.isEmpty ? 0 : done.length / items.length,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('${done.length} / ${items.length} éléments prêts'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final checked = done.contains(item.id);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (v) async {
                    setState(
                      () =>
                          v == true ? done.add(item.id) : done.remove(item.id),
                    );
                    await store.toggle(key, item.id, v ?? false);
                  },
                  title: Text(item.label),
                  subtitle: Text(item.category),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
