import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localizations.dart';
import '../screens/home_screen.dart';

class ReadySafeApp extends StatelessWidget {
  const ReadySafeApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ReadySafe',
    debugShowCheckedModeBanner: false,
    locale: const Locale('fr'),
    supportedLocales: const [Locale('fr'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff075e68),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xfff7f9fa),
      appBarTheme: const AppBarTheme(centerTitle: false),
    ),
    home: const HomeScreen(),
  );
}
