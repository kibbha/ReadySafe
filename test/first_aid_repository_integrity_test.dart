import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/app/localizations.dart';
import 'package:readysafe/data/first_aid_repository.dart';

void main() {
  test('every first-aid repository key resolves in French and English', () {
    const fr = AppLocalizations(Locale('fr'));
    const en = AppLocalizations(Locale('en'));

    final keys = <String>{
      for (final guide in firstAidGuides) ...[
        guide.titleKey,
        guide.summaryKey,
        for (final step in guide.steps) step.textKey,
      ],
    };

    for (final key in keys) {
      expect(
        fr.get(key),
        isNot(key),
        reason: 'Missing French translation: $key',
      );
      expect(
        en.get(key),
        isNot(key),
        reason: 'Missing English translation: $key',
      );
    }
  });

  test('every first-aid illustration referenced by the repository exists', () {
    for (final guide in firstAidGuides) {
      for (final step in guide.steps) {
        expect(
          File(step.illustrationAsset).existsSync(),
          isTrue,
          reason: 'Missing illustration: ${step.illustrationAsset}',
        );
      }
    }
  });
}
