import 'package:flutter/material.dart';
import '../app/localizations.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int adults = 1, children = 0, days = 3;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final people = adults + children;
    final water = (adults * 3 + children * 2) * days;
    final meals = people * 3 * days;
    return Scaffold(
      appBar: AppBar(title: Text(t.get('waterFood'))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            t.get('calculator_estimate'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(t.get('calculator_note')),
          _Counter(
            label: t.get('adults'),
            value: adults,
            onChange: (v) => setState(() => adults = v),
          ),
          _Counter(
            label: t.get('children'),
            value: children,
            onChange: (v) => setState(() => children = v),
          ),
          _Counter(
            label: t.get('days'),
            value: days,
            min: 1,
            onChange: (v) => setState(() => days = v),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.water_drop),
              title: Text(t.get('water_result')),
              subtitle: Text(
                t.get('litres_for', {
                  'litres': '$water',
                  'people': '$people',
                  'days': '$days',
                }),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(t.get('meal_result')),
              subtitle: Text(t.get('meals_for', {'meals': '$meals'})),
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
