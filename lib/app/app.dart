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
    controller = AppController(widget.settingsService ?? AppSettingsService())
      ..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff075e68)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xfff7f9fa),
          appBarTheme: const AppBarTheme(centerTitle: false),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 52)),
          ),
          listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
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
