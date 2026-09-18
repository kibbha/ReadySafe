import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    this.residenceCountryCode,
    this.travelCountryCode,
    this.localeCode = 'fr',
    this.largeText = false,
    this.highContrast = false,
  });

  final String? residenceCountryCode;
  final String? travelCountryCode;
  final String localeCode;
  final bool largeText;
  final bool highContrast;

  bool get onboardingComplete => residenceCountryCode != null;
  String? get activeCountryCode => travelCountryCode ?? residenceCountryCode;

  AppSettings copyWith({
    String? residenceCountryCode,
    String? travelCountryCode,
    String? localeCode,
    bool? largeText,
    bool? highContrast,
    bool clearTravelCountry = false,
  }) =>
      AppSettings(
        residenceCountryCode: residenceCountryCode ?? this.residenceCountryCode,
        travelCountryCode: clearTravelCountry
            ? null
            : (travelCountryCode ?? this.travelCountryCode),
        localeCode: localeCode ?? this.localeCode,
        largeText: largeText ?? this.largeText,
        highContrast: highContrast ?? this.highContrast,
      );
}

class AppSettingsService {
  static const _residence = 'settings.residenceCountry';
  static const _travel = 'settings.travelCountry';
  static const _locale = 'settings.locale';
  static const _largeText = 'settings.largeText';
  static const _highContrast = 'settings.highContrast';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      residenceCountryCode: prefs.getString(_residence),
      travelCountryCode: prefs.getString(_travel),
      localeCode: prefs.getString(_locale) ?? 'fr',
      largeText: prefs.getBool(_largeText) ?? false,
      highContrast: prefs.getBool(_highContrast) ?? false,
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

  Future<void> saveLargeText(bool enabled) async =>
      (await SharedPreferences.getInstance()).setBool(_largeText, enabled);

  Future<void> saveHighContrast(bool enabled) async =>
      (await SharedPreferences.getInstance()).setBool(_highContrast, enabled);
}
