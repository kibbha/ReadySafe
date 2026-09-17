import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/data/country_repository.dart';
import 'package:readysafe/data/first_aid_repository.dart';

void main() {
  test('verified emergency numbers remain available after main merge', () {
    final expected = <String, Set<String>>{
      'FR': {'112', '15', '17', '18', '114'},
      'BE': {'112', '101'},
      'DE': {'112', '110'},
      'IT': {'112'},
    };

    for (final entry in expected.entries) {
      final country = CountryRepository.byCode(entry.key);
      expect(country, isNotNull, reason: '${entry.key} must remain supported');
      expect(
        country!.services.map((service) => service.number).toSet(),
        containsAll(entry.value),
      );
    }
  });

  test('essential step-by-step first-aid guides remain available', () {
    const expectedIds = {
      'cpr_adult',
      'aed',
      'cpr_child',
      'cpr_infant',
      'choking_adult',
      'choking_child',
      'choking_infant',
      'bleeding',
      'burn',
      'unconscious',
      'seizure',
      'drowning',
      'hypothermia',
      'heatstroke',
    };
    expect(firstAidGuides.map((guide) => guide.id), containsAll(expectedIds));
    expect(firstAidGuides.every((guide) => guide.steps.length >= 3), isTrue);
    expect(
      firstAidGuides.every(
        (guide) => guide.steps.every(
          (step) => step.illustrationAsset.endsWith('.svg'),
        ),
      ),
      isTrue,
    );
  });
}
