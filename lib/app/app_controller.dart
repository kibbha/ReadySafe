import 'package:flutter/foundation.dart';
import '../data/country_repository.dart';
import '../models/country_profile.dart';
import '../services/app_settings_service.dart';

class AppController extends ChangeNotifier {
  AppController(this._service);
  final AppSettingsService _service;
  AppSettings _settings = const AppSettings();
  bool _ready = false;
  bool get ready => _ready;
  AppSettings get settings => _settings;
  CountryProfile? get residenceCountry =>
      CountryRepository.byCode(_settings.residenceCountryCode);
  CountryProfile? get activeCountry =>
      CountryRepository.byCode(_settings.activeCountryCode);
  bool get travelMode => _settings.travelCountryCode != null;

  Future<void> load() async {
    final loaded = await _service.load();
    final residence = CountryRepository.byCode(loaded.residenceCountryCode);
    final travel = CountryRepository.byCode(loaded.travelCountryCode);
    _settings = AppSettings(
      residenceCountryCode: residence?.isoCode,
      travelCountryCode: residence == null ? null : travel?.isoCode,
      localeCode: const {'fr', 'en'}.contains(loaded.localeCode)
          ? loaded.localeCode
          : 'fr',
    );
    _ready = true;
    notifyListeners();
  }

  Future<void> setResidence(String code) async {
    if (CountryRepository.byCode(code) == null) {
      throw ArgumentError.value(code, 'code', 'Unsupported country');
    }
    await _service.saveResidence(code);
    _settings = AppSettings(
      residenceCountryCode: code,
      travelCountryCode: _settings.travelCountryCode,
      localeCode: _settings.localeCode,
    );
    notifyListeners();
  }

  Future<void> setTravel(String? code) async {
    if (code != null && CountryRepository.byCode(code) == null) {
      throw ArgumentError.value(code, 'code', 'Unsupported country');
    }
    await _service.saveTravel(code);
    _settings = AppSettings(
      residenceCountryCode: _settings.residenceCountryCode,
      travelCountryCode: code,
      localeCode: _settings.localeCode,
    );
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    await _service.saveLocale(code);
    _settings = AppSettings(
      residenceCountryCode: _settings.residenceCountryCode,
      travelCountryCode: _settings.travelCountryCode,
      localeCode: code,
    );
    notifyListeners();
  }
}
