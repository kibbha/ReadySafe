import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/services/emergency_speech_service.dart';

void main() {
  test('emergency speech maps supported UI languages to installed voice locales', () {
    expect(EmergencySpeechService.localeFor('fr'), 'fr-FR');
    expect(EmergencySpeechService.localeFor('fr-CH'), 'fr-FR');
    expect(EmergencySpeechService.localeFor('en'), 'en-US');
    expect(EmergencySpeechService.localeFor('en-GB'), 'en-US');
  });
}
