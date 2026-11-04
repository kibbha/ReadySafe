import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/models/regional_map_pack.dart';
import 'package:readysafe/services/regional_map_pack_service.dart';

List<int> _archive() => [...utf8.encode('PMTiles'), 3, ...List<int>.filled(119, 0)];

Map<String, dynamic> _fixture({
  bool approved = true,
  String? hash,
  int? size,
}) => {
  'id': 'test-region',
  'name_fr': 'Zone test',
  'name_en': 'Test region',
  'country': 'CH',
  'centre_lat': 46.2,
  'centre_lon': 6.14,
  'zoom': 12,
  'version': 'test-1',
  'tile_schema': 'protomaps-v4',
  'source_label': 'Fixture only — no real host',
  'attribution': '© OpenStreetMap contributors',
  'license': 'test-only',
  'approved': approved,
  'download_url': 'https://example.org/test.pmtiles',
  'byte_length': size ?? _archive().length,
  'sha256': hash ?? sha256.convert(_archive()).toString(),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled regional catalog is a fail-closed preview, no downloads', () async {
    final raw = await rootBundle.loadString(
      RegionalMapPackService.catalogAsset,
    );
    final catalog = RegionalMapCatalog.fromJson(raw);
    expect(catalog.packs.length, 3);
    expect(catalog.packs.every((p) => !p.canDownload), isTrue);
    expect(catalog.packs.every((p) => p.downloadUrl == null), isTrue);
  });

  test('approved packs require a pinned size, HTTPS URL and digest', () {
    final pack = RegionalMapPack.fromJson(_fixture());
    expect(pack.canDownload, isTrue);
    expect(pack.filename, 'test-region-test-1.pmtiles');
    final invalid = _fixture()..['download_url'] = 'http://example.org/file.pmtiles';
    expect(() => RegionalMapPack.fromJson(invalid), throwsFormatException);
    final noHash = _fixture()..remove('sha256');
    expect(() => RegionalMapPack.fromJson(noHash), throwsFormatException);
    final escape = _fixture()..['id'] = '../etc';
    expect(() => RegionalMapPack.fromJson(escape), throwsFormatException);
    final overSize = _fixture()..['byte_length'] = 3 * 1024 * 1024 * 1024;
    expect(() => RegionalMapPack.fromJson(overSize), throwsFormatException);
  });

  test('catalog rejects duplicate IDs and incompatible schema', () {
    final fixture = _fixture(approved: false);
    expect(
      () => RegionalMapCatalog.fromJson(jsonEncode({
        'schema_version': 1,
        'packs': [fixture, fixture],
      })),
      throwsFormatException,
    );
    final incorrect = _fixture()..['tile_schema'] = 'random-vectors';
    expect(() => RegionalMapPack.fromJson(incorrect), throwsFormatException);
  });

  test('local file requires exact length and SHA-256', () async {
    final pack = RegionalMapPack.fromJson(_fixture());
    final folder = await Directory.systemTemp.createTemp('readysafe-pack-test-');
    try {
      final file = File('${folder.path}/test.pmtiles');
      await file.writeAsBytes(_archive(), flush: true);
      expect(await RegionalMapPackService.verifyFile(file, pack), isTrue);

      final corrupted = _archive()..[25] = 42;
      await file.writeAsBytes(corrupted, flush: true);
      expect(await RegionalMapPackService.verifyFile(file, pack), isFalse);

      await file.writeAsBytes([..._archive(), 7], flush: true);
      expect(await RegionalMapPackService.verifyFile(file, pack), isFalse);
    } finally {
      await folder.delete(recursive: true);
    }
  });

  test('unapproved pack cannot qualify as installed even with a local file', () async {
    final pack = RegionalMapPack.fromJson(_fixture(approved: false));
    final folder = await Directory.systemTemp.createTemp('readysafe-block-test-');
    try {
      final file = File('${folder.path}/test.pmtiles');
      await file.writeAsBytes(_archive());
      expect(await RegionalMapPackService.verifyFile(file, pack), isFalse);
    } finally {
      await folder.delete(recursive: true);
    }
  });
}
