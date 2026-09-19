import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the ten validated first-aid posters are bundled', () {
    const ids = <String>[
      'cpr_adult',
      'choking_adult',
      'unconscious',
      'bleeding',
      'aed',
      'cpr_child',
      'cpr_infant',
      'choking_infant',
      'drowning',
      'anaphylaxis',
    ];

    for (final id in ids) {
      final file = File('assets/illustrations/posters/$id.png');
      expect(file.existsSync(), isTrue, reason: 'Missing poster for $id');
      expect(file.lengthSync(), greaterThan(100000),
          reason: 'Poster for $id looks empty or truncated');
    }
  });
}
