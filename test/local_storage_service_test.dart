import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('malformed family data falls back safely', () async {
    SharedPreferences.setMockInitialValues({'family': '{broken'});
    expect(await LocalStorageService().family(), {
      'adults': 1,
      'children': 0,
      'care': 0,
      'pets': 0,
    });
  });

  test('communication plan persists locally', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.saveCommunicationPlan({
      'outOfAreaContact': 'Contact test',
      'outOfAreaPhone': '+41000000000',
      'schoolWork': 'École',
      'reconnectNotes': 'Point B',
      'safeMessage': 'Je suis en sécurité.',
    });

    final plan = await storage.communicationPlan();
    expect(plan['outOfAreaContact'], 'Contact test');
    expect(plan['outOfAreaPhone'], '+41000000000');
    expect(plan['safeMessage'], 'Je suis en sécurité.');
  });

  test('personal safety markers persist locally', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.saveSafetyMarkers([
      {
        'id': 'test',
        'name': 'Point famille',
        'note': 'Rassemblement',
        'lat': 46.20,
        'lng': 6.14,
        'kind': 'meeting',
      },
    ]);

    final markers = await storage.safetyMarkers();
    expect(markers, hasLength(1));
    expect(markers.first['name'], 'Point famille');
    expect(markers.first['kind'], 'meeting');
  });

  test('annual preparedness review persists date and checks', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    final date = DateTime(2026, 9, 18);

    await storage.savePreparednessReviewDate(date);
    await storage.savePreparednessReviewChecks({'contacts', 'kit', 'alerts'});

    final savedDate = await storage.preparednessReviewDate();
    final checks = await storage.preparednessReviewChecks();

    expect(savedDate?.year, 2026);
    expect(savedDate?.month, 9);
    expect(savedDate?.day, 18);
    expect(checks, containsAll({'contacts', 'kit', 'alerts'}));
  });

  test('support needs and practical notes persist locally', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();

    await storage.saveSupportNeeds({'mobility', 'power'});
    await storage.saveSupportNeedsNotes('Batterie de secours dans le placard.');

    expect(await storage.supportNeeds(), containsAll({'mobility', 'power'}));
    expect(
      await storage.supportNeedsNotes(),
      'Batterie de secours dans le placard.',
    );
  });

  test('home safety and offline checks persist locally', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();

    await storage.saveHomeSafetyPlan({
      'waterShutoff': 'Cave',
      'gasShutoff': '',
      'electricPanel': 'Entrée',
      'primaryExit': 'Porte principale',
      'secondaryExit': 'Cour',
      'safeRoom': 'Couloir intérieur',
    });
    await storage.saveHomeSafetyChecks({'smoke', 'routes', 'utilities'});
    await storage.saveOfflineReadinessChecks({'paper_contacts', 'radio', 'power'});

    final plan = await storage.homeSafetyPlan();
    expect(plan['waterShutoff'], 'Cave');
    expect(plan['electricPanel'], 'Entrée');
    expect(await storage.homeSafetyChecks(), containsAll({'smoke', 'routes', 'utilities'}));
    expect(await storage.offlineReadinessChecks(), containsAll({'paper_contacts', 'radio', 'power'}));
  });

  test('maintenance verification dates persist locally', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    final checkedAt = DateTime(2026, 9, 18, 10, 0);

    await storage.saveMaintenanceDate('radio', checkedAt);
    await storage.saveMaintenanceDate('water', checkedAt);

    final dates = await storage.maintenanceDates();
    expect(dates['radio']?.year, 2026);
    expect(dates['radio']?.month, 9);
    expect(dates['water']?.day, 18);
  });

  test('medical continuity and pet planning checks persist', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();

    await storage.toggle('medical_continuity_v3', 'med_list', true);
    await storage.toggle('medical_continuity_v3', 'device_power', true);
    await storage.toggle('pet_emergency_v3', 'id', true);
    await storage.toggle('pet_emergency_v3', 'carrier', true);

    expect(
      await storage.completed('medical_continuity_v3'),
      containsAll({'med_list', 'device_power'}),
    );
    expect(
      await storage.completed('pet_emergency_v3'),
      containsAll({'id', 'carrier'}),
    );
  });
}
