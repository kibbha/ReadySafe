import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../screens/main_shell.dart';
import '../screens/onboarding_screen.dart';
import '../services/app_settings_service.dart';
import 'app_controller.dart';
import 'app_scope.dart';
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
    controller = AppController(widget.settingsService ?? AppSettingsService())..load();
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
          final highContrast = controller.settings.highContrast;
          const teal = Color(0xff087f83);
          const tealDark = Color(0xff075e68);
          const emergency = Color(0xffd92d36);
          final ink = highContrast ? Colors.black : const Color(0xff172126);
          final canvas = highContrast ? Colors.white : const Color(0xfff7fafb);
          final outline = highContrast ? const Color(0xff526064) : const Color(0xffdbe5e7);
          final surfaceMuted = highContrast ? const Color(0xfff0f2f2) : const Color(0xfff2f6f7);

          final scheme = ColorScheme.fromSeed(
            seedColor: teal,
            brightness: Brightness.light,
          ).copyWith(
            primary: highContrast ? const Color(0xff006a6d) : teal,
            secondary: tealDark,
            error: highContrast ? const Color(0xffb00020) : emergency,
            surface: Colors.white,
            onSurface: ink,
            outline: outline,
          );

          return MaterialApp(
            title: 'ReadySafe',
            debugShowCheckedModeBanner: false,
            locale: Locale(controller.settings.localeCode),
            supportedLocales: const [Locale('fr'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              final media = MediaQuery.of(context);
              final scale = controller.settings.largeText ? 1.18 : 1.0;
              return MediaQuery(
                data: media.copyWith(
                  textScaler: TextScaler.linear(scale),
                  highContrast: controller.settings.highContrast,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            theme: ThemeData(
              colorScheme: scheme,
              useMaterial3: true,
              scaffoldBackgroundColor: canvas,
              fontFamily: 'Roboto',
              appBarTheme: AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: canvas,
                foregroundColor: ink,
                titleTextStyle: TextStyle(
                  color: ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: highContrast ? 1 : 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: outline,
                    width: highContrast ? 1.5 : 1,
                  ),
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                height: controller.settings.largeText ? 74 : 68,
                elevation: 0,
                backgroundColor: Colors.white,
                indicatorColor: highContrast ? const Color(0xffc8ece8) : const Color(0xffd9f1f1),
                labelTextStyle: WidgetStateProperty.resolveWith(
                  (states) => TextStyle(
                    fontSize: controller.settings.largeText ? 12 : 11,
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w800
                        : FontWeight.w700,
                    color: states.contains(WidgetState.selected)
                        ? tealDark
                        : (highContrast ? Colors.black87 : const Color(0xff59686d)),
                  ),
                ),
                iconTheme: WidgetStateProperty.resolveWith(
                  (states) => IconThemeData(
                    color: states.contains(WidgetState.selected)
                        ? scheme.primary
                        : (highContrast ? Colors.black87 : const Color(0xff65747a)),
                    size: controller.settings.largeText ? 25 : 23,
                  ),
                ),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  minimumSize: Size(64, controller.settings.largeText ? 54 : 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(64, controller.settings.largeText ? 52 : 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(
                    color: outline,
                    width: highContrast ? 1.5 : 1,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: surfaceMuted,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: outline,
                    width: highContrast ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: scheme.primary,
                    width: highContrast ? 2 : 1.5,
                  ),
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: highContrast ? const Color(0xffecefef) : const Color(0xffeef4f5),
                selectedColor: highContrast ? const Color(0xffc7e8e5) : const Color(0xffd7eeee),
                side: highContrast ? BorderSide(color: outline) : BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              dividerTheme: DividerThemeData(
                color: outline,
                thickness: highContrast ? 1.5 : 1,
              ),
              listTileTheme: ListTileThemeData(
                minVerticalPadding: 10,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                iconColor: highContrast ? Colors.black87 : tealDark,
                textColor: ink,
              ),
            ),
            home: !controller.ready
                ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                : controller.settings.onboardingComplete
                    ? const MainShell()
                    : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
