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

  testWidgets('saved residence opens all-in-one ReadySafe dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.residenceCountry': 'FR'});
    await tester.pumpWidget(const ReadySafeApp());
    await tester.pumpAndSettle();

    expect(find.text('ReadySafe'), findsOneWidget);
    expect(find.textContaining('France'), findsOneWidget);
    expect(find.text('URGENCE — GUIDEZ-MOI'), findsOneWidget);
    expect(find.text('Premiers secours'), findsWidgets);
    expect(find.text('Kit & check-lists'), findsOneWidget);
    expect(find.text('Famille & documents'), findsOneWidget);
    expect(find.text('Carte & repères'), findsOneWidget);
    expect(find.text('Kits'), findsWidgets);
    expect(find.text('Carte'), findsWidgets);
  });

  testWidgets('saved English locale renders primary shell navigation in English', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.residenceCountry': 'FR',
      'settings.locale': 'en',
    });
    await tester.pumpWidget(const ReadySafeApp());
    await tester.pumpAndSettle();

    expect(find.text('ReadySafe'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Emergency'), findsWidgets);
    expect(find.text('Map'), findsWidgets);
    expect(find.text('First aid'), findsOneWidget);
    expect(find.text('Accueil'), findsNothing);
  });
}
