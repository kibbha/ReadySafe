import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../screens/main_shell.dart';
import '../screens/onboarding_screen.dart';
import '../services/app_settings_service.dart';
import 'accessibility.dart';
import 'app_controller.dart';
import 'app_scope.dart';
import 'app_theme.dart';
import 'localizations.dart';

class ReadySafeApp extends StatefulWidget {
  const ReadySafeApp({super.key, this.settingsService});
  final AppSettingsService? settingsService;

  @override
  State<ReadySafeApp> createState() => _ReadySafeAppState();
}

class _ReadySafeAppState extends State<ReadySafeApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AppController(widget.settingsService ?? AppSettingsService())..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, _) {
          final settings = controller.settings;

          return MaterialApp(
            title: 'ReadySafe',
            debugShowCheckedModeBanner: false,
            locale: Locale(settings.localeCode),
            supportedLocales: const [
              Locale('fr'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: ReadySafeTheme.modeFor(settings.themeModeCode),
            theme: ReadySafeTheme.light(
              highContrast: settings.highContrast,
              largeText: settings.largeText,
            ),
            darkTheme: ReadySafeTheme.dark(
              highContrast: settings.highContrast,
              largeText: settings.largeText,
            ),
            builder: (context, child) {
              final media = MediaQuery.of(context);
              final multiplier = settings.largeText ? 1.18 : 1.0;
              return MediaQuery(
                data: media.copyWith(
                  textScaler: ReadySafeTextScaler(
                    base: media.textScaler,
                    multiplier: multiplier,
                  ),
                  highContrast: media.highContrast || settings.highContrast,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: !controller.ready
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : settings.onboardingComplete
                    ? const MainShell()
                    : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
