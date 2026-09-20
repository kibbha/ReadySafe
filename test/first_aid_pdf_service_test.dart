import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/app/localizations.dart';
import 'package:readysafe/data/first_aid_repository.dart';
import 'package:readysafe/services/first_aid_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first-aid PDF export is generated fully offline', () async {
    const strings = AppLocalizations(Locale('fr'));
    final guide = firstAidGuides.firstWhere((item) => item.id == 'cpr_adult');

    final bytes = await FirstAidPdfService.build(
      guide: guide,
      text: (key) => strings.get(key),
      english: false,
      emergencyNumber: '144',
    );

    expect(bytes.length, greaterThan(1500));
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
  });
}
