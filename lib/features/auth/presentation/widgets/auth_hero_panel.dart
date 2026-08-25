import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Panel hero gradiente compartido (login y selector de contexto).
enum AuthHeroDensity { tabletLandscape, desktop }

class AuthHeroPanel extends StatelessWidget {
  const AuthHeroPanel({
    super.key,
    required this.version,
    required this.density,
  });

  final String version;
  final AuthHeroDensity density;

  @override
  Widget build(BuildContext context) {
    final isTablet = density == AuthHeroDensity.tabletLandscape;
    final padding = isTablet ? 48.0 : 64.0;
    final symbolSize = isTablet ? 130.0 : 160.0;
    final brandSize = isTablet ? 36.0 : 48.0;
    final taglineSize = isTablet ? 15.0 : 18.0;
    final centerGap = isTablet ? 24.0 : 32.0;
    final footerSize = isTablet ? 12.0 : 13.0;
    final watermarkSize = isTablet ? 11.0 : 12.0;
    final watermarkOpacity = isTablet ? 0.5 : 0.4;
    final versionLabel = isTablet ? 'v$version' : 'Versión $version';

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SECURE ENTERPRISE LOGIN',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: watermarkOpacity),
                  fontWeight: FontWeight.w700,
                  fontSize: watermarkSize,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  SvgPicture.asset(
                    BrandAssets.symbolLarge,
                    width: symbolSize,
                    height: symbolSize,
                  ),
                  SizedBox(height: centerGap),
                  Text(
                    'COMUNEXA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: brandSize,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: isTablet ? 8 : 12),
                  Text(
                    BrandAssets.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: taglineSize,
                      height: isTablet ? 1.4 : null,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2026 Comunexa Inc.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: footerSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    versionLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: footerSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
