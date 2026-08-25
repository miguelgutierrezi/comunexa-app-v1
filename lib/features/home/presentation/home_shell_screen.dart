import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/home/presentation/desktop_dashboard.dart';
import 'package:comunexa/features/home/presentation/home_bottom_nav.dart';
import 'package:comunexa/features/home/presentation/noticias_feed.dart';
import 'package:comunexa/features/home/presentation/tablet_portrait_home.dart';
import 'package:comunexa/features/home/presentation/widgets/header_property_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shell post-login:
/// - mobile: header + bottom nav (showcase `#35:5`)
/// - tablet portrait ≥700 y alto>ancho: feed + eventos (`#74:5`)
/// - tablet landscape ≥900: sidebar compacto (`#35:487` / `#35:606`)
/// - desktop ≥1280: sidebar dashboard (`#35:233` / `#35:353`)
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  static const double tabletPortraitBreakpoint = 700;
  static const double tabletLandscapeBreakpoint = 900;
  static const double desktopBreakpoint = 1280;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  HomeTab _tab = HomeTab.noticias;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.ink : AppTheme.bgLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final isDesktop = width >= HomeShellScreen.desktopBreakpoint;
          final isTabletLand =
              width >= HomeShellScreen.tabletLandscapeBreakpoint &&
                  width >= height;
          final isTabletPort =
              width >= HomeShellScreen.tabletPortraitBreakpoint &&
                  height > width;

          if (isDesktop || isTabletLand) {
            return DesktopDashboard(
              currentTab: _tab,
              onTabChanged: (tab) => setState(() => _tab = tab),
              layout: isDesktop
                  ? DashboardLayout.desktop
                  : DashboardLayout.tabletLandscape,
            );
          }

          if (isTabletPort) {
            return TabletPortraitHome(
              currentTab: _tab,
              onTabChanged: (tab) => setState(() => _tab = tab),
            );
          }

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _HomeHeader(),
                Expanded(child: _buildMobileBody()),
                HomeBottomNav(
                  current: _tab,
                  onChanged: (tab) => setState(() => _tab = tab),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileBody() {
    return switch (_tab) {
      HomeTab.noticias => const NoticiasFeed(),
      HomeTab.zonas => const HomePlaceholderTab(title: 'Zonas'),
      HomeTab.feed => const HomePlaceholderTab(title: 'Feed'),
      HomeTab.mensajes => const HomePlaceholderTab(title: 'Mensajes'),
      HomeTab.config => const HomePlaceholderTab(title: 'Config'),
    };
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.headerDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.fieldDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: HeaderPropertySwitcher(
              density: HeaderPropertySwitcherDensity.mobile,
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones — próximamente')),
              );
            },
            child: SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  BrandAssets.iconBell,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : AppTheme.ink,
                    BlendMode.srcIn,
                  ),
                ),
                Positioned(
                  right: -4,
                  top: -6,
                  child: Container(
                    width: 14,
                    height: 14,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppTheme.dangerRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.brandGradient,
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'C',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
