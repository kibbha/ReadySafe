import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/field_guide_entry.dart';

/// Versioned, bundled knowledge. Reading and searching require no network.
class FieldGuideRepository {
  const FieldGuideRepository._();

  static const assetPath = 'assets/data/field_guide_v1.json';

  static Future<List<FieldGuideEntry>> load() async {
    final content = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic> || decoded['schema_version'] != 1) {
      throw const FormatException('Unsupported field-guide database');
    }

    final entries = decoded['entries'];
    if (entries is! List) throw const FormatException('Missing field-guide entries');

    final ids = <String>{};
    final result = <FieldGuideEntry>[];
    for (final raw in entries) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid field-guide entry');
      }
      final entry = FieldGuideEntry.fromJson(raw);
      if (!ids.add(entry.id)) throw FormatException('Duplicate field-guide ID: ${entry.id}');
      result.add(entry);
    }
    return List<FieldGuideEntry>.unmodifiable(result);
  }

  static List<FieldGuideEntry> search(
    List<FieldGuideEntry> entries, {
    String query = '',
    FieldGuideCategory? category,
    bool english = false,
  }) {
    return entries.where((entry) =>
      (category == null || entry.category == category) &&
      entry.matches(query, english),
    ).toList(growable: false);
  }
}
