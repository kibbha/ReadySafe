import 'dart:convert';
import 'dart:math' as math;

import 'package:xml/xml.dart';

import 'field_navigation.dart';

class GpxPoint {
  const GpxPoint(this.latitude, this.longitude, {this.elevation, this.label = ''});

  final double latitude;
  final double longitude;
  final double? elevation;
  final String label;

  Map<String, dynamic> toJson() => {
    'lat': latitude,
    'lon': longitude,
    if (elevation != null) 'ele': elevation,
    if (label.isNotEmpty) 'name': label,
  };

  factory GpxPoint.fromJson(Map<String, dynamic> json) {
    final lat = (json['lat'] as num?)?.toDouble();
    final lon = (json['lon'] as num?)?.toDouble();
    final ele = (json['ele'] as num?)?.toDouble();
    if (lat == null || lon == null ||
        !lat.isFinite || !lon.isFinite ||
        lat < -90 || lat > 90 || lon < -180 || lon > 180 ||
        (ele != null && (!ele.isFinite || ele < -15000 || ele > 15000))) {
      throw const FormatException('Invalid GPX coordinates or elevation');
    }
    final rawLabel = json['name'];
    final label = rawLabel is String
        ? rawLabel.replaceAll(RegExp(r'[\\x00-\\x1f\\x7f]'), ' ').trim()
        : '';
    return GpxPoint(lat, lon, elevation: ele,
        label: label.length > 80 ? label.substring(0, 80) : label);
  }
}

class GpxRoute {
  const GpxRoute({
    required this.id,
    required this.name,
    required this.segments,
    required this.waypoints,
    this.visible = true,
  });

  static const maxBytes = 2 * 1024 * 1024;
  static const maxPoints = 12000;
  static const maxWaypoints = 500;
  static const maxSegments = 200;

  final String id;
  final String name;
  final List<List<GpxPoint>> segments;
  final List<GpxPoint> waypoints;
  final bool visible;

  int get pointCount => segments.fold<int>(0, (n, seg) => n + seg.length);
  int get totalPointCount => pointCount + waypoints.length;

  double get lengthMeters {
    var distance = 0.0;
    for (final segment in segments) {
      for (var i = 1; i < segment.length; i++) {
        distance += FieldNavigation.between(
          fromLatitude: segment[i - 1].latitude,
          fromLongitude: segment[i - 1].longitude,
          toLatitude: segment[i].latitude,
          toLongitude: segment[i].longitude,
        ).distanceMeters;
      }
    }
    return distance;
  }

  GpxPoint? get firstPoint {
    for (final seg in segments) {
      if (seg.isNotEmpty) return seg.first;
    }
    return waypoints.isEmpty ? null : waypoints.first;
  }

  GpxRoute withVisibility(bool value) => GpxRoute(
    id: id,
    name: name,
    segments: segments,
    waypoints: waypoints,
    visible: value,
  );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'id': id,
    'name': name,
    'visible': visible,
    'segments': [
      for (final segment in segments)
        [for (final point in segment) point.toJson()],
    ],
    'waypoints': [for (final point in waypoints) point.toJson()],
  };

  factory GpxRoute.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 ||
        json['id'] is! String ||
        !RegExp(r'^gpx-[0-9]{10,18}$').hasMatch(json['id'] as String) ||
        json['name'] is! String ||
        json['segments'] is! List ||
        json['waypoints'] is! List) {
      throw const FormatException('Invalid saved GPX route');
    }
    final rawSegments = json['segments'] as List;
    final rawWaypoints = json['waypoints'] as List;
    if (rawSegments.length > maxSegments ||
        rawWaypoints.length > maxWaypoints) {
      throw const FormatException('GPX complexity limit exceeded');
    }
    var points = 0;
    final segments = <List<GpxPoint>>[];
    for (final raw in rawSegments) {
      if (raw is! List) throw const FormatException('Bad GPX segment');
      points += raw.length;
      if (points > maxPoints) throw const FormatException('Too many GPX points');
      segments.add(List.unmodifiable([
        for (final p in raw)
          GpxPoint.fromJson(Map<String, dynamic>.from(p as Map)),
      ]));
    }
    final waypoints = List<GpxPoint>.unmodifiable([
      for (final p in rawWaypoints)
        GpxPoint.fromJson(Map<String, dynamic>.from(p as Map)),
    ]);
    if (points == 0 && waypoints.isEmpty) {
      throw const FormatException('Empty GPX file');
    }
    final name = (json['name'] as String).trim();
    if (name.isEmpty || name.length > 80) {
      throw const FormatException('Bad saved GPX title');
    }
    return GpxRoute(
      id: json['id'] as String,
      name: name,
      segments: List.unmodifiable(segments),
      waypoints: waypoints,
      visible: json['visible'] != false,
    );
  }
}

/// GPX 1.0/1.1 reader: no network, DTD, external entities or arbitrary XML
/// metadata is retained. Import only coordinates, optional elevation and name.
class GpxCodec {
  const GpxCodec._();

