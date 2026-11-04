import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/models/field_navigation.dart';
import 'package:readysafe/screens/field_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('offline great-circle navigation', () {
    test('north and east bearings are geographic (true-north)', () {
      final north = FieldNavigation.between(
        fromLatitude: 0, fromLongitude: 0,
        toLatitude: 1, toLongitude: 0,
      );
      expect(north.bearingDegrees, closeTo(0, 0.001));
      expect(north.distanceMeters, closeTo(111195, 150));
      expect(north.cardinal(false), 'N');

      final east = FieldNavigation.between(
        fromLatitude: 0, fromLongitude: 0,
        toLatitude: 0, toLongitude: 1,
      );
      expect(east.bearingDegrees, closeTo(90, 0.001));
      expect(east.cardinal(true), 'E');
    });

    test('zero-distance waypoint is not treated as a route', () {
      final leg = FieldNavigation.between(
        fromLatitude: 46.2044, fromLongitude: 6.1432,
        toLatitude: 46.2044, toLongitude: 6.1432,
      );
      expect(leg.distanceMeters, closeTo(0, 0.01));
      expect(leg.bearingDegrees, 0);
      expect(leg.distanceLabel(false), '0 m');
    });

    test('wraps across international dateline, not around the earth', () {
      final leg = FieldNavigation.between(
        fromLatitude: 0, fromLongitude: 179.9,
        toLatitude: 0, toLongitude: -179.9,
      );
      expect(leg.distanceMeters, lessThan(30000));
      expect(leg.bearingDegrees, closeTo(90, 0.1));
    });

    test('invalid coordinates reject safely', () {
      expect(
        () => FieldNavigation.between(
          fromLatitude: double.nan, fromLongitude: 0,
          toLatitude: 0, toLongitude: 0,
        ),
        throwsFormatException,
      );
      expect(
        () => FieldNavigation.between(
          fromLatitude: 46, fromLongitude: 6,
          toLatitude: -100, toLongitude: 6,
        ),
        throwsFormatException,
      );
    });
  });

  testWidgets('locally saved map points appear without requesting GPS',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'personal_safety_markers_v3': jsonEncode([
        {
          'id': 'camp-1',
          'name': 'Campement',
          'lat': 46.2044,
          'lng': 6.1432,
          'kind': 'personal',
        },
        {
          'id': 'bad',
          'name': 'Invalid',
          'lat': 999,
          'lng': 1,
          'kind': 'personal',
        },
      ]),
    });

    await tester.pumpWidget(
      const MaterialApp(locale: Locale('fr'), home: FieldNavigationScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Campement'), findsWidgets);
    expect(find.text('Invalid'), findsNothing);
    expect(find.text('Actualiser ma position'), findsOneWidget);
    expect(find.textContaining('cap n’est PAS un itinéraire'), findsOneWidget);
  });
}
