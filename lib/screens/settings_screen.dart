import 'package:flutter/material.dart';
import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../data/country_repository.dart';
import '../widgets/country_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final residence = app.residenceCountry;
    final active = app.activeCountry;
    return Scaffold(
      appBar: AppBar(title: Text(strings.get('settings'))),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width >= 700 ? 28 : 16,
                vertical: 16,
              ),
              children: [
                Text(
                  strings.get('residence_country'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Card(
                  child: ListTile(
                    minTileHeight: 64,
                    leading: Text(
                      residence == null ? '🌍' : countryFlag(residence.isoCode),
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      residence == null
                          ? strings.get('choose_residence')
                          : strings.get(residence.nameKey),
                    ),
                    trailing: const Icon(Icons.search),
                    onTap: () async {
                      final code = await showCountryPicker(
                        context,
                        selectedCode: residence?.isoCode,
                      );
                      if (code != null) await app.setResidence(code);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.get('travel_mode')),
                  subtitle: Text(strings.get('travel_explanation')),
                  value: app.travelMode,
                  onChanged: (enabled) async {
                    if (!enabled) {
                      await app.setTravel(null);
                    } else {
                      final code = await showCountryPicker(
                        context,
                        selectedCode: active?.isoCode,
                      );
                      if (code != null) await app.setTravel(code);
                    }
                  },
                ),
                if (app.travelMode)
                  Card(
                    child: ListTile(
                      leading: Text(
                        active == null ? '🌍' : countryFlag(active.isoCode),
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        active == null
                            ? strings.get('active_country')
                            : strings.get(active.nameKey),
                      ),
                      trailing: const Icon(Icons.search),
                      onTap: () async {
                        final code = await showCountryPicker(
                          context,
                          selectedCode: active?.isoCode,
                        );
                        if (code != null) await app.setTravel(code);
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  strings.get('language'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                RadioGroup<String>(
                  groupValue: app.settings.localeCode,
                  onChanged: (value) {
                    if (value != null) app.setLocale(value);
                  },
                  child: Column(
                    children: [
                      RadioListTile(
                        value: 'fr',
                        title: Text(strings.get('french')),
                      ),
                      RadioListTile(
                        value: 'en',
                        title: Text(strings.get('english')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${CountryRepository.supported.length} ${strings.get('europe_filter')}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
