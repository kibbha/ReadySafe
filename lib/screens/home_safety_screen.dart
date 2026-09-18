import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class HomeSafetyScreen extends StatefulWidget {
  const HomeSafetyScreen({super.key});

  @override
  State<HomeSafetyScreen> createState() => _HomeSafetyScreenState();
}

class _HomeSafetyScreenState extends State<HomeSafetyScreen> {
  final _storage = LocalStorageService();

  final _water = TextEditingController();
  final _gas = TextEditingController();
  final _electric = TextEditingController();
  final _primaryExit = TextEditingController();
  final _secondaryExit = TextEditingController();
  final _safeRoom = TextEditingController();

  Set<String> _checks = {};
  bool _loading = true;
  bool _saved = false;

  static const _checkItems = <_SafetyCheck>[
    _SafetyCheck(
      'smoke',
      'Détecteurs de fumée',
      'Présents, accessibles et testés régulièrement.',
      Icons.detector_smoke_rounded,
    ),
    _SafetyCheck(
      'co',
      'Détection monoxyde de carbone',
      'Prévue si le logement et les équipements concernés le justifient.',
      Icons.co2_rounded,
    ),
    _SafetyCheck(
      'extinguisher',
      'Extincteur / couverture anti-feu',
      'Présent si adapté et son utilisation est comprise.',
      Icons.fire_extinguisher_rounded,
    ),
    _SafetyCheck(
      'flashlight',
      'Éclairage de secours',
      'Une lampe est accessible sans devoir traverser le logement dans le noir.',
      Icons.flashlight_on_rounded,
    ),
    _SafetyCheck(
      'keys',
      'Clés accessibles',
      'Les clés de sortie et doubles utiles sont connus.',
      Icons.key_rounded,
    ),
    _SafetyCheck(
      'routes',
      'Deux sorties possibles',
      'Un itinéraire principal et une alternative sont identifiés.',
      Icons.alt_route_rounded,
    ),
    _SafetyCheck(
      'utilities',
      'Coupures techniques repérées',
      'Eau, gaz et électricité sont localisés, sans supposer qu’il faut les couper.',
      Icons.settings_input_component_rounded,
    ),
    _SafetyCheck(
      'assembly',
      'Point extérieur',
      'Un point de rassemblement hors du bâtiment est défini.',
      Icons.groups_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _water.dispose();
    _gas.dispose();
    _electric.dispose();
    _primaryExit.dispose();
    _secondaryExit.dispose();
    _safeRoom.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final plan = await _storage.homeSafetyPlan();
    final checks = await _storage.homeSafetyChecks();

    if (!mounted) return;

    _water.text = plan['waterShutoff'] ?? '';
    _gas.text = plan['gasShutoff'] ?? '';
    _electric.text = plan['electricPanel'] ?? '';
    _primaryExit.text = plan['primaryExit'] ?? '';
    _secondaryExit.text = plan['secondaryExit'] ?? '';
    _safeRoom.text = plan['safeRoom'] ?? '';

    setState(() {
      _checks = checks;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await _storage.saveHomeSafetyPlan({
      'waterShutoff': _water.text.trim(),
      'gasShutoff': _gas.text.trim(),
      'electricPanel': _electric.text.trim(),
      'primaryExit': _primaryExit.text.trim(),
      'secondaryExit': _secondaryExit.text.trim(),
      'safeRoom': _safeRoom.text.trim(),
    });

    await _storage.saveHomeSafetyChecks(_checks);

    if (!mounted) return;

    setState(() => _saved = true);

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final validIds = _checkItems.map((item) => item.id).toSet();
    final ready = _checks.intersection(validIds).length;
    final progress =
        _checkItems.isEmpty ? 0.0 : ready / _checkItems.length;

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Home safety' : 'Sécurité du domicile'),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _save,
            icon: Icon(
              _saved ? Icons.check_rounded : Icons.save_outlined,
            ),
            label: Text(
              _saved
                  ? (en ? 'Saved' : 'Enregistré')
                  : (en ? 'Save' : 'Enregistrer'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffe4f3f0),
                            Color(0xfffff4e8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xff087f83),
                                child: Icon(
                                  Icons.home_work_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  en
                                      ? 'Identify key points before you need them'
                                      : 'Repérer avant d’en avoir besoin',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.white,
                              color: const Color(0xff087f83),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            en
                                ? '$ready / ${_checkItems.length} safety points checked'
                                : '$ready / ${_checkItems.length} points vérifiés',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      en ? 'Utility locations' : 'Repères techniques',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _Field(
                      controller: _water,
                      icon: Icons.water_drop_outlined,
                      label: en ? 'Water shutoff' : 'Arrivée d’eau',
                      hint: en
                          ? 'E.g. utility closet, basement…'
                          : 'Ex. placard technique, sous-sol…',
                    ),
                    _Field(
                      controller: _gas,
                      icon: Icons.local_fire_department_outlined,
                      label: en ? 'Gas shutoff' : 'Arrivée de gaz',
                      hint: en
                          ? 'Leave blank if not applicable'
                          : 'Laisser vide si non concerné',
                    ),
                    _Field(
                      controller: _electric,
                      icon: Icons.electrical_services_outlined,
                      label: en ? 'Electrical panel' : 'Tableau électrique',
                      hint: en
                          ? 'E.g. entrance, basement…'
                          : 'Ex. entrée, cave…',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      en ? 'Exits & safe indoor area' : 'Sorties et zone sûre',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _Field(
                      controller: _primaryExit,
                      icon: Icons.exit_to_app_rounded,
                      label: en ? 'Primary exit' : 'Sortie principale',
                      hint: en ? 'E.g. front door' : 'Ex. porte d’entrée',
                    ),
                    _Field(
                      controller: _secondaryExit,
                      icon: Icons.alt_route_rounded,
                      label: en ? 'Alternative exit' : 'Sortie alternative',
                      hint: en
                          ? 'E.g. courtyard, accessible balcony, other stairs…'
                          : 'Ex. cour, balcon accessible, autre escalier…',
                    ),
                    _Field(
                      controller: _safeRoom,
                      icon: Icons.shield_outlined,
                      label: en
                          ? 'Safest indoor area'
                          : 'Zone intérieure la plus sûre',
                      hint: en
                          ? 'Define according to local hazards and the building'
                          : 'À définir selon les risques locaux et le logement',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      en ? 'Safety checklist' : 'Checklist sécurité',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    ..._checkItems.map((item) {
                      final checked = _checks.contains(item.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: checked,
                          onChanged: (value) {
                            setState(() {
                              (value ?? false)
                                  ? _checks.add(item.id)
                                  : _checks.remove(item.id);
                            });
                          },
                          secondary: CircleAvatar(
                            backgroundColor: checked
                                ? const Color(0xffdff2ed)
                                : const Color(0xfffff2df),
                            child: Icon(
                              item.icon,
                              color: checked
                                  ? const Color(0xff087f83)
                                  : const Color(0xffb7833f),
                            ),
                          ),
                          title: Text(
                            en ? _titleEn(item.id) : item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: Text(
                            en ? _subtitleEn(item.id) : item.subtitle,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xffffeeee),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xffd92d36),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              en
                                  ? 'Knowing where a valve or electrical panel is does not mean it should be operated during an emergency. Shut off a utility only when authorities, a qualified professional or the situation requires it and you know how to do so safely.'
                                  : 'Repérer une vanne ou un tableau ne signifie pas qu’il faut les manipuler pendant une urgence. Coupez un réseau uniquement si les autorités, un professionnel ou la situation l’exigent et si vous savez le faire sans danger.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _titleEn(String id) {
    return const {
          'smoke': 'Smoke alarms',
          'co': 'Carbon-monoxide detection',
          'extinguisher': 'Fire extinguisher / fire blanket',
          'flashlight': 'Emergency lighting',
          'keys': 'Accessible keys',
          'routes': 'Two possible exits',
          'utilities': 'Utility shutoffs identified',
          'assembly': 'Outdoor meeting point',
        }[id] ??
        id;
  }

  String _subtitleEn(String id) {
    return const {
          'smoke': 'Installed, accessible and tested regularly.',
          'co':
              'Planned where the building or fuel-burning equipment makes it relevant.',
          'extinguisher':
              'Available when appropriate and household members understand its intended use.',
          'flashlight':
              'A light can be reached without crossing the home in darkness.',
          'keys':
              'Exit keys and useful spare keys are known and accessible.',
          'routes':
              'A primary route and an alternative exit have been identified.',
          'utilities':
              'Water, gas and electricity locations are known without assuming they must be shut off.',
          'assembly':
              'A meeting point outside the building has been defined.',
        }[id] ??
        '';
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.icon,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
        ),
      );
}

class _SafetyCheck {
  const _SafetyCheck(
    this.id,
    this.title,
    this.subtitle,
    this.icon,
  );

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
