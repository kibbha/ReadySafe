import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum EmergencySpeechAvailability {
  ready,
  languageUnavailable,
  offlineVoiceUnavailable,
  error,
}

/// Text-to-speech used by the guided first-aid mode.
///
/// ReadySafe never uploads the instruction text. On Android we deliberately
/// select an installed voice whose metadata does not require the network.
/// If no such voice is available, speech remains disabled instead of falling
/// back to a cloud voice.
class EmergencySpeechService {
  EmergencySpeechService({FlutterTts? engine}) : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;
  String? _locale;
  bool _prepared = false;

  bool get prepared => _prepared;

  static String localeFor(String languageCode) =>
      languageCode.toLowerCase().startsWith('en') ? 'en-US' : 'fr-FR';

  static bool _networkRequired(Object? value) {
    if (value is bool) return value;
    final normalized = '$value'.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static bool _sameLanguage(Object? candidate, String wanted) {
    final raw = '$candidate'.replaceAll('_', '-').toLowerCase();
    final target = wanted.toLowerCase();
    if (raw == target) return true;
    return raw.split('-').first == target.split('-').first;
  }

  Future<EmergencySpeechAvailability> prepare(String languageCode) async {
    final locale = localeFor(languageCode);

    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final installed = await _engine.isLanguageInstalled(locale);
        if (installed != true) {
          _prepared = false;
          return EmergencySpeechAvailability.offlineVoiceUnavailable;
        }

        final rawVoices = await _engine.getVoices;
        final voices = rawVoices is List ? rawVoices : const [];
        Map<String, dynamic>? localVoice;

        for (final raw in voices) {
          if (raw is! Map) continue;
          final voice = Map<String, dynamic>.from(raw);
          if (!_sameLanguage(voice['locale'], locale)) continue;
          if (_networkRequired(voice['network_required'])) continue;
          localVoice = voice;
          break;
        }

        if (localVoice == null) {
          _prepared = false;
          return EmergencySpeechAvailability.offlineVoiceUnavailable;
        }

        final name = '${localVoice['name'] ?? ''}'.trim();
        final voiceLocale = '${localVoice['locale'] ?? locale}'.trim();
        if (name.isNotEmpty) {
          await _engine.setVoice(<String, String>{
            'name': name,
            'locale': voiceLocale,
          });
        }
      } else {
        final available = await _engine.isLanguageAvailable(locale);
        if (available != true) {
          _prepared = false;
          return EmergencySpeechAvailability.languageUnavailable;
        }
      }

      await _engine.setLanguage(locale);
      await _engine.setSpeechRate(.46);
      await _engine.setVolume(1.0);
      await _engine.setPitch(1.0);
      await _engine.awaitSpeakCompletion(false);
      _locale = locale;
      _prepared = true;
      return EmergencySpeechAvailability.ready;
    } catch (_) {
      _prepared = false;
      return EmergencySpeechAvailability.error;
    }
  }

  Future<bool> speak(String text) async {
    if (!_prepared || text.trim().isEmpty) return false;
    try {
      await _engine.stop();
      final result = await _engine.speak(text, focus: true);
      return result == 1;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _engine.stop();
    } catch (_) {
      // Best effort: speech must never block emergency navigation.
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final next = localeFor(languageCode);
    if (_locale == next && _prepared) return;
    await stop();
    await prepare(languageCode);
  }

  Future<void> dispose() async {
    await stop();
  }
}
