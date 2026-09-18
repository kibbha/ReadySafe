import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/data/country_repository.dart';
import 'package:readysafe/data/content.dart';
import 'package:readysafe/data/first_aid_repository.dart';
import 'package:readysafe/screens/guide_list_screen.dart';

void main() {
  test('first aid never proposes a number for an unverified country', () {
    final pending = CountryRepository.byCode('AM')!;
    expect(pending.verifiedOn, isNull);
    expect(pending.preferredEmergencyNumber, isNull);
    expect(CountryRepository.byCode('CH')!.preferredEmergencyNumber, '144');
  });

  test('verified emergency numbers remain available after main merge', () {
    final expected = <String, Set<String>>{
      'FR': {'112', '15', '17', '18', '114'},
      'BE': {'112', '101'},
      'DE': {'112', '110'},
      'IT': {'112'},
      'NO': {'110', '112', '113'},
      'IS': {'112'},
      'TR': {'112'},
      'LI': {'112', '117', '118', '144'},
      'GE': {'112'},
      'MD': {'112'},
      'AL': {'112'},
      'MK': {'112'},
      'AD': {'110', '112', '116', '118'},
      'MC': {'15', '17', '18', '112', '196'},
      'SM': {'112', '113', '115'},
      'ME': {'112'},
      'RS': {'192', '193', '194'},
      'XK': {'112', '192', '193', '194'},
      'UA': {'112', '101', '102', '103', '104'},
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

  test('evacuation guidance never requires delaying departure for utilities', () {
    final evacuation = emergencyGuides.firstWhere(
      (guide) => guide.id == 'evacuation',
    );
    final flood = disasterGuides.firstWhere(
      (guide) => guide.id == 'flood',
    );

    expect(
      evacuation.avoid.toLowerCase(),
      contains('ne retardez pas'),
    );
    expect(
      evacuation.steps.join(' ').toLowerCase(),
      contains('ne manipulez gaz, eau ou électricité que si'),
    );
    expect(
      flood.steps.join(' ').toLowerCase(),
      isNot(contains('coupez l’électricité')),
    );

    final shelter = disasterGuides.firstWhere(
      (guide) => guide.id == 'shelter',
    );
    expect(
      shelter.immediate.toLowerCase(),
      isNot(contains('fermez portes, fenêtres et ventilation')),
    );

    final earthquake = disasterGuides.firstWhere(
      (guide) => guide.id == 'earthquake',
    );
    expect(
      earthquake.steps.join(' ').toLowerCase(),
      isNot(contains('sortez prudemment')),
    );
  });

  test('direct hazard routes can use English localized content', () {
    final flood = disasterGuides.firstWhere(
      (guide) => guide.id == 'flood',
    );
    final englishFlood = localizedGuide(flood, true);

    expect(flood.title, 'Inondation');
    expect(englishFlood.title, 'Flood');
    expect(
      englishFlood.steps.join(' '),
      contains('official alerts'),
    );
  });

  test('gas leak guidance avoids ignition sources and re-entry', () {
    final gas = disasterGuides.firstWhere(
      (guide) => guide.id == 'gas_leak',
    );

    final combined = [
      gas.immediate,
      gas.avoid,
      ...gas.steps,
      gas.callHelp,
      gas.evacuate,
    ].join(' ').toLowerCase();

    expect(combined, contains('interrupteur'));
    expect(combined, contains('flamme'));
    expect(combined, contains('ne rentrez pas'));
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
      'poisoning',
      'anaphylaxis',
      'stroke',
      'chest_pain',
      'asthma',
      'hypoglycemia',
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
