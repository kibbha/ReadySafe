import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/app/app_controller.dart';
import 'package:readysafe/app/app_scope.dart';
import 'package:readysafe/app/localizations.dart';
import 'package:readysafe/screens/emergency_screen.dart';
import 'package:readysafe/services/app_settings_service.dart';
import 'package:readysafe/services/emergency_call_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCallService implements EmergencyCallService {
  String? called;
  @override
  Future<bool> call(String number) async {
    called = number;
    return true;
  }
}

void main() {
  testWidgets('emergency call requires explicit confirmation', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.residenceCountry': 'FR'});
    final controller = AppController(AppSettingsService());
    await controller.load();
    final calls = _FakeCallService();
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: const [Locale('fr'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: EmergencyScreen(callService: calls),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('112').first);
    await tester.pumpAndSettle();
    expect(calls.called, isNull);
    expect(find.text('Confirmer l’appel'), findsOneWidget);
    await tester.tap(find.text('Appeler').last);
    await tester.pumpAndSettle();
    expect(calls.called, '112');
  });
}
