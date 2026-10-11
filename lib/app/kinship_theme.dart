import 'package:flutter/material.dart';

/// Kinship light palette. Deliberately fixed: no automatic dark inversion.
abstract final class KinshipColors {
  static const canvas = Color(0xFFF8F9F6);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF172B35);
  static const heading = Color(0xFF193039);
  static const secondary = Color(0xFF21333C);
  static const muted = Color(0xFF78878A);
  static const terracotta = Color(0xFFE89A78);
  static const line = Color(0xFFE6E9E4);
  static const mint = Color(0xFFDBECE4);
  static const softMint = Color(0xFFDFEFE7);
  static const sage = Color(0xFFE9EDE6);
  static const peach = Color(0xFFF9E7DD);
  static const success = Color(0xFF35654B);
  static const successBg = Color(0xFFE7F3E8);
  static const error = Color(0xFFA14734);
  static const errorBg = Color(0xFFFFF0EA);
  static const warningBg = Color(0xFFFBF3E7);
}

abstract final class KinshipTheme {
  static ThemeData get light {
    const colors = ColorScheme.light(
      primary: KinshipColors.ink,
      onPrimary: KinshipColors.white,
      secondary: KinshipColors.terracotta,
      onSecondary: KinshipColors.white,
      surface: KinshipColors.white,
      onSurface: KinshipColors.ink,
      error: KinshipColors.error,
      onError: KinshipColors.white,
      outline: KinshipColors.line,
    );
    const body = TextStyle(
      fontFamily: 'DM Sans',
      color: KinshipColors.secondary,
    );
    const display = TextStyle(
      fontFamily: 'Manrope',
      fontWeight: FontWeight.w800,
      color: KinshipColors.heading,
      letterSpacing: -1.0,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colors,
      scaffoldBackgroundColor: KinshipColors.canvas,
      fontFamily: 'DM Sans',
      textTheme: TextTheme(
        headlineLarge: display.copyWith(fontSize: 32, height: 1.17),
        headlineMedium: display.copyWith(fontSize: 32, height: 1.17),
        headlineSmall: display.copyWith(fontSize: 20, letterSpacing: -0.5),
        titleLarge: display.copyWith(fontSize: 20, letterSpacing: -0.5),
        titleMedium: display.copyWith(fontSize: 16, letterSpacing: -0.3),
        bodyLarge: body.copyWith(fontSize: 16, height: 1.45),
        bodyMedium: body.copyWith(fontSize: 14, height: 1.45),
        bodySmall: body.copyWith(
          fontSize: 12,
          height: 1.4,
          color: KinshipColors.muted,
        ),
        labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        labelSmall: body.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: KinshipColors.canvas,
        foregroundColor: KinshipColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 20,
          letterSpacing: -0.5,
          color: KinshipColors.heading,
        ),
      ),
      cardTheme: CardThemeData(
        color: KinshipColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: KinshipColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: KinshipColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KinshipColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KinshipColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KinshipColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: KinshipColors.terracotta,
            width: 2,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: KinshipColors.white,
        indicatorColor: KinshipColors.peach,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? KinshipColors.terracotta
                : KinshipColors.muted,
            size: 23,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? KinshipColors.ink
                : KinshipColors.muted,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: KinshipColors.line),
    );
  }
}
