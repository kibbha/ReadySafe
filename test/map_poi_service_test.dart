import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/models/map_poi.dart';
import 'package:readysafe/services/map_poi_service.dart';

void main() {
  test('Overpass query requests useful places but not shelters', () {
    final query = MapPoiService.buildOverpassQuery(
      latitude: 46.2,
      longitude: 6.14,
    );

    expect(query, contains('hospital'));
    expect(query, contains('pharmacy'));
    expect(query, contains('police'));
    expect(query, contains('drinking_water'));
    expect(query, contains('defibrillator'));
    expect(query, isNot(contains('"shelter"')));
  });

  test('Overpass parser classifies and sorts useful places', () {
    final decoded = <String, dynamic>{
      'elements': [
        {
          'type': 'node',
          'id': 1,
          'lat': 46.201,
          'lon': 6.141,
          'tags': {'amenity': 'hospital', 'name': 'Hospital Test'},
        },
        {
          'type': 'way',
          'id': 2,
          'center': {'lat': 46.202, 'lon': 6.142},
          'tags': {
            'amenity': 'pharmacy',
            'name': 'Pharmacy Test',
            'opening_hours': '24/7',
          },
        },
        {
          'type': 'node',
          'id': 3,
          'lat': 46.203,
          'lon': 6.143,
          'tags': {'emergency': 'defibrillator'},
        },
      ],
    };

    final result = MapPoiService.parseOverpass(
      decoded,
      originLatitude: 46.2,
      originLongitude: 6.14,
    );

    expect(result, hasLength(3));
    expect(result.first.kind, MapPoiKind.hospital);
    expect(result[1].kind, MapPoiKind.pharmacy);
    expect(result[1].openingHours, '24/7');
    expect(result[2].kind, MapPoiKind.aed);
    expect(result.every((item) => item.trust == MapPoiTrust.community), isTrue);
  });

  test('SITG parser creates institutional hospital and AED points', () {
    final hospitals = MapPoiService.parseSitgFeatures(
      {
        'features': [
          {
            'attributes': {
              'OBJECTID': 10,
              'NOM_ETABLISSEMENT': 'Hôpital test',
              'ADRESSE': 'Rue Test 1',
            },
            'geometry': {'x': 6.14, 'y': 46.20},
          },
        ],
      },
      datasetId: 'DAS_HOPITAUX_CLINIQUES',
      originLatitude: 46.20,
      originLongitude: 6.14,
    );

    final aeds = MapPoiService.parseSitgFeatures(
      {
        'features': [
          {
            'attributes': {
              'OBJECTID': 20,
              'TYPE_DE_LIEU': 'Gare',
              'ADRESSE': 'Place Test 2',
              'H24': 'Oui',
            },
            'geometry': {'x': 6.15, 'y': 46.21},
          },
        ],
      },
      datasetId: 'DEAS_144_DEFIBRILLATEURS',
      originLatitude: 46.20,
      originLongitude: 6.14,
    );

    expect(hospitals.single.trust, MapPoiTrust.official);
    expect(hospitals.single.kind, MapPoiKind.hospital);
    expect(hospitals.single.address, 'Rue Test 1');
    expect(aeds.single.trust, MapPoiTrust.official);
    expect(aeds.single.kind, MapPoiKind.aed);
    expect(aeds.single.openingHours, '24/7');
  });

  test('institutional points replace nearby community duplicates', () {
    const official = MapPoi(
      id: 'official',
      name: 'Hospital',
      latitude: 46.20,
      longitude: 6.14,
      kind: MapPoiKind.hospital,
      trust: MapPoiTrust.official,
      sourceName: 'Authority',
      sourceUrl: 'https://example.org',
      distanceMeters: 0,
    );
    const communityDuplicate = MapPoi(
      id: 'community',
      name: 'Hospital OSM',
      latitude: 46.2003,
      longitude: 6.1403,
      kind: MapPoiKind.hospital,
      trust: MapPoiTrust.community,
      sourceName: 'OpenStreetMap',
      sourceUrl: 'https://example.org/osm',
      distanceMeters: 40,
    );

    final merged = MapPoiService.mergePreferOfficial(
      [official],
      [communityDuplicate],
    );

    expect(merged, hasLength(1));
    expect(merged.single.trust, MapPoiTrust.official);
  });
}
