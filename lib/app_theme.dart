import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reference-style dark palette (charcoal, card grey, purple–blue accents).
abstract final class AppPalette {
  static const charcoal = Color(0xFF1E1E22);
  static const cardGrey = Color(0xFF323238);
  static const navBar = Color(0xFF25252B);
  static const tealNav = Color(0xFF2DD4BF);
  static const ringTrack = Color(0xFF4A4A52);
  static const ringProgress = Color(0xFFDCE775);
  static const purpleGrad = Color(0xFFA855F7);
  static const blueGrad = Color(0xFF60A5FA);
  static const mutedNav = Color(0xFF8B8B96);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.blueGrad,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF3D4A63),
    onPrimaryContainer: Colors.white,
    secondary: AppPalette.tealNav,
    onSecondary: Colors.black,
    tertiary: AppPalette.purpleGrad,
    onTertiary: Colors.white,
    error: const Color(0xFFFF6B6B),
    onError: Colors.white,
    surface: AppPalette.charcoal,
    onSurface: Colors.white,
    onSurfaceVariant: const Color(0xFFB0B0BC),
    outline: const Color(0xFF52525C),
    outlineVariant: const Color(0xFF3F3F48),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Colors.white,
    onInverseSurface: AppPalette.charcoal,
    inversePrimary: AppPalette.blueGrad,
    surfaceTint: Colors.transparent,
    surfaceContainerHighest: AppPalette.cardGrey,
    surfaceContainerHigh: AppPalette.cardGrey,
    surfaceContainer: AppPalette.cardGrey,
    surfaceContainerLow: AppPalette.cardGrey,
    surfaceContainerLowest: AppPalette.charcoal,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppPalette.charcoal,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: AppPalette.charcoal,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppPalette.cardGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.cardGrey,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.blueGrad, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: AppPalette.blueGrad,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppPalette.cardGrey,
      contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
