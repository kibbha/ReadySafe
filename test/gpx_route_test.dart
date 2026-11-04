import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/models/gpx_route.dart';
import 'package:readysafe/services/gpx_library_service.dart';

const _sample = '''<?xml version="1.0" encoding="UTF-8"?>
<gpx xmlns="http://www.topografix.com/GPX/1/1" creator="test" version="1.1">
 <trk>
  <name>Tour du lac</name>
  <trkseg>
   <trkpt lat="46.2044" lon="6.1432"><ele>385.5</ele></trkpt>
   <trkpt lat="46.2050" lon="6.1450"><ele>386.1</ele></trkpt>
  </trkseg>
  <trkseg>
   <trkpt lat="46.2200" lon="6.1600" />
   <trkpt lat="46.2300" lon="6.1700" />
  </trkseg>
 </trk>
 <wpt lat="46.2022" lon="6.1412"><name>Source</name></wpt>
</gpx>''';

void main() {
  test('reads GPX 1.1 offline and keeps split segments separate', () {
    final route = GpxCodec.decode(
      utf8.encode(_sample),
      id: 'gpx-1234567890123456',
      fallbackName: 'demo',
    );
    expect(route.name, 'Tour du lac');
    expect(route.pointCount, 4);
    expect(route.segments.length, 2);
    expect(route.waypoints.length, 1);
    expect(route.waypoints.single.label, 'Source');
    expect(route.segments.first.first.elevation, 385.5);
    expect(route.lengthMeters, greaterThan(0));
    expect(route.firstPoint!.latitude, 46.2044);
  });

  test('GPX export can be reimported without merging disconnected segments', () {
    final original = GpxCodec.decode(
      utf8.encode(_sample),
      id: 'gpx-1234567890123456',
      fallbackName: 'demo',
    );
    final generated = GpxCodec.encode(original);
    expect(generated, contains('GPX/1/1'));
    final second = GpxCodec.decode(
      utf8.encode(generated),
      id: 'gpx-1234567890123457',
      fallbackName: 'roundtrip',
    );
    expect(second.name, original.name);
    expect(second.segments.length, 2);
    expect(second.pointCount, 4);
    expect(second.waypoints.length, 1);
    expect(second.waypoints.single.label, 'Source');
  });

  test('rejects invalid coordinates, oversized XML and XML DTD declarations', () {
    final bad = _sample.replaceFirst('lon="6.1432"', 'lon="200"');
    expect(
      () => GpxCodec.decode(utf8.encode(bad),
          id: 'gpx-1234567890123456', fallbackName: 'bad'),
      throwsFormatException,
    );
    const entity = '''<!DOCTYPE gpx [
<!ENTITY evil SYSTEM "file:///etc/passwd">
]><gpx version="1.1"><wpt lat="46" lon="6">&evil;</wpt></gpx>''';
    expect(
      () => GpxCodec.decode(utf8.encode(entity),
          id: 'gpx-1234567890123456', fallbackName: 'bad'),
      throwsFormatException,
    );
    expect(
      () => GpxCodec.decode(
          List<int>.filled(GpxRoute.maxBytes + 1, 65),
          id: 'gpx-1234567890123456', fallbackName: 'large'),
      throwsFormatException,
    );
    expect(
      () => GpxCodec.decode(utf8.encode('<root/>'),
          id: 'gpx-1234567890123456', fallbackName: 'bad'),
      throwsFormatException,
    );
  });

  test('tracks, routes and standalone waypoints are supported', () {
    const xml = '''<gpx version="1.1">
      <rte><name>Col</name>
        <rtept lat="46" lon="7"/><rtept lat="46.1" lon="7.2"/>
      </rte>
      <wpt lat="45.9" lon="6.9"/>
    </gpx>''';
    final route = GpxCodec.decode(utf8.encode(xml),
        id: 'gpx-1234567890123456', fallbackName: 'route');
    expect(route.name, 'Col');
    expect(route.segments.single.length, 2);
    expect(route.waypoints.single.longitude, 6.9);
  });

  test('render simplification keeps endpoints and segment boundaries', () {
    final points = [
      for (var i = 0; i < 3000; i++)
        GpxPoint(46 + i * 0.00001, 6 + i * 0.00001),
    ];
    final route = GpxRoute(
      id: 'gpx-1234567890123456',
      name: 'Mountain trail',
      segments: [points],
      waypoints: const [],
    );
    final rendered = GpxCodec.renderSegments(route, maximumVertices: 600);
    expect(rendered.length, 1);
    expect(rendered.single.first.latitude, points.first.latitude);
    expect(rendered.single.last.longitude, points.last.longitude);
    expect(rendered.single.length, lessThanOrEqualTo(601));
    expect(route.pointCount, 3000);
  });

  test('local library saves, hides, reloads and deletes without network',
      () async {
    final temp = await Directory.systemTemp.createTemp('readysafe-gpx-');
    final library = GpxLibraryService(rootDirectory: temp);
    try {
      final saved = await library.importBytes(utf8.encode(_sample), 'sample.gpx');
      var routes = await library.list();
      expect(routes.length, 1);
      expect(routes.first.name, 'Tour du lac');
      expect(routes.first.visible, isTrue);

      await library.setVisibility(saved, false);
      routes = await library.list();
      expect(routes.single.visible, isFalse);
      expect(routes.single.pointCount, 4);

      await library.delete(routes.single);
      expect(await library.list(), isEmpty);
    } finally {
      await temp.delete(recursive: true);
    }
  });
}
