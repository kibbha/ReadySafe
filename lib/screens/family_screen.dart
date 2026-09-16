import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Famille')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Profil familial local',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'N’enregistrez que ce qui vous aide à préparer votre foyer. Aucune donnée n’est envoyée à un serveur.',
          ),
          ...['adults', 'children', 'care', 'pets'].map(
            (key) => ListTile(
              title: Text(
                {
                  'adults': 'Adultes',
                  'children': 'Enfants',
                  'care': 'Personnes nécessitant une attention particulière',
                  'pets': 'Animaux domestiques',
                }[key]!,
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
            label: const Text('Enregistrer localement'),
          ),
          if (saved)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Profil enregistré hors ligne.'),
            ),
        ],
      ),
    );
  }
}
