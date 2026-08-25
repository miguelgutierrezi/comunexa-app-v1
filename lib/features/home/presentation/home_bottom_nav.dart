import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum HomeTab { noticias, zonas, feed, mensajes, config }

/// Densidad / acentos del bottom nav (móvil showcase vs tablet portrait `#74:5`).
enum HomeNavDensity {
  mobile,
  tabletPortrait,
}

extension HomeTabX on HomeTab {
  String get label => switch (this) {
        HomeTab.noticias => 'Noticias',
        HomeTab.zonas => 'Zonas',
        HomeTab.feed => 'Feed',
        HomeTab.mensajes => 'Mensajes',
        HomeTab.config => 'Config',
      };

  String get desktopLabel => switch (this) {
        HomeTab.config => 'Configuración',
        _ => label,
      };

  String get iconAsset => switch (this) {
        HomeTab.noticias => BrandAssets.iconNewspaper,
        HomeTab.zonas => BrandAssets.iconGrid,
        HomeTab.feed => BrandAssets.iconActivity,
        HomeTab.mensajes => BrandAssets.iconMessage,
        HomeTab.config => BrandAssets.iconSettings,
      };
}

/// Bottom nav mobile / tablet portrait del showcase Comunexa.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.current,
    required this.onChanged,
    this.density = HomeNavDensity.mobile,
  });

  final HomeTab current;
  final ValueChanged<HomeTab> onChanged;
  final HomeNavDensity density;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = density == HomeNavDensity.tabletPortrait;

    return Material(
      color: isDark ? AppTheme.headerDark : Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
          ),
          padding: isTablet
              ? const EdgeInsets.fromLTRB(32, 12, 32, 8)
              : const EdgeInsets.fromLTRB(12, 10, 12, 4),
          constraints: isTablet
              ? const BoxConstraints(minHeight: 72)
              : null,
          child: Row(
            children: [
              for (final tab in HomeTab.values)
                Expanded(
                  child: _NavItem(
                    tab: tab,
                    selected: tab == current,
                    showDot: tab == HomeTab.mensajes,
                    density: density,
                    onTap: () => onChanged(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.showDot,
    required this.density,
    required this.onTap,
  });

  final HomeTab tab;
  final bool selected;
  final bool showDot;
  final HomeNavDensity density;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = density == HomeNavDensity.tabletPortrait;
    // Light tablet: seed blue. Dark tablet (`#74:117`): accent sky.
    // Móvil showcase: teal.
    final active = isTablet
        ? (isDark ? AppTheme.accentSky : AppTheme.seedColor)
        : AppTheme.accentTeal;
    final inactive = isDark
        ? AppTheme.slateLight
        : (isTablet ? AppTheme.slate : AppTheme.slateLight);
    final color = selected ? active : inactive;
    final iconSize = isTablet ? 24.0 : 20.0;
    final labelSize = isTablet ? 11.0 : 10.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      tab.iconAsset,
                      width: iconSize,
                      height: iconSize,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
                  ),
                  if (showDot)
                    Positioned(
                      right: isTablet ? -2 : 0,
                      top: isTablet ? -2 : 0,
                      child: Container(
                        width: isTablet ? 8 : 6,
                        height: isTablet ? 8 : 6,
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRed,
                          shape: BoxShape.circle,
                          border: isTablet
                              ? Border.all(
                                  color: isDark
                                      ? AppTheme.headerDark
                                      : Colors.white,
                                  width: 1.5,
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 6 : 4),
            Text(
              tab.label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: labelSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
