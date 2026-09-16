import 'package:flutter/material.dart';
import '../app/localizations.dart';
import '../services/local_storage_service.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});
  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final storage = LocalStorageService();
  Map<String, int> values = {'adults': 1, 'children': 0, 'care': 0, 'pets': 0};
  bool saved = false;
  @override
  void initState() {
    super.initState();
    storage.family().then((v) {
      if (mounted) setState(() => values = v);
    });
  }

  Future<void> _save() async {
    await storage.saveFamily(values);
    if (mounted) setState(() => saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.get('family'))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            t.get('family_profile'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(t.get('family_privacy')),
          ...['adults', 'children', 'care', 'pets'].map(
            (key) => ListTile(
              title: Text(
                t.get(
                  {
                    'adults': 'adults',
                    'children': 'children',
                    'care': 'care_people',
                    'pets': 'pets',
                  }[key]!,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: values[key]! > 0
                        ? () => setState(() => values[key] = values[key]! - 1)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('${values[key]}'),
                  IconButton(
                    onPressed: () =>
                        setState(() => values[key] = values[key]! + 1),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(t.get('save_local')),
          ),
          if (saved)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(t.get('saved_offline')),
            ),
        ],
      ),
    );
  }
}
