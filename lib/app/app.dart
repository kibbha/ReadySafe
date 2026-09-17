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
    const teal = Color(0xff087f83);
    const tealDark = Color(0xff075e68);
    const emergency = Color(0xffd92d36);
    const ink = Color(0xff172126);
    const canvas = Color(0xfff7fafb);
    const outline = Color(0xffdbe5e7);

    final scheme = ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.light,
    ).copyWith(
      primary: teal,
      secondary: tealDark,
      error: emergency,
      surface: Colors.white,
      onSurface: ink,
      outline: outline,
    );

    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, _) => MaterialApp(
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
          theme: ThemeData(
            colorScheme: scheme,
            useMaterial3: true,
            scaffoldBackgroundColor: canvas,
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
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
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: outline),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              height: 68,
              elevation: 0,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xffd9f1f1),
              labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w600,
                color: states.contains(WidgetState.selected) ? tealDark : const Color(0xff59686d),
              )),
              iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
                color: states.contains(WidgetState.selected) ? teal : const Color(0xff65747a),
                size: 23,
              )),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                minimumSize: const Size(64, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(64, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: outline),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xfff2f6f7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: teal, width: 1.5),
              ),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xffeef4f5),
              selectedColor: const Color(0xffd7eeee),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: ink),
            ),
            dividerTheme: const DividerThemeData(color: outline, thickness: 1),
            listTileTheme: const ListTileThemeData(
              minVerticalPadding: 10,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              iconColor: tealDark,
              textColor: ink,
            ),
          ),
          home: !controller.ready
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : controller.settings.onboardingComplete
                  ? const MainShell()
                  : const OnboardingScreen(),
        ),
      ),
    );
  }
}
