import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Breakpoints y densidad responsive del login (y pantallas auth afines).
enum LoginDensity {
  mobile,
  tabletPortrait,
  tabletLandscape,
  desktop,
}

abstract final class LoginBreakpoints {
  static const double tabletPortrait = 700;
  static const double tabletLandscape = 900;
  static const double desktop = 1280;
  static const String appVersion = '1.0.0';

  static LoginDensity densityFor(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    if (width >= desktop) {
      return LoginDensity.desktop;
    }
    if (width >= tabletLandscape && width >= height) {
      return LoginDensity.tabletLandscape;
    }
    if (width >= tabletPortrait && height > width) {
      return LoginDensity.tabletPortrait;
    }
    return LoginDensity.mobile;
  }

  /// Apple Sign-In en UI: iOS y macOS (también web sobre esos hosts).
  static bool platformOffersAppleSignIn() {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}
