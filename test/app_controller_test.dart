import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/app/app_controller.dart';
import 'package:readysafe/services/app_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('residence and temporary travel country persist', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(AppSettingsService());
    await controller.load();
    expect(controller.settings.onboardingComplete, isFalse);
    await controller.setResidence('FR');
    await controller.setTravel('DE');
    expect(controller.residenceCountry?.isoCode, 'FR');
    expect(controller.activeCountry?.isoCode, 'DE');
    expect(controller.travelMode, isTrue);

    final restored = AppController(AppSettingsService());
    await restored.load();
    expect(restored.settings.residenceCountryCode, 'FR');
    expect(restored.settings.travelCountryCode, 'DE');
    await restored.setTravel(null);
    expect(restored.activeCountry?.isoCode, 'FR');
  });

  test('invalid persisted country returns to onboarding safely', () async {
    SharedPreferences.setMockInitialValues({
      'settings.residenceCountry': 'XX',
      'settings.travelCountry': 'YY',
    });
    final controller = AppController(AppSettingsService());
    await controller.load();
    expect(controller.settings.onboardingComplete, isFalse);
    expect(controller.activeCountry, isNull);
  });
}
