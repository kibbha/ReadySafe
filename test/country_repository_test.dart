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
  test('unverified country profiles remain non-callable by design', () {
    final pending = CountryRepository.supported.where(
      (country) => !country.hasVerifiedNumbers,
    );

    expect(pending, isNotEmpty);
    for (final country in pending) {
      expect(country.verifiedOn, isNull);
      expect(
        country.services.every((service) => !service.isCallable),
        isTrue,
      );
    }
  });

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
  test('Swiss emergency services use dedicated verified labels', () {
    final switzerland = CountryRepository.byCode('CH')!;
    final byId = {for (final service in switzerland.services) service.id: service};

    expect(byId['medical']?.number, '144');
    expect(byId['police']?.number, '117');
    expect(byId['fire']?.number, '118');
    expect(byId['poison']?.number, '145');
    expect(byId['police']?.descriptionKey, 'service_ch_police_desc');
    expect(byId['fire']?.descriptionKey, 'service_ch_fire_desc');
    expect(switzerland.preferredEmergencyNumber, '144');
  });

  test(
    'unknown countries are not silently substituted',
    () => expect(CountryRepository.byCode('XX'), isNull),
  );
}
