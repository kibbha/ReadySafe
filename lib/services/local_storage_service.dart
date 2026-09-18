import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checklist_item.dart';

class LocalStorageService {
  static const _familyDefaults = {
    'adults': 1,
    'children': 0,
    'care': 0,
    'pets': 0,
  };

  static const _contactsKey = 'family_contacts_v3';
  static const _documentsKey = 'family_documents_v3';
  static const _planKey = 'family_plan_v3';

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

  Future<Map<String, KitStockEntry>> kitStock() async {
    try {
      final raw = (await _prefs).getString('kit_stock_v2');
      if (raw == null) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      return decoded.map((id, value) {
        final data = Map<String, dynamic>.from(value as Map);
        return MapEntry(id, KitStockEntry.fromJson(data));
      });
    } catch (_) {
      return {};
    }
  }

  Future<void> saveKitStockEntry(KitStockEntry entry) async {
    final stock = await kitStock();
    stock[entry.itemId] = entry;
    final encoded = stock.map((id, value) => MapEntry(id, value.toJson()));
    await (await _prefs).setString('kit_stock_v2', jsonEncode(encoded));
  }

  Future<void> removeKitStockEntry(String itemId) async {
    final stock = await kitStock();
    stock.remove(itemId);
    final encoded = stock.map((id, value) => MapEntry(id, value.toJson()));
    await (await _prefs).setString('kit_stock_v2', jsonEncode(encoded));
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

  Future<List<Map<String, String>>> familyContacts() async {
    final defaults = <Map<String, String>>[
      {'name': 'Contact principal', 'role': 'À définir', 'phone': ''},
    ];
    try {
      final raw = (await _prefs).getString(_contactsKey);
      if (raw == null) return defaults;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return defaults;
      return decoded.whereType<Map>().map((item) {
        return <String, String>{
          for (final entry in item.entries) '${entry.key}': '${entry.value ?? ''}',
        };
      }).toList();
    } catch (_) {
      return defaults;
    }
  }

  Future<void> saveFamilyContacts(List<Map<String, String>> contacts) async =>
      (await _prefs).setString(_contactsKey, jsonEncode(contacts));

  Future<List<Map<String, dynamic>>> emergencyDocuments() async {
    const defaults = <Map<String, dynamic>>[
      {'id': 'identity', 'title': 'Pièces d’identité', 'category': 'Identité', 'ready': false},
      {'id': 'health', 'title': 'Documents de santé', 'category': 'Santé', 'ready': false},
      {'id': 'insurance', 'title': 'Assurances', 'category': 'Protection', 'ready': false},
      {'id': 'home', 'title': 'Documents logement', 'category': 'Logement', 'ready': false},
      {'id': 'school', 'title': 'Documents scolaires', 'category': 'Famille', 'ready': false},
      {'id': 'vehicle', 'title': 'Documents véhicule', 'category': 'Mobilité', 'ready': false},
    ];
    try {
      final raw = (await _prefs).getString(_documentsKey);
      if (raw == null) return defaults.map((e) => Map<String, dynamic>.from(e)).toList();
      final decoded = jsonDecode(raw);
      if (decoded is! List) return defaults.map((e) => Map<String, dynamic>.from(e)).toList();
      return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return defaults.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  Future<void> saveEmergencyDocuments(List<Map<String, dynamic>> docs) async =>
      (await _prefs).setString(_documentsKey, jsonEncode(docs));

  Future<Map<String, String>> familyPlan() async {
    try {
      final raw = (await _prefs).getString(_planKey);
      if (raw == null) {
        return {
          'meetingPoint': '',
          'backupMeetingPoint': '',
          'notes': '',
        };
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {'meetingPoint': '', 'backupMeetingPoint': '', 'notes': ''};
      return <String, String>{
        for (final entry in decoded.entries) '${entry.key}': '${entry.value ?? ''}',
      };
    } catch (_) {
      return {'meetingPoint': '', 'backupMeetingPoint': '', 'notes': ''};
    }
  }

  Future<void> saveFamilyPlan(Map<String, String> plan) async =>
      (await _prefs).setString(_planKey, jsonEncode(plan));

  Future<int> preparednessScore() async {
    final stock = await kitStock();
    final familyValue = await family();
    final contacts = await familyContacts();
    final docs = await emergencyDocuments();
    final plan = await familyPlan();

    var score = 0;
    if (stock.values.where((entry) => entry.quantityOwned > 0 && !entry.isExpired).length >= 8) {
      score += 40;
    } else if (stock.values.any((entry) => entry.quantityOwned > 0)) {
      score += 20;
    }
    final people = (familyValue['adults'] ?? 0) + (familyValue['children'] ?? 0);
    if (people > 0) score += 15;
    if (contacts.any((contact) => (contact['phone'] ?? '').trim().isNotEmpty)) score += 15;
    if ((plan['meetingPoint'] ?? '').trim().isNotEmpty) score += 15;
    if (docs.where((doc) => doc['ready'] == true).length >= 3) score += 15;
    return score.clamp(0, 100).toInt();
  }
}
