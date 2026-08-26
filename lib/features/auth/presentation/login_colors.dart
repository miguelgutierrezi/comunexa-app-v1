import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:flutter/material.dart';

/// Tokens de color del formulario de login según tema claro/oscuro.
class LoginColors {
  const LoginColors({
    required this.isDark,
    required this.ink,
    required this.muted,
    required this.fieldFill,
    required this.fieldBorder,
    required this.socialFill,
    required this.accentLink,
    required this.focusBorder,
    required this.markAsset,
    required this.highlightExa,
  });

  final bool isDark;
  final Color ink;
  final Color muted;
  final Color fieldFill;
  final Color fieldBorder;
  final Color socialFill;
  final Color accentLink;
  final Color focusBorder;
  final String markAsset;
  final bool highlightExa;

  factory LoginColors.of(bool isDark) {
    return LoginColors(
      isDark: isDark,
      ink: isDark ? Colors.white : AppTheme.ink,
      muted: isDark ? AppTheme.slateLight : AppTheme.slate,
      fieldFill: isDark ? AppTheme.fieldDark : Colors.white,
      fieldBorder: isDark ? AppTheme.borderDark : AppTheme.borderLight,
      socialFill: isDark ? AppTheme.socialDark : Colors.white,
      accentLink: isDark ? AppTheme.accentTeal : AppTheme.seedColor,
      focusBorder: isDark ? AppTheme.accentTeal : AppTheme.seedColor,
      markAsset: isDark ? BrandAssets.markNegative : BrandAssets.markColor,
      highlightExa: !isDark,
    );
  }
}
