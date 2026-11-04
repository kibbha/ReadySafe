import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/data/field_guide_repository.dart';
import 'package:readysafe/models/field_guide_entry.dart';
import 'package:readysafe/screens/field_guide_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled field guide parses and works without network services', () async {
    final entries = await FieldGuideRepository.load();

    expect(entries.length, 14);
    expect(entries.map((entry) => entry.id).toSet().length, entries.length);
    expect(entries.where((e) => e.category == FieldGuideCategory.plants).length, 4);
    expect(entries.where((e) => e.category == FieldGuideCategory.mushrooms).length, 4);
    expect(entries.where((e) => e.category == FieldGuideCategory.skills).length, 6);

    for (final entry in entries) {
      expect(entry.title(false), isNotEmpty);
      expect(entry.title(true), isNotEmpty);
      expect(entry.warning(false), isNotEmpty);
      expect(entry.warning(true), isNotEmpty);
      expect(entry.steps(false), isNotEmpty);
      expect(entry.steps(true), isNotEmpty);
      expect(Uri.parse(entry.sourceUrl).isScheme('https'), isTrue);
    }
  });

  test('search is accent-insensitive, multilingual and category-aware', () async {
    final entries = await FieldGuideRepository.load();

    expect(FieldGuideRepository.search(entries, query: 'ortie').single.id, 'urtica-dioica');
    expect(FieldGuideRepository.search(entries, query: 'phalloide').single.id, 'amanita-phalloides');
    expect(FieldGuideRepository.search(entries, query: 'FERRO ROD', english: true).single.id, 'fire-ferrocerium');
    expect(
      FieldGuideRepository.search(entries, query: 'amanite', category: FieldGuideCategory.plants),
      isEmpty,
    );
  });

  testWidgets('field guide opens from bundled data and filters locally', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FieldGuideScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Encyclopédie de survie'), findsOneWidget);
    expect(find.textContaining('14 fiches hors ligne'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'galere');
    await tester.pumpAndSettle();

    expect(find.text('Galère marginée'), findsOneWidget);
    expect(find.text('Amanite phalloïde'), findsNothing);
  });
}
