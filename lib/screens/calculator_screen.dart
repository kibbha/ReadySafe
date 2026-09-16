import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int adults = 1, children = 0, days = 3;
  @override
  Widget build(BuildContext context) {
    final people = adults + children;
    final water = (adults * 3 + children * 2) * days;
    final meals = people * 3 * days;
    return Scaffold(
      appBar: AppBar(title: const Text('Eau & nourriture')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Estimation de préparation',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ces estimations doivent être adaptées à la santé, au climat et aux consignes locales.',
          ),
          _Counter(
            label: 'Adultes',
            value: adults,
            onChange: (v) => setState(() => adults = v),
          ),
          _Counter(
            label: 'Enfants',
            value: children,
            onChange: (v) => setState(() => children = v),
          ),
          _Counter(
            label: 'Jours',
            value: days,
            min: 1,
            onChange: (v) => setState(() => days = v),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('Eau recommandée'),
              subtitle: Text(
                '$water litres pour $people personne(s) pendant $days jour(s)',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Repas recommandés'),
              subtitle: Text(
                '$meals repas à prévoir (3 par personne et par jour)',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.onChange,
    this.min = 0,
  });
  final String label;
  final int value, min;
  final ValueChanged<int> onChange;
  @override
  Widget build(BuildContext c) => ListTile(
    title: Text(label),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: value > min ? () => onChange(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$value',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => onChange(value + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    ),
  );
}
