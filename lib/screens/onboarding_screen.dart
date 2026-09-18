import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../data/country_repository.dart';
import '../widgets/country_picker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final en = Localizations.localeOf(context).languageCode == 'en';
    final selectedCountry = CountryRepository.byCode(selected);

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 7,
                      children: [
                        ChoiceChip(
                          label: const Text('FR'),
                          selected: !en,
                          showCheckmark: false,
                          onSelected: (_) => app.setLocale('fr'),
                        ),
                        ChoiceChip(
                          label: const Text('EN'),
                          selected: en,
                          showCheckmark: false,
                          onSelected: (_) => app.setLocale('en'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffe2f3ef), Color(0xfffff4e8)],
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: const Color(0xff087f83),
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ReadySafe',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                en
                                    ? 'Emergency, first aid and preparedness in one place.'
                                    : 'Urgence, premiers secours et préparation au même endroit.',
                                style: const TextStyle(
                                  color: Color(0xff52666b),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Benefit(
                          icon: Icons.offline_bolt_rounded,
                          title: en ? 'Offline core' : 'Essentiel hors ligne',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Benefit(
                          icon: Icons.no_accounts_rounded,
                          title: en ? 'No account required' : 'Sans compte obligatoire',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Benefit(
                          icon: Icons.public_rounded,
                          title: en ? 'Country-aware' : 'Adapté au pays',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.get('choose_residence'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.get('country_explanation'),
                    style: const TextStyle(
                      color: Color(0xff65747a),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xffdde7e5)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CountrySearchList(
                        selectedCode: selected,
                        onSelected: (code) => setState(() => selected = code),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (selectedCountry != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffeaf6f4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text(
                            countryFlag(selectedCountry.isoCode),
                            style: const TextStyle(fontSize: 25),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              strings.get(selectedCountry.nameKey),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xff087f83),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                    onPressed: selected == null
                        ? null
                        : () => AppScope.of(context).setResidence(selected!),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(strings.get('continue')),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    en
                        ? 'You can change the residence country or enable travel mode later in Settings.'
                        : 'Vous pourrez modifier le pays de résidence ou activer le mode voyage plus tard dans Paramètres.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xff65747a),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffdde7e5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xff087f83), size: 22),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ],
        ),
      );
}
