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
    final selectedCountry = CountryRepository.byCode(selected);
    return Scaffold(
      appBar: AppBar(title: Text(strings.get('welcome'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                strings.get('country_explanation'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: CountrySearchList(
                  selectedCode: selected,
                  onSelected: (code) => setState(() => selected = code),
                ),
              ),
              const SizedBox(height: 12),
              if (selectedCountry != null)
                Text(
                  '${countryFlag(selectedCountry.isoCode)} ${strings.get(selectedCountry.nameKey)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: selected == null
                    ? null
                    : () => AppScope.of(context).setResidence(selected!),
                child: Text(strings.get('continue')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
