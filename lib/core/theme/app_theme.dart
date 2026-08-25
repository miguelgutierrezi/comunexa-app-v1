import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema Comunexa alineado al login Figma (light / dark).
abstract final class AppTheme {
  static const Color seedColor = Color(0xFF2563EB);
  static const Color accentTeal = Color(0xFF00B4A6);
  static const Color accentViolet = Color(0xFF7A4DFF);
  static const Color ink = Color(0xFF0D1B2A);
  static const Color slate = Color(0xFF64748B);
  static const Color slateLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color fieldDark = Color(0xFF111E2E);
  static const Color borderDark = Color(0xFF203545);
  static const Color socialDark = Color(0xFF152535);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentTeal, seedColor, accentViolet],
    stops: [0.0, 0.52, 1.0],
  );

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: seedColor,
        secondary: accentTeal,
        tertiary: accentViolet,
        surface: bgLight,
        onSurface: ink,
      ),
      scaffoldBackgroundColor: bgLight,
    );
    return _withText(base, ink, slate);
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        primary: accentTeal,
        secondary: seedColor,
        tertiary: accentViolet,
        surface: ink,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: ink,
    );
    return _withText(base, Colors.white, slateLight);
  }

  static ThemeData _withText(ThemeData base, Color onSurface, Color muted) {
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );
    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: base.scaffoldBackgroundColor,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      dividerColor: muted.withValues(alpha: 0.35),
    );
  }
}
