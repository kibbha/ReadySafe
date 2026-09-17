import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/app/localizations.dart';
import 'package:readysafe/data/country_repository.dart';
import 'package:readysafe/widgets/country_picker.dart';

void main() {
  test('country search matches localized name and ISO code', () {
    const strings = AppLocalizations(Locale('fr'));
    expect(
      filterCountries(
        CountryRepository.supported,
        'Suisse',
        strings,
      ).single.isoCode,
      'CH',
    );
    expect(
      filterCountries(
        CountryRepository.supported,
        'GB',
        strings,
      ).single.isoCode,
      'GB',
    );
    expect(
      filterCountries(CountryRepository.supported, '', strings).length,
      CountryRepository.supported.length,
    );
  });
}
