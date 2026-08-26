import 'dart:ui';

import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/session/session_state.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/presentation/post_login_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Splash breve → restaura sesión persistida o login.
/// Móvil `#118:5`/`#118:27` · tablet port `#118:117`/`#118:128` · tablet land `#118:95`/`#118:106` ·
/// desktop `#118:73`/`#118:84`.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const double tabletPortraitBreakpoint = 700;
  static const double tabletLandscapeBreakpoint = 900;
  static const double desktopBreakpoint = 1280;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 1200));
    final sessionFuture = ref.read(sessionProvider.future);
    await Future.wait([minDelay, sessionFuture]);

    if (!mounted) return;
    final session = ref.read(sessionProvider).valueOrNull ?? SessionState.empty;
    navigateToAppStart(
      context,
      resolveAppStartDestination(session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final isDesktop = width >= SplashScreen.desktopBreakpoint;
    final isTabletLandscape = !isDesktop &&
        width >= SplashScreen.tabletLandscapeBreakpoint &&
        isLandscape;
    final isTabletPortrait = !isDesktop &&
        !isTabletLandscape &&
        width >= SplashScreen.tabletPortraitBreakpoint &&
        !isLandscape;
    final taglineBase =
        BrandAssets.tagline.replaceAll(RegExp(r'\.$'), '');

    if (isDesktop) {
      return _WideSplash(
        isDark: isDark,
        tagline: taglineBase,
        symbolSize: 140,
        glowSize: 540,
      );
    }
    // Tablet land light `#118:95` · dark `#118:106`.
    if (isTabletLandscape) {
      return _WideSplash(
        isDark: isDark,
        tagline: taglineBase,
        symbolSize: 120,
        glowSize: 500,
      );
    }
    // Tablet port light `#118:117` · dark `#118:128`.
    if (isTabletPortrait) {
      return _WideSplash(
        isDark: isDark,
        tagline: taglineBase,
        symbolSize: 110,
        glowSize: 500,
      );
    }

    return _MobileSplash(
      isDark: isDark,
      tagline: taglineBase.toUpperCase(),
    );
  }
}

/// Wide: desktop · tablet land · tablet port `#118:117`/`#118:128`.
class _WideSplash extends StatelessWidget {
  const _WideSplash({
    required this.isDark,
    required this.tagline,
    required this.symbolSize,
    required this.glowSize,
  });

  final bool isDark;
  final String tagline;
  final double symbolSize;
  final double glowSize;

  static const _ambientGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppTheme.accentTeal,
      AppTheme.seedColor,
      AppTheme.accentViolet,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppTheme.ink : Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Opacity(
              // Light: 8%. Dark desktop `#118:84`: 15%.
              opacity: isDark ? 0.15 : 0.08,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  width: glowSize,
                  height: glowSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _ambientGradient,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  isDark
                      ? BrandAssets.symbolGradientDark
                      : BrandAssets.symbolGradientLight,
                  width: symbolSize,
                  height: symbolSize,
                  semanticsLabel: 'Comunexa',
                ),
                const SizedBox(height: 24),
                Text(
                  'COMUNEXA',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: isDark ? Colors.white : AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tagline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: isDark ? AppTheme.slateLight : AppTheme.slate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Móvil light `#118:5` · dark `#118:27`.
class _MobileSplash extends StatelessWidget {
  const _MobileSplash({
    required this.isDark,
    required this.tagline,
  });

  final bool isDark;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppTheme.ink : AppTheme.bgLight;
    final wordmarkColor = isDark ? Colors.white : AppTheme.ink;
    final symbolAsset =
        isDark ? BrandAssets.symbolGradientDark : BrandAssets.symbolGradientLight;
    final glowSize = isDark ? 220.0 : 180.0;
    final glowBlur = isDark ? 30.0 : 20.0;
    final glowColor =
        isDark ? const Color(0x142563EB) : const Color(0x0D2563EB);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: glowBlur,
                              sigmaY: glowBlur,
                            ),
                            child: Container(
                              width: glowSize,
                              height: glowSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: glowColor,
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            symbolAsset,
                            width: 100,
                            height: 100,
                            semanticsLabel: 'Comunexa',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'COMUNEXA',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        letterSpacing: 6,
                        color: wordmarkColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tagline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: 1.5,
                        color: AppTheme.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
