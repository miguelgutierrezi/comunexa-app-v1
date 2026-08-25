import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/home/data/mock_noticias.dart';
import 'package:comunexa/features/home/presentation/home_bottom_nav.dart';
import 'package:comunexa/features/home/presentation/noticias_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Home tablet portrait (Figma `#74:5` light / `#74:117` dark).
/// Header con búsqueda + feed en columna + eventos horizontales + bottom nav.
class TabletPortraitHome extends StatelessWidget {
  const TabletPortraitHome({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  final HomeTab currentTab;
  final ValueChanged<HomeTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? AppTheme.ink : const Color(0xFFF1F5F9),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TabletPortraitHeader(),
            Expanded(
              child: currentTab == HomeTab.noticias
                  ? const _TabletPortraitNoticiasBody()
                  : HomePlaceholderTab(title: currentTab.label),
            ),
            HomeBottomNav(
              current: currentTab,
              onChanged: onTabChanged,
              density: HomeNavDensity.tabletPortrait,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletPortraitHeader extends StatelessWidget {
  const _TabletPortraitHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final muted = isDark ? AppTheme.slateLight : AppTheme.slate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        // Dark Figma `#74:117`: header cardDark; search fieldDark.
        color: isDark ? AppTheme.headerDark : Colors.white,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            BrandAssets.symbolNav,
            width: 28,
            height: 28,
          ),
          const SizedBox(width: 12),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 2,
                color: isDark ? Colors.white : AppTheme.ink,
              ),
              children: const [
                TextSpan(text: 'COMUN'),
                TextSpan(
                  text: 'EXA',
                  style: TextStyle(color: AppTheme.seedColor),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 220,
            child: TextField(
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.ink,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar novedades...',
                hintStyle: TextStyle(color: muted, fontSize: 13),
                filled: true,
                fillColor: isDark ? AppTheme.fieldDark : AppTheme.bgLight,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: SvgPicture.asset(
                    BrandAssets.iconSearch,
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(muted, BlendMode.srcIn),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 36),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.accentSky : AppTheme.seedColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
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
                  top: -4,
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
          const SizedBox(width: 20),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.brandGradient,
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: const Text(
              'CM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletPortraitNoticiasBody extends StatelessWidget {
  const _TabletPortraitNoticiasBody();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Text(
          'Novedades de la Comunidad',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.ink,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < mockNoticias.length; i++) ...[
          NewsCard(item: mockNoticias[i], dense: false),
          if (i < mockNoticias.length - 1) const SizedBox(height: 16),
        ],
        const SizedBox(height: 24),
        const _TabletEventsSection(),
      ],
    );
  }
}

class _TabletEventsSection extends StatelessWidget {
  const _TabletEventsSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Próximos Eventos',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor:
                    isDark ? AppTheme.accentSky : AppTheme.seedColor,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < mockEventos.length; i++) ...[
                _TabletEventCard(event: mockEventos[i]),
                if (i < mockEventos.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TabletEventCard extends StatelessWidget {
  const _TabletEventCard({required this.event});

  final ComunidadEvento event;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.fieldDark : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  event.monthLabel,
                  style: TextStyle(
                    color: isDark ? AppTheme.slate : AppTheme.slateLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                Text(
                  event.day,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppTheme.slateLight : AppTheme.slate,
                    fontSize: 11,
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
