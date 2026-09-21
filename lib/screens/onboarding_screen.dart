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
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                keyboardVisible ? 4 : 18,
                18,
                keyboardVisible ? 4 : 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!keyboardVisible) ...[
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
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: scheme.primary,
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
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale =
                          MediaQuery.textScalerOf(context).scale(16) / 16;
                      final stacked =
                          constraints.maxWidth < 560 || textScale > 1.25;
                      final itemWidth = stacked
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 16) / 3;
                      final benefits = [
                        (
                          Icons.offline_bolt_rounded,
                          en ? 'Offline core' : 'Essentiel hors ligne',
                        ),
                        (
                          Icons.no_accounts_rounded,
                          en ? 'No account required' : 'Sans compte obligatoire',
                        ),
                        (
                          Icons.public_rounded,
                          en ? 'Country-aware' : 'Adapté au pays',
                        ),
                      ];
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final benefit in benefits)
                            SizedBox(
                              width: itemWidth,
                              child: _Benefit(
                                icon: benefit.$1,
                                title: benefit.$2,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ],
                  Text(
                    strings.get('choose_residence'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (!keyboardVisible) ...[
                    const SizedBox(height: 4),
                    Text(
                      strings.get('country_explanation'),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else
                    const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: scheme.outline),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CountrySearchList(
                        selectedCode: selected,
                        onSelected: (code) => setState(() => selected = code),
                      ),
                    ),
                  ),
                  SizedBox(height: keyboardVisible ? 4 : 10),
                  if (selectedCountry != null && !keyboardVisible)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
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
                          Icon(
                            Icons.check_circle_rounded,
                            color: scheme.onSecondaryContainer,
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: keyboardVisible ? 4 : 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: Size.fromHeight(keyboardVisible ? 46 : 54),
                    ),
                    onPressed: selected == null
                        ? null
                        : () => AppScope.of(context).setResidence(selected!),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(strings.get('continue')),
                  ),
                  if (!keyboardVisible) ...[
                    const SizedBox(height: 6),
                    Text(
                      en
                          ? 'You can change the residence country or enable travel mode later in Settings.'
                          : 'Vous pourrez modifier le pays de résidence ou activer le mode voyage plus tard dans Paramètres.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline),
        ),
        child: Column(
          children: [
            Icon(icon, color: scheme.primary, size: 22),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
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
}
