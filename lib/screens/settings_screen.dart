import 'package:flutter/material.dart';
import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../data/country_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context), app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.get('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.get('residence_country'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: app.settings.residenceCountryCode,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _countries(t),
            onChanged: (v) {
              if (v != null) app.setResidence(v);
            },
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.get('travel_mode')),
            subtitle: Text(t.get('travel_explanation')),
            value: app.travelMode,
            onChanged: (enabled) {
              if (!enabled) {
                app.setTravel(null);
              } else {
                final other = CountryRepository.supported.firstWhere(
                  (c) => c.isoCode != app.settings.residenceCountryCode,
                );
                app.setTravel(other.isoCode);
              }
            },
          ),
          if (app.travelMode)
            DropdownButtonFormField<String>(
              initialValue: app.settings.travelCountryCode,
              decoration: InputDecoration(
                labelText: t.get('active_country'),
                border: const OutlineInputBorder(),
              ),
              items: _countries(t),
              onChanged: app.setTravel,
            ),
          const SizedBox(height: 24),
          Text(
            t.get('language'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          RadioGroup<String>(
            groupValue: app.settings.localeCode,
            onChanged: (v) {
              if (v != null) app.setLocale(v);
            },
            child: Column(
              children: [
                RadioListTile(value: 'fr', title: Text(t.get('french'))),
                RadioListTile(value: 'en', title: Text(t.get('english'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _countries(AppLocalizations t) =>
      CountryRepository.supported
          .map(
            (c) => DropdownMenuItem(
              value: c.isoCode,
              child: Text(t.get(c.nameKey)),
            ),
          )
          .toList();
}
