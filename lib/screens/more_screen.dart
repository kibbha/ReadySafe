import 'package:flutter/material.dart';
import '../app/localizations.dart';
import 'calculator_screen.dart';
import 'checklist_screen.dart';
import 'family_screen.dart';
import 'guide_list_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final items = [
      (
        t.get('disasters'),
        Icons.thunderstorm_outlined,
        const GuideListScreen(kind: GuideKind.disasters),
      ),
      (t.get('kit'), Icons.backpack_outlined, const ChecklistScreen(kit: true)),
      (t.get('checklists'), Icons.checklist, const ChecklistScreen(kit: false)),
      (t.get('waterFood'), Icons.water_drop_outlined, const CalculatorScreen()),
      (t.get('family'), Icons.family_restroom, const FamilyScreen()),
      (t.get('settings'), Icons.settings_outlined, const SettingsScreen()),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(t.get('more'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items
            .map(
              (item) => Card(
                child: ListTile(
                  minTileHeight: 64,
                  leading: Icon(item.$2),
                  title: Text(item.$1),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item.$3),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
