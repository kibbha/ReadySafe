import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../services/local_storage_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _storage = LocalStorageService();

  int adults = 1;
  int children = 0;
  int care = 0;
  int days = 4;
  double litresPerPersonDay = 3;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadFamily();
    }
  }

  Future<void> _loadFamily() async {
    final family = await _storage.family();
    if (!mounted) return;
    setState(() {
      adults = family['adults'] ?? 1;
      children = family['children'] ?? 0;
      care = family['care'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final country = AppScope.of(context).activeCountry;
    final isSwitzerland = country?.isoCode == 'CH';
    final people = adults + children + care;
    final effectivePeople = people == 0 ? 1 : people;
    final water = effectivePeople * litresPerPersonDay * days;
    final meals = effectivePeople * 3 * days;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(title: Text(t.get('waterFood'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffe4f3f0), Color(0xfffff4e8)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xff237fc7),
                  child: Icon(Icons.water_drop_rounded, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Autonomie eau & nourriture',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Estimez un stock de départ puis adaptez-le aux besoins réels de votre foyer, au climat et aux recommandations locales.',
                        style: TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Votre foyer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
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
            label: 'Personnes avec besoins de soins',
            value: care,
            onChange: (v) => setState(() => care = v),
          ),
          const SizedBox(height: 12),
          const Text('Durée cible', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in const [3, 4, 7, 14])
                ChoiceChip(
                  label: Text('$value jours'),
                  selected: days == value,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => days = value),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Hypothèse eau',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${litresPerPersonDay.toStringAsFixed(1)} L / personne / jour',
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xff237fc7)),
          ),
          Slider(
            value: litresPerPersonDay,
            min: 2,
            max: 5,
            divisions: 6,
            label: '${litresPerPersonDay.toStringAsFixed(1)} L',
            onChanged: (value) => setState(() => litresPerPersonDay = value),
          ),
          const Text(
            'Ce réglage est un outil d’estimation, pas une prescription universelle. Augmentez selon chaleur, activité, grossesse, allaitement ou autres besoins particuliers.',
            style: TextStyle(fontSize: 12, color: Color(0xff65747a), height: 1.35),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ResultCard(
                  icon: Icons.water_drop_rounded,
                  title: 'Eau',
                  value: '${water.toStringAsFixed(water.truncateToDouble() == water ? 0 : 1)} L',
                  subtitle: '$effectivePeople personne(s) · $days jours',
                  color: const Color(0xff237fc7),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _ResultCard(
                  icon: Icons.restaurant_rounded,
                  title: 'Repas',
                  value: '$meals',
                  subtitle: 'équivalents repas',
                  color: const Color(0xffb7833f),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isSwitzerland)
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xfffff4c7),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.flag_outlined, color: Color(0xff9a6a00)),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Référence Suisse : Alertswiss recommande au moins 9 litres d’eau par personne pour 3–4 jours et des denrées alimentaires pour environ une semaine. Adaptez toujours le stock aux besoins personnels.',
                      style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xffeaf6f4),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xff087f83)),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Consultez les recommandations officielles de votre pays pour confirmer la quantité et la durée de réserve adaptées.',
                      style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('À ne pas oublier', style: TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  _Tip('Prévoir des aliments consommables sans cuisson.'),
                  _Tip('Faire tourner les stocks dans la consommation quotidienne.'),
                  _Tip('Contrôler régulièrement les dates de péremption.'),
                  _Tip('Prévoir séparément les besoins des animaux.'),
                  _Tip('Conserver une marge pour les besoins particuliers et les visiteurs éventuels.'),
                ],
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
  final int value;
  final int min;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 7),
        child: ListTile(
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: value > min ? () => onChange(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: () => onChange(value + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
      );

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffdbe6e7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: color),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11.5, color: Color(0xff65747a)),
            ),
          ],
        ),
      );
}

class _Tip extends StatelessWidget {
  const _Tip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xff087f83)),
            const SizedBox(width: 7),
            Expanded(child: Text(text, style: const TextStyle(height: 1.3))),
          ],
        ),
      );
}
