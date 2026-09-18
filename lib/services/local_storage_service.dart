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
  static const _communicationKey = 'communication_plan_v3';
  static const _safetyMarkersKey = 'personal_safety_markers_v3';
  static const _reviewDateKey = 'preparedness_review_date_v3';
  static const _reviewChecksKey = 'preparedness_review_checks_v3';
  static const _supportNeedsKey = 'support_needs_v3';
  static const _supportNeedsNotesKey = 'support_needs_notes_v3';
  static const _homeSafetyKey = 'home_safety_v3';
  static const _homeSafetyChecksKey = 'home_safety_checks_v3';
  static const _offlineChecksKey = 'offline_readiness_checks_v3';

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

  Future<Map<String, String>> communicationPlan() async {
    const defaults = <String, String>{
      'outOfAreaContact': '',
      'outOfAreaPhone': '',
      'schoolWork': '',
      'reconnectNotes': '',
      'safeMessage': 'Je suis en sécurité. Je te contacte dès que possible.',
    };
    try {
      final raw = (await _prefs).getString(_communicationKey);
      if (raw == null) return Map<String, String>.from(defaults);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return Map<String, String>.from(defaults);
      return {
        for (final entry in defaults.entries)
          entry.key: '${decoded[entry.key] ?? entry.value}',
      };
    } catch (_) {
      return Map<String, String>.from(defaults);
    }
  }

  Future<void> saveCommunicationPlan(Map<String, String> plan) async =>
      (await _prefs).setString(_communicationKey, jsonEncode(plan));

  Future<List<Map<String, dynamic>>> safetyMarkers() async {
    try {
      final raw = (await _prefs).getString(_safetyMarkersKey);
      if (raw == null) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSafetyMarkers(List<Map<String, dynamic>> markers) async =>
      (await _prefs).setString(_safetyMarkersKey, jsonEncode(markers));

  Future<DateTime?> preparednessReviewDate() async {
    try {
      final raw = (await _prefs).getString(_reviewDateKey);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePreparednessReviewDate(DateTime value) async =>
      (await _prefs).setString(_reviewDateKey, value.toIso8601String());

  Future<Set<String>> preparednessReviewChecks() async {
    try {
      return (await _prefs).getStringList(_reviewChecksKey)?.toSet() ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<void> savePreparednessReviewChecks(Set<String> values) async =>
      (await _prefs).setStringList(_reviewChecksKey, values.toList());

  Future<Set<String>> supportNeeds() async {
    try {
      return (await _prefs).getStringList(_supportNeedsKey)?.toSet() ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<void> saveSupportNeeds(Set<String> values) async =>
      (await _prefs).setStringList(_supportNeedsKey, values.toList());

  Future<String> supportNeedsNotes() async {
    try {
      return (await _prefs).getString(_supportNeedsNotesKey) ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> saveSupportNeedsNotes(String value) async =>
      (await _prefs).setString(_supportNeedsNotesKey, value);

  Future<Map<String, String>> homeSafetyPlan() async {
    const defaults = <String, String>{
      'waterShutoff': '',
      'gasShutoff': '',
      'electricPanel': '',
      'primaryExit': '',
      'secondaryExit': '',
      'safeRoom': '',
    };
    try {
      final raw = (await _prefs).getString(_homeSafetyKey);
      if (raw == null) return Map<String, String>.from(defaults);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return Map<String, String>.from(defaults);
      return {
        for (final entry in defaults.entries)
          entry.key: '${decoded[entry.key] ?? entry.value}',
      };
    } catch (_) {
      return Map<String, String>.from(defaults);
    }
  }

  Future<void> saveHomeSafetyPlan(Map<String, String> value) async =>
      (await _prefs).setString(_homeSafetyKey, jsonEncode(value));

  Future<Set<String>> homeSafetyChecks() async {
    try {
      return (await _prefs).getStringList(_homeSafetyChecksKey)?.toSet() ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<void> saveHomeSafetyChecks(Set<String> values) async =>
      (await _prefs).setStringList(_homeSafetyChecksKey, values.toList());

  Future<Set<String>> offlineReadinessChecks() async {
    try {
      return (await _prefs).getStringList(_offlineChecksKey)?.toSet() ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<void> saveOfflineReadinessChecks(Set<String> values) async =>
      (await _prefs).setStringList(_offlineChecksKey, values.toList());

  Future<int> preparednessScore() async {
    final stock = await kitStock();
    final familyValue = await family();
    final contacts = await familyContacts();
    final docs = await emergencyDocuments();
    final plan = await familyPlan();
    final communication = await communicationPlan();
    final homeChecks = await homeSafetyChecks();
    final offlineChecks = await offlineReadinessChecks();
    final reviewDate = await preparednessReviewDate();
    final support = await supportNeeds();
    final supportNotes = await supportNeedsNotes();

    var score = 0;

    final readyKitItems = stock.values
        .where((entry) => entry.quantityOwned > 0 && !entry.isExpired)
        .length;
    if (readyKitItems >= 8) {
      score += 25;
    } else if (readyKitItems >= 4) {
      score += 15;
    } else if (readyKitItems > 0) {
      score += 8;
    }

    final people = (familyValue['adults'] ?? 0) +
        (familyValue['children'] ?? 0) +
        (familyValue['care'] ?? 0);
    if (people > 0) score += 10;

    if (contacts.any((contact) => (contact['phone'] ?? '').trim().isNotEmpty)) {
      score += 10;
    }

    if ((plan['meetingPoint'] ?? '').trim().isNotEmpty) score += 10;

    if (docs.where((doc) => doc['ready'] == true).length >= 3) score += 10;

    if ((communication['outOfAreaPhone'] ?? '').trim().isNotEmpty) score += 10;

    if (homeChecks.length >= 4) score += 10;

    if (offlineChecks.length >= 3) score += 5;

    if (reviewDate != null &&
        DateTime.now().difference(reviewDate).inDays.abs() <= 400) {
      score += 5;
    }

    final supportRelevant = (familyValue['care'] ?? 0) > 0 || support.isNotEmpty;
    if (!supportRelevant || support.isNotEmpty || supportNotes.trim().isNotEmpty) {
      score += 5;
    }

    return score.clamp(0, 100).toInt();
  }
}

