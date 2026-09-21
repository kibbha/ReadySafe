import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/services/app_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ReadySafe defaults to a light appearance', () async {
    SharedPreferences.setMockInitialValues({});
    final service = AppSettingsService();

    final settings = await service.load();

    expect(settings.themeModeCode, 'light');
  });

  test('accessibility display preferences persist', () async {
    SharedPreferences.setMockInitialValues({});
    final service = AppSettingsService();

    await service.saveThemeMode('dark');
    await service.saveLargeText(true);
    await service.saveHighContrast(true);

    final settings = await service.load();
    expect(settings.themeModeCode, 'dark');
    expect(settings.largeText, isTrue);
    expect(settings.highContrast, isTrue);
  });

  test('copyWith preserves accessibility preferences', () {
    const settings = AppSettings(
      residenceCountryCode: 'CH',
      localeCode: 'fr',
      themeModeCode: 'dark',
      largeText: true,
      highContrast: true,
    );

    final changed = settings.copyWith(localeCode: 'en');

    expect(changed.residenceCountryCode, 'CH');
    expect(changed.localeCode, 'en');
    expect(changed.themeModeCode, 'dark');
    expect(changed.largeText, isTrue);
    expect(changed.highContrast, isTrue);
  });
}
