import 'package:flutter/material.dart';
import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../data/country_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? selected;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.shield_outlined,
                size: 88,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                t.get('welcome'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(t.get('country_explanation'), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              DropdownButtonFormField<String>(
                initialValue: selected,
                decoration: InputDecoration(
                  labelText: t.get('choose_residence'),
                  border: const OutlineInputBorder(),
                ),
                items: CountryRepository.supported
                    .map(
                      (country) => DropdownMenuItem(
                        value: country.isoCode,
                        child: Text(
                          '${_flag(country.isoCode)} ${t.get(country.nameKey)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selected = v),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: selected == null
                    ? null
                    : () => AppScope.of(context).setResidence(selected!),
                child: Text(t.get('continue')),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _flag(String code) =>
      String.fromCharCodes(code.codeUnits.map((c) => c + 127397));
}
