import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/data/country_repository.dart';
import 'package:readysafe/models/country_profile.dart';

void main() {
  test(
    'European registry is complete, unique and explicit about verification',
    () {
      final countries = CountryRepository.supported;
      expect(countries.length, greaterThanOrEqualTo(49));
      expect(countries.map((c) => c.isoCode).toSet().length, countries.length);
      for (final country in countries) {
        expect(country.isoCode, hasLength(2));
        expect(country.languages, isNotEmpty);
        expect(country.services, isNotEmpty);
        for (final service in country.services) {
          if (service.verification == DataVerification.needsVerification) {
            expect(service.isCallable, isFalse);
          }
        }
      }
    },
  );
  test('verified countries retain official source references', () {
    for (final code in ['FR', 'BE', 'DE', 'IT']) {
      final country = CountryRepository.byCode(code)!;
      expect(country.hasVerifiedNumbers, isTrue);
      expect(country.sources, isNotEmpty);
      expect(
        country.sources.every((source) => source.scheme == 'https'),
        isTrue,
      );
    }
  });
  test(
    'unknown countries are not silently substituted',
    () => expect(CountryRepository.byCode('XX'), isNull),
  );
}
