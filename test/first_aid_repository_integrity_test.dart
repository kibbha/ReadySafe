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
        if (guide.definitionTitleKey != null) guide.definitionTitleKey!,
        if (guide.definitionBodyKey != null) guide.definitionBodyKey!,
        ...guide.warningKeys,
        for (final step in guide.steps) ...[
          step.textKey,
          if (step.headingKey != null) step.headingKey!,
          ...step.detailKeys,
        ],
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

  test('priority life-saving guides required by the redesign are present', () {
    final ids = firstAidGuides.map((guide) => guide.id).toSet();

    expect(ids, contains('wounds'));
    expect(ids, contains('waiting_positions'));
    expect(ids, containsAll(<String>[
      'unconscious',
      'cpr_adult',
      'bleeding',
      'choking_adult',
      'choking_child',
      'choking_infant',
      'burn',
      'stroke',
      'chest_pain',
      'anaphylaxis',
      'seizure',
      'drowning',
      'hypothermia',
      'heatstroke',
    ]));
  });

  test('CPR guides expose exactly the steps that can be paced', () {
    final pacedGuides = firstAidGuides.where(
      (guide) => guide.supportsCprMetronome,
    );

    expect(pacedGuides, isNotEmpty);
    for (final guide in pacedGuides) {
      expect(
        guide.steps.where((step) => step.cprPacing),
        isNotEmpty,
        reason: '${guide.id} enables pacing but has no paced step',
      );
    }
  });

  test('production first-aid guides never fall back to generic pictograms', () {
    const genericAssets = <String>{
      'assets/illustrations/assess.svg',
      'assets/illustrations/call.svg',
      'assets/illustrations/care.svg',
    };

    for (final guide in firstAidGuides) {
      for (final step in guide.steps) {
        expect(
          genericAssets.contains(step.illustrationAsset),
          isFalse,
          reason:
              '${guide.id} still uses generic artwork: ${step.illustrationAsset}',
        );
      }
    }
  });

  test('approved unconscious full-sheet image is bundled', () {
    const path =
        'assets/first_aid_sheets/unconscious_pls_approved.webp';

    expect(
      File(path).existsSync(),
      isTrue,
      reason: 'Missing approved image sheet: $path',
    );
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
