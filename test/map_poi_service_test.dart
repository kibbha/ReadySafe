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
}
