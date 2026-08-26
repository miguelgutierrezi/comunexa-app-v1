import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({
    super.key,
    required this.markAsset,
    required this.ink,
    required this.muted,
    required this.highlightExa,
  });

  final String markAsset;
  final Color ink;
  final Color muted;
  final bool highlightExa;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(markAsset, width: 64, height: 64),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: 4,
              color: ink,
            ),
            children: [
              const TextSpan(text: 'COMUN'),
              TextSpan(
                text: 'EXA',
                style: TextStyle(
                  color: highlightExa ? AppTheme.seedColor : ink,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          BrandAssets.tagline,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, height: 1.4, color: muted),
        ),
      ],
    );
  }
}
