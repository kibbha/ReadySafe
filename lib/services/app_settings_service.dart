import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    this.residenceCountryCode,
    this.travelCountryCode,
    this.localeCode = 'fr',
  });
  final String? residenceCountryCode;
  final String? travelCountryCode;
  final String localeCode;
  bool get onboardingComplete => residenceCountryCode != null;
  String? get activeCountryCode => travelCountryCode ?? residenceCountryCode;
}

class AppSettingsService {
  static const _residence = 'settings.residenceCountry';
  static const _travel = 'settings.travelCountry';
  static const _locale = 'settings.locale';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      residenceCountryCode: prefs.getString(_residence),
      travelCountryCode: prefs.getString(_travel),
      localeCode: prefs.getString(_locale) ?? 'fr',
    );
  }

  Future<void> saveResidence(String code) async =>
      (await SharedPreferences.getInstance()).setString(_residence, code);
  Future<void> saveTravel(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_travel);
    } else {
      await prefs.setString(_travel, code);
    }
  }

  Future<void> saveLocale(String code) async =>
      (await SharedPreferences.getInstance()).setString(_locale, code);
}
