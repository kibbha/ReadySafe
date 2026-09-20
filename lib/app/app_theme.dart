import 'package:flutter/material.dart';

class ReadySafeColors {
  const ReadySafeColors._();

  static const blue = Color(0xff1268d8);
  static const blueDark = Color(0xff0c4fa8);
  static const teal = Color(0xff087f83);
  static const tealDark = Color(0xff075e68);
  static const emergency = Color(0xffd92d36);
  static const aed = Color(0xffe98a15);
  static const warning = Color(0xff9a6a00);

  static const lightCanvas = Color(0xfff7fafb);
  static const lightSurface = Colors.white;
  static const lightInk = Color(0xff172126);
  static const lightMuted = Color(0xff59686d);
  static const lightOutline = Color(0xffdbe5e7);

  static const darkCanvas = Color(0xff0f171a);
  static const darkSurface = Color(0xff172226);
  static const darkSurfaceMuted = Color(0xff1e2c31);
  static const darkInk = Color(0xfff3f7f8);
  static const darkMuted = Color(0xffb8c6ca);
  static const darkOutline = Color(0xff43545a);
}

class ReadySafeTheme {
  const ReadySafeTheme._();

  static ThemeData light({
    required bool highContrast,
    required bool largeText,
  }) =>
      _theme(
        brightness: Brightness.light,
        highContrast: highContrast,
        largeText: largeText,
      );

  static ThemeData dark({
    required bool highContrast,
    required bool largeText,
  }) =>
      _theme(
        brightness: Brightness.dark,
        highContrast: highContrast,
        largeText: largeText,
      );

  static ThemeMode modeFor(String code) => switch (code) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static ThemeData _theme({
    required Brightness brightness,
    required bool highContrast,
    required bool largeText,
  }) {
    final dark = brightness == Brightness.dark;

    final canvas = highContrast
        ? (dark ? Colors.black : Colors.white)
        : (dark ? ReadySafeColors.darkCanvas : ReadySafeColors.lightCanvas);
    final surface = highContrast
        ? (dark ? const Color(0xff080808) : Colors.white)
        : (dark ? ReadySafeColors.darkSurface : ReadySafeColors.lightSurface);
    final surfaceMuted = highContrast
        ? (dark ? const Color(0xff151515) : const Color(0xfff0f2f2))
        : (dark
            ? ReadySafeColors.darkSurfaceMuted
            : const Color(0xfff2f6f7));
    final ink = highContrast
        ? (dark ? Colors.white : Colors.black)
        : (dark ? ReadySafeColors.darkInk : ReadySafeColors.lightInk);
    final muted = highContrast
        ? (dark ? const Color(0xffe5e5e5) : const Color(0xff333333))
        : (dark ? ReadySafeColors.darkMuted : ReadySafeColors.lightMuted);
    final outline = highContrast
        ? (dark ? const Color(0xffd7d7d7) : const Color(0xff526064))
        : (dark ? ReadySafeColors.darkOutline : ReadySafeColors.lightOutline);

    final scheme = ColorScheme.fromSeed(
      seedColor: ReadySafeColors.blue,
      brightness: brightness,
    ).copyWith(
      primary: highContrast
          ? (dark ? const Color(0xff8fc8ff) : const Color(0xff004f9e))
          : ReadySafeColors.blue,
      secondary: highContrast
          ? (dark ? const Color(0xff7ee1df) : const Color(0xff006a6d))
          : ReadySafeColors.teal,
      tertiary: ReadySafeColors.aed,
      error: highContrast
          ? (dark ? const Color(0xffff8f98) : const Color(0xffb00020))
          : ReadySafeColors.emergency,
      surface: surface,
      onSurface: ink,
      outline: outline,
    );

    final borderRadius = BorderRadius.circular(18);

    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      dividerColor: outline,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: canvas,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -.35,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: highContrast ? 1 : 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: outline,
            width: highContrast ? 1.7 : 1,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: largeText ? 76 : 68,
        elevation: 0,
        backgroundColor: surface,
        indicatorColor: highContrast
            ? (dark ? const Color(0xff174c69) : const Color(0xffc7e3ff))
            : (dark ? const Color(0xff173f5d) : const Color(0xffdeedff)),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: largeText ? 12.5 : 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color:
                states.contains(WidgetState.selected) ? scheme.primary : muted,
            size: largeText ? 26 : 23,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: dark
            ? const Color(0xff173f5d)
            : const Color(0xffdeedff),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: muted,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(64, largeText ? 56 : 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: Size(64, largeText ? 54 : 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: outline,
            width: highContrast ? 1.7 : 1,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: outline,
            width: highContrast ? 1.7 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.primary,
            width: highContrast ? 2.3 : 1.6,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: dark
            ? const Color(0xff173f5d)
            : const Color(0xffdeedff),
        side: BorderSide(
          color: highContrast ? outline : Colors.transparent,
          width: highContrast ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        iconColor: scheme.secondary,
        textColor: ink,
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: ink,
            displayColor: ink,
          ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xffe9eff1) : const Color(0xff172126),
        contentTextStyle: TextStyle(
          color: dark ? const Color(0xff172126) : Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
