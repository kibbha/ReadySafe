import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/data/country_repository.dart';

void main() {
  test('country registry is uniquely keyed and traceable', () {
    final countries = CountryRepository.supported;
    expect(
      countries.map((country) => country.isoCode).toSet().length,
      countries.length,
    );
    for (final country in countries) {
      expect(country.isoCode, hasLength(2));
      expect(country.languages, isNotEmpty);
      expect(
        country.services.any((service) => service.number == '112'),
        isTrue,
      );
      expect(country.sources, isNotEmpty);
      expect(
        country.sources.every((source) => source.scheme == 'https'),
        isTrue,
      );
    }
  });

  test('unknown countries are not silently substituted', () {
    expect(CountryRepository.byCode('XX'), isNull);
  });
}
