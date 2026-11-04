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
    expect(catalog.contourPacks.length, 3);
    expect(catalog.contourPacks.every((p) => !p.canDownload), isTrue);
    expect(catalog.contoursFor('ch-leman')?.id, 'ch-leman-contours');
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

  test('contour overlays must have one existing parent and the right schema', () {
    final base = _fixture(approved: false);
    final contours = _fixture(approved: false)
      ..['id'] = 'test-region-contours'
      ..['tile_schema'] = 'readysafe-contours-v1'
      ..['parent_map_id'] = 'test-region';

    final catalog = RegionalMapCatalog.fromJson(jsonEncode({
      'schema_version': 1,
      'packs': [base],
      'contour_packs': [contours],
    }));
    expect(catalog.contoursFor('test-region')?.id, 'test-region-contours');

    final unknownParent = Map<String, dynamic>.from(contours)
      ..['parent_map_id'] = 'other-region';
    expect(
      () => RegionalMapCatalog.fromJson(jsonEncode({
        'schema_version': 1,
        'packs': [base],
        'contour_packs': [unknownParent],
      })),
      throwsFormatException,
    );

    expect(
      () => RegionalMapCatalog.fromJson(jsonEncode({
        'schema_version': 1,
        'packs': [base],
        'contour_packs': [contours, contours],
      })),
      throwsFormatException,
    );

    final badOverlay = Map<String, dynamic>.from(contours)
      ..remove('parent_map_id');
    expect(() => RegionalMapPack.fromJson(badOverlay), throwsFormatException);
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

  test('verified streaming installs and preserves existing map after bad update',
      () async {
    final pack = RegionalMapPack.fromJson(_fixture());
    final folder = await Directory.systemTemp.createTemp('readysafe-stream-');
    final service = RegionalMapPackService(rootDirectory: folder);
    try {
      final installed = await service.installVerifiedFixture(
        pack,
        Stream<List<int>>.value(_archive()),
      );
      expect(await RegionalMapPackService.verifyFile(installed, pack), isTrue);
      final original = await installed.readAsBytes();

      final damaged = _archive()..[30] = 99;
      await expectLater(
        service.installVerifiedFixture(
          pack,
          Stream<List<int>>.value(damaged),
        ),
        throwsFormatException,
      );
      expect(await installed.readAsBytes(), original);
      expect(await File('${installed.path}.partial').exists(), isFalse);

      await expectLater(
        service.installVerifiedFixture(
          pack,
          Stream<List<int>>.value([..._archive(), 1]),
        ),
        throwsFormatException,
      );
      expect(await installed.readAsBytes(), original);
    } finally {
      await folder.delete(recursive: true);
    }
  });

  test('verified local contour archive appears only with matching parent',
      () async {
    final folder = await Directory.systemTemp.createTemp('readysafe-relief-');
    final service = RegionalMapPackService(rootDirectory: folder);
    try {
      final base = RegionalMapPack.fromJson(_fixture());
      final contourInput = _fixture()
        ..['id'] = 'test-region-contours'
        ..['tile_schema'] = 'readysafe-contours-v1'
        ..['parent_map_id'] = 'test-region'
        ..['attribution'] = '© swisstopo';
      final contour = RegionalMapPack.fromJson(contourInput);
      await service.installVerifiedFixture(
        base, Stream<List<int>>.value(_archive()),
      );
      await service.installVerifiedFixture(
        contour, Stream<List<int>>.value(_archive()),
      );

      final plain = jsonDecode(await service.localPreviewStyle(base))
          as Map<String, dynamic>;
      final plainSources = plain['sources'] as Map<String, dynamic>;
      expect(plainSources.containsKey('contours'), isFalse);

      final withRelief = jsonDecode(await service.localPreviewStyle(
        base, contours: contour,
      )) as Map<String, dynamic>;
      final sources = withRelief['sources'] as Map<String, dynamic>;
      expect((sources['contours'] as Map)['attribution'], '© swisstopo');
      expect((sources['contours'] as Map)['url'].toString(),
          startsWith('pmtiles://file:///'));

      final wrong = RegionalMapPack.fromJson(
        Map<String, dynamic>.from(contourInput)
          ..['parent_map_id'] = 'unrelated-region',
      );
      await expectLater(
        service.localPreviewStyle(base, contours: wrong),
        throwsStateError,
      );

      await service.delete(contour);
      await expectLater(
        service.localPreviewStyle(base, contours: contour),
        throwsStateError,
      );
      expect(await service.verifiedInstalled(base), isTrue);
    } finally {
      await folder.delete(recursive: true);
    }
  });
}
