import 'dart:convert';

/// Minimal, fully offline MapLibre terrain style for a pinned Protomaps v4
/// archive. It needs no network glyphs, sprites, logos or online style JSON.
/// Tiles are not navigation advice and hiking paths may be stale.
class RegionalTerrainStyle {
  const RegionalTerrainStyle._();

  static String build({
    required String basemapUri,
    required String attribution,
    String? contoursUri,
    String? contoursAttribution,
  }) {
    void local(String url) {
      if (!url.startsWith('pmtiles://file:///') ||
          url.contains('?') || url.contains('#')) {
        throw const FormatException('Only local PMTiles sources are accepted');
      }
    }

    local(basemapUri);
    if (contoursUri != null) {
      local(contoursUri);
      if (contoursAttribution == null ||
          contoursAttribution.trim().isEmpty) {
        throw const FormatException('Contour data needs separate attribution');
      }
    }
    if (attribution.trim().isEmpty) {
      throw const FormatException('Map attribution must be displayed');
    }

    Map<String, dynamic> mapLayer(
      String id, String type, String sourceLayer,
      Map<String, dynamic> paint, {
      Object? filter,
      int? minZoom,
    }) {
      final layer = <String, dynamic>{
        'id': id,
        'type': type,
        'source': 'regional',
        'source-layer': sourceLayer,
        'paint': paint,
      };
      if (minZoom != null) {
        layer['minzoom'] = minZoom;
      }
      if (filter != null) {
        layer['filter'] = filter;
      }
      return layer;
    }

    Object kind(String value) => ['==', ['get', 'kind'], value];
    Object kindDetail(String value) => ['==', ['get', 'kind_detail'], value];
    Object any(List<Object> filters) => ['any', ...filters];

    final sources = <String, dynamic>{
      'regional': {
        'type': 'vector',
        'url': basemapUri,
        'attribution': attribution,
      },
      if (contoursUri != null)
        'contours': {
          'type': 'vector',
          'url': contoursUri,
          'attribution': contoursAttribution!,
        },
    };

    final layers = <Map<String, dynamic>>[
      {
        'id': 'terrain-background',
        'type': 'background',
        'paint': {'background-color': '#f6f3e8'},
      },
      mapLayer('forests-low-zoom', 'fill', 'landcover',
        {'fill-color': '#b7d5ad', 'fill-opacity': 0.62},
        filter: kind('forest')),
      mapLayer('forests', 'fill', 'landuse',
        {'fill-color': '#c3dfb4', 'fill-opacity': 0.72},
        filter: any([kind('forest'), kind('wood')])),
      mapLayer('meadows', 'fill', 'landuse',
        {'fill-color': '#e3edc8', 'fill-opacity': 0.64},
        filter: any([kind('meadow'), kind('grass')])),
      mapLayer('glaciers', 'fill', 'landuse',
        {'fill-color': '#e6f6fc', 'fill-opacity': 0.94},
        filter: kind('glacier')),
      mapLayer('rock', 'fill', 'landuse',
        {'fill-color': '#d8d0c5', 'fill-opacity': 0.68},
        filter: kind('bare_rock')),
      mapLayer('wetlands', 'fill', 'landuse',
        {'fill-color': '#c0ddc8', 'fill-opacity': 0.65},
        filter: kind('wetland')),
      mapLayer('water-fill', 'fill', 'water',
        {'fill-color': '#a4d2e9', 'fill-opacity': 0.92}),
      mapLayer('water-lines', 'line', 'water',
        {'line-color': '#7bbbdc', 'line-width': 1.5},
        minZoom: 11),
      if (contoursUri != null) ...[
        {
          'id': 'verified-contour-lines',
          'type': 'line',
          'source': 'contours',
          'source-layer': 'contours',
          'minzoom': 10,
          'paint': {
            'line-color': '#987c61',
            'line-opacity': 0.42,
            'line-width': [
              'interpolate', ['linear'], ['zoom'],
              10, 0.4, 14, 0.9, 17, 1.35,
            ],
          },
        },
      ],
      mapLayer('buildings', 'fill', 'buildings',
        {'fill-color': '#d6c7b5', 'fill-opacity': 0.86},
        minZoom: 13,
        filter: kind('building')),
      mapLayer('roads-main-outline', 'line', 'roads',
        {'line-color': '#b89c81',
          'line-width': ['interpolate', ['linear'], ['zoom'],
            8, 0.8, 14, 5.5]},
        filter: any([kind('highway'), kind('major_road')])),
      mapLayer('roads-main', 'line', 'roads',
        {'line-color': '#fffef9',
          'line-width': ['interpolate', ['linear'], ['zoom'],
            8, 0.5, 14, 4.1]},
        filter: any([kind('highway'), kind('major_road')])),
      mapLayer('roads-minor', 'line', 'roads',
        {'line-color': '#c6b8a1',
          'line-width': ['interpolate', ['linear'], ['zoom'],
            11, 0.6, 15, 2.3]},
        minZoom: 11,
        filter: kind('minor_road')),
      mapLayer('tracks', 'line', 'roads',
        {'line-color': '#b28d64',
          'line-width': ['interpolate', ['linear'], ['zoom'],
            11, 1, 16, 2.5],
          'line-dasharray': [3, 1.5]},
        minZoom: 11,
        filter: any([kindDetail('track'), kindDetail('bridleway')])),
      mapLayer('walking-paths', 'line', 'roads',
        {'line-color': '#be773c',
          'line-width': ['interpolate', ['linear'], ['zoom'],
            11, 1, 16, 2.2],
          'line-dasharray': [1.5, 1.1]},
        minZoom: 11,
        filter: any([
          kindDetail('path'), kindDetail('footway'),
          kindDetail('steps'), kindDetail('pedestrian'),
        ])),
      mapLayer('shelters-unverified', 'circle', 'pois',
        {'circle-color': '#805b47',
          'circle-radius': ['interpolate', ['linear'], ['zoom'],
            11, 2.6, 16, 5],
          'circle-stroke-color': '#ffffff',
          'circle-stroke-width': 1.2},
        minZoom: 11,
        filter: any([
          kind('shelter'), kind('alpine_hut'), kind('camp_site'),
        ])),
      mapLayer('water-unverified', 'circle', 'pois',
        {'circle-color': '#2384ae',
          'circle-radius': ['interpolate', ['linear'], ['zoom'],
            12, 2.4, 16, 4.2],
          'circle-stroke-color': '#ffffff',
          'circle-stroke-width': 1},
        minZoom: 12,
        filter: kind('drinking_water')),
    ];

    // Text labels require local glyph assets and are deliberately omitted
    // until their font licences and local file paths are verified.
    return jsonEncode({
      'version': 8,
      'name': 'ReadySafe offline hiking preview',
      'sources': sources,
      'layers': layers,
    });
  }
}
