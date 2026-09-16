import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _familyDefaults = {
    'adults': 1,
    'children': 0,
    'care': 0,
    'pets': 0,
  };

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Set<String>> completed(String key) async {
    try {
      return (await _prefs).getStringList(key)?.toSet() ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<void> toggle(String key, String id, bool value) async {
    final values = await completed(key);
    value ? values.add(id) : values.remove(id);
    await (await _prefs).setStringList(key, values.toList());
  }

  Future<Map<String, int>> family() async {
    try {
      final raw = (await _prefs).getString('family');
      if (raw == null) return Map.of(_familyDefaults);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return Map.of(_familyDefaults);
      return {
        for (final entry in _familyDefaults.entries)
          entry.key: (decoded[entry.key] as num?)?.toInt() ?? entry.value,
      };
    } catch (_) {
      return Map.of(_familyDefaults);
    }
  }

  Future<void> saveFamily(Map<String, int> value) async =>
      (await _prefs).setString('family', jsonEncode(value));
}
