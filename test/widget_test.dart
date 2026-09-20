import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first launch requires country onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ReadySafeApp());
    await tester.pumpAndSettle();

    expect(find.text('ReadySafe'), findsOneWidget);
    expect(
      find.text('Sélectionnez votre pays de résidence'),
      findsOneWidget,
    );
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets(
    'onboarding language can switch before country selection',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const ReadySafeApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      expect(
        find.text('Select your country of residence'),
        findsOneWidget,
      );
      expect(find.text('Continue'), findsOneWidget);
    },
  );

  testWidgets(
    'saved residence opens situation-first ReadySafe dashboard',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'settings.residenceCountry': 'FR',
      });
      await tester.pumpWidget(const ReadySafeApp());
      await tester.pumpAndSettle();

      expect(find.text('ReadySafe'), findsOneWidget);
      expect(find.textContaining('France'), findsOneWidget);
      expect(find.text('QUE SE PASSE-T-IL ?'), findsOneWidget);
      expect(find.text('Une personne est en danger'), findsOneWidget);
      expect(find.text('Je dois me protéger'), findsOneWidget);
      expect(find.text('Je cherche un lieu utile'), findsOneWidget);
      expect(find.text('Je veux me préparer'), findsOneWidget);
      expect(find.text('Gestes qui sauvent'), findsOneWidget);
      expect(find.text('Famille & documents'), findsOneWidget);
      expect(find.text('Kits'), findsWidgets);
      expect(find.text('Carte'), findsWidgets);
    },
  );

  testWidgets(
    'saved English locale renders primary shell navigation in English',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'settings.residenceCountry': 'FR',
        'settings.locale': 'en',
      });
      await tester.pumpWidget(const ReadySafeApp());
      await tester.pumpAndSettle();

      expect(find.text('ReadySafe'), findsOneWidget);
      expect(find.text('WHAT IS HAPPENING?'), findsOneWidget);
      expect(find.text('A person is in danger'), findsOneWidget);
      expect(find.text('I need to protect myself'), findsOneWidget);
      expect(find.text('I need a useful place'), findsOneWidget);
      expect(find.text('I want to get prepared'), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Emergency'), findsWidgets);
      expect(find.text('Map'), findsWidgets);
      expect(find.text('Accueil'), findsNothing);
    },
  );

  testWidgets('saved dark appearance selects dark theme mode', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.residenceCountry': 'CH',
      'settings.themeMode': 'dark',
    });

    await tester.pumpWidget(const ReadySafeApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.darkTheme?.brightness, Brightness.dark);
    expect(find.textContaining('Suisse'), findsOneWidget);
  });
}
