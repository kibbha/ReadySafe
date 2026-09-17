import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first launch requires country onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ReadySafeApp());
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue dans ReadySafe'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('saved residence opens localized home', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.residenceCountry': 'FR'});
    await tester.pumpWidget(const ReadySafeApp());
    await tester.pumpAndSettle();

    expect(find.text('READYSAFE'), findsOneWidget);
    expect(find.text('France'), findsOneWidget);
    expect(find.text('Urgences'), findsWidgets);
  });

  testWidgets('saved English locale renders the shell in English', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.residenceCountry': 'FR',
      'settings.locale': 'en',
    });
    await tester.pumpWidget(const ReadySafeApp());
    await tester.pumpAndSettle();

    expect(find.text('READYSAFE'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Emergencies'), findsWidgets);
    expect(find.text('First aid'), findsWidgets);
    expect(find.text('Accueil'), findsNothing);
    expect(find.text('Urgences'), findsNothing);
  });
}
