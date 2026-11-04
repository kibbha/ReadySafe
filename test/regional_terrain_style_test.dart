import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/services/regional_terrain_style.dart';

void main() {
  const basemap = 'pmtiles://file:///data/user/0/readysafe/base.pmtiles';
  const contours = 'pmtiles://file:///data/user/0/readysafe/contours.pmtiles';

  test('local topographic preview only requests local map sources', () {
    final style = jsonDecode(RegionalTerrainStyle.build(
      basemapUri: basemap,
      attribution: '© OpenStreetMap contributors · Protomaps',
    )) as Map<String, dynamic>;

    expect(style['version'], 8);
    expect(style.containsKey('glyphs'), isFalse);
    expect(style.containsKey('sprite'), isFalse);
    final sources = style['sources'] as Map<String, dynamic>;
    expect(sources.length, 1);
    expect((sources['regional'] as Map<String, dynamic>)['url'], basemap);

    final layers = (style['layers'] as List).cast<Map<String, dynamic>>();
    final ids = layers.map((layer) => layer['id']).toSet();
    expect(ids.length, layers.length);
    expect(ids, containsAll([
      'forests', 'water-fill', 'water-lines', 'walking-paths',
      'tracks', 'shelters-unverified', 'water-unverified',
    ]));
    expect(ids.contains('verified-contour-lines'), isFalse);
    expect(style.toString().contains('https://'), isFalse);
  });

  test('paths are filtered by documented Protomaps v4 tags', () {
    final style = jsonDecode(RegionalTerrainStyle.build(
      basemapUri: basemap,
      attribution: '© OSM',
    )) as Map<String, dynamic>;
    final layers = (style['layers'] as List).cast<Map<String, dynamic>>();
    final trails = layers.singleWhere(
      (layer) => layer['id'] == 'walking-paths',
    );
    expect(trails['source-layer'], 'roads');
    expect(trails['filter'].toString(), contains('kind_detail'));
    expect(trails['filter'].toString(), contains('footway'));
    expect(trails['filter'].toString(), contains('path'));
    expect((trails['paint'] as Map)['line-dasharray'], isNotEmpty);
  });

  test('contour lines only appear when a separate LOCAL archive is supplied', () {
    final style = jsonDecode(RegionalTerrainStyle.build(
      basemapUri: basemap,
      attribution: '© OSM · Protomaps',
      contoursUri: contours,
      contoursAttribution: '© swisstopo',
    )) as Map<String, dynamic>;
    final sources = style['sources'] as Map<String, dynamic>;
    expect((sources['contours'] as Map)['url'], contours);
    expect((sources['contours'] as Map)['attribution'], '© swisstopo');

    final layers = (style['layers'] as List).cast<Map<String, dynamic>>();
    final contourLayer = layers.singleWhere(
      (layer) => layer['id'] == 'verified-contour-lines',
    );
    expect(contourLayer['source'], 'contours');
    expect(contourLayer['source-layer'], 'contours');
  });

  test('refuse remote map and contour sources even if they look like PMTiles', () {
    expect(
      () => RegionalTerrainStyle.build(
        basemapUri: 'https://tiles.example.com/a.pmtiles',
        attribution: '© OSM',
      ),
      throwsFormatException,
    );
    expect(
      () => RegionalTerrainStyle.build(
        basemapUri: basemap,
        contoursUri: 'https://evil.invalid/terrain.pmtiles',
        contoursAttribution: '© swisstopo',
        attribution: '© OSM',
      ),
      throwsFormatException,
    );
    expect(
      () => RegionalTerrainStyle.build(
        basemapUri: basemap,
        attribution: '  ',
      ),
      throwsFormatException,
    );
    expect(
      () => RegionalTerrainStyle.build(
        basemapUri: basemap,
        attribution: '© OSM',
        contoursUri: contours,
      ),
      throwsFormatException,
    );
  });
}