  static GpxRoute decode(List<int> bytes, {
    required String id,
    required String fallbackName,
  }) {
    if (bytes.isEmpty || bytes.length > GpxRoute.maxBytes) {
      throw const FormatException('GPX exceeds 2 MiB or is empty');
    }
    final xml = utf8.decode(bytes, allowMalformed: false);
    if (RegExp(r'<!\s*(DOCTYPE|ENTITY)\b', caseSensitive: false).hasMatch(xml)) {
      throw const FormatException('GPX DTD/entity declarations are not allowed');
    }
    final doc = XmlDocument.parse(xml);
    final root = doc.rootElement;
    if (root.name.local != 'gpx') {
      throw const FormatException('Not a GPX document');
    }

    Iterable<XmlElement> direct(XmlElement parent, String tag) =>
        parent.children.whereType<XmlElement>().where(
          (element) => element.name.local == tag,
        );

    String text(XmlElement element, String tag) {
      final elements = direct(element, tag);
      return elements.isEmpty ? '' : elements.first.innerText.trim();
    }

    GpxPoint parsePoint(XmlElement element) {
      final lat = double.tryParse(element.getAttribute('lat') ?? '');
      final lon = double.tryParse(element.getAttribute('lon') ?? '');
      final e = text(element, 'ele');
      return GpxPoint.fromJson({
        'lat': lat,
        'lon': lon,
        if (e.isNotEmpty) 'ele': double.tryParse(e),
        if (element.name.local == 'wpt') 'name': text(element, 'name'),
      });
    }

    final segments = <List<GpxPoint>>[];
    final waypoints = <GpxPoint>[];
    var count = 0;
    void addSegment(Iterable<XmlElement> nodes) {
      final result = <GpxPoint>[];
      for (final node in nodes) {
        count++;
        if (count > GpxRoute.maxPoints) {
          throw const FormatException('Too many GPX track points');
        }
        result.add(parsePoint(node));
      }
      if (result.isNotEmpty) {
        if (segments.length >= GpxRoute.maxSegments) {
          throw const FormatException('Too many GPX segments');
        }
        segments.add(List.unmodifiable(result));
      }
    }

    var title = '';
    for (final trk in direct(root, 'trk')) {
      if (title.isEmpty) title = text(trk, 'name');
      for (final seg in direct(trk, 'trkseg')) {
        addSegment(direct(seg, 'trkpt'));
      }
    }
    for (final route in direct(root, 'rte')) {
      if (title.isEmpty) title = text(route, 'name');
      addSegment(direct(route, 'rtept'));
    }
    for (final waypoint in direct(root, 'wpt')) {
      if (waypoints.length >= GpxRoute.maxWaypoints) {
        throw const FormatException('Too many GPX waypoints');
      }
      waypoints.add(parsePoint(waypoint));
    }

    if (count == 0 && waypoints.isEmpty) {
      throw const FormatException('GPX has no track, route or waypoint');
    }
    title = (title.isEmpty ? fallbackName : title)
        .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ')
        .trim();
    if (title.isEmpty) title = 'GPX';
    if (title.length > 80) title = title.substring(0, 80);
    return GpxRoute(
      id: id,
      name: title,
      segments: List.unmodifiable(segments),
      waypoints: List.unmodifiable(waypoints),
    );
  }

  static String encode(GpxRoute route) {
    final builder = XmlBuilder();
    builder.declaration(encoding: 'UTF-8');
    builder.element('gpx', namespaces: {
      'http://www.topografix.com/GPX/1/1': '',
    }, attributes: {
      'version': '1.1',
      'creator': 'ReadySafe',
    }, nest: () {
      builder.element('trk', nest: () {
        builder.element('name', nest: route.name);
        for (final segment in route.segments) {
          builder.element('trkseg', nest: () {
            for (final point in segment) {
              builder.element('trkpt', attributes: {
                'lat': point.latitude.toStringAsFixed(7),
                'lon': point.longitude.toStringAsFixed(7),
              }, nest: () {
                if (point.elevation != null) {
                  builder.element('ele', nest: point.elevation!.toStringAsFixed(1));
                }
              });
            }
          });
        }
      });
      for (final waypoint in route.waypoints) {
        builder.element('wpt', attributes: {
          'lat': waypoint.latitude.toStringAsFixed(7),
          'lon': waypoint.longitude.toStringAsFixed(7),
        }, nest: () {
          if (waypoint.elevation != null) {
            builder.element('ele', nest: waypoint.elevation!.toStringAsFixed(1));
          }
          if (waypoint.label.isNotEmpty) {
            builder.element('name', nest: waypoint.label);
          }
        });
      }
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// Avoid huge annotation batches on weak/offline phones. Endpoints are kept,
  /// and segment boundaries are never joined by a fictitious line.
  static List<List<GpxPoint>> renderSegments(
    GpxRoute route, {int maximumVertices = 4000},
  ) {
    if (route.pointCount <= maximumVertices) {
      return route.segments.where((segment) => segment.length >= 2).toList();
    }
    final stride = math.max(2, (route.pointCount / maximumVertices).ceil());
    return [
      for (final segment in route.segments)
        if (segment.length >= 2)
          <GpxPoint>[
            for (var i = 0; i < segment.length; i += stride) segment[i],
            if ((segment.length - 1) % stride != 0) segment.last,
          ],
    ];
  }
}
