import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/data/mock_user_contexts.dart';
import 'package:comunexa/features/home/data/mock_noticias.dart';
import 'package:comunexa/features/home/presentation/home_bottom_nav.dart';
import 'package:comunexa/features/home/presentation/noticias_feed.dart';
import 'package:comunexa/features/home/presentation/widgets/property_context_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Densidad del dashboard split
/// (desktop `#35:233`/`#35:353` · tablet land `#35:487`/`#35:606`).
enum DashboardLayout {
  desktop,
  tabletLandscape;

  double get sidebarWidth => this == desktop ? 260 : 220;
  double get eventsPanelWidth => this == desktop ? 340 : 280;
  double get brandSize => this == desktop ? 20 : 18;
  double get titleSize => this == desktop ? 22 : 20;
  double get topBarHPad => this == desktop ? 40 : 32;
  double get contentPad => this == desktop ? 40 : 32;
  double get contentGap => this == desktop ? 32 : 24;
  double get searchWidth => this == desktop ? 260 : 220;
  double get searchHintSize => this == desktop ? 13 : 12;
  double get headerAvatar => this == desktop ? 36 : 32;
  double get headerActionsGap => this == desktop ? 24 : 20;
  double get eventsPad => this == desktop ? 24 : 20;
  double get eventsTitleSize => this == desktop ? 16 : 15;
  double get eventDaySize => this == desktop ? 16 : 14;
  double get eventBoxWidth => this == desktop ? 48 : 44;
  double get userAvatar => this == desktop ? 40 : 36;
  double get userNameSize => this == desktop ? 13 : 12;
  double get userRoleSize => this == desktop ? 11 : 10;
  bool get denseCards => this == tabletLandscape;

  /// Ancho sidebar en pantallas “añadir noticia” (Figma tablet `#114:8` = 240).
  double get addNewsSidebarWidth => this == desktop ? 260 : 240;
  double get addNewsCardWidth => this == desktop ? 680 : 640;
  double get addNewsCardPadding => this == desktop ? 32 : 28;
  double get addNewsFormGap => this == desktop ? 24 : 20;
  double get addNewsLabelSize => this == desktop ? 13 : 12;
  double get addNewsDropzonePad => this == desktop ? 20 : 16;
  double? get addNewsDescriptionMin => this == desktop ? 160 : null;
  EdgeInsets get addNewsBodyPadding => this == desktop
      ? const EdgeInsets.all(40)
      : const EdgeInsets.symmetric(vertical: 24);

  /// Fondo de la pill del property switcher (dark tablet usa `#111E2E`).
  Color propertyPillFill(bool isDark) {
    if (!isDark) return AppTheme.bgLight;
    return this == tabletLandscape ? AppTheme.fieldDark : AppTheme.cardDark;
  }
}

/// Dashboard split light/dark (desktop + tablet landscape).
class DesktopDashboard extends StatelessWidget {
  const DesktopDashboard({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.layout = DashboardLayout.desktop,
    this.onAddNews,
  });

  final HomeTab currentTab;
  final ValueChanged<HomeTab> onTabChanged;
  final DashboardLayout layout;
  final VoidCallback? onAddNews;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? AppTheme.ink : const Color(0xFFF1F5F9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: layout.sidebarWidth,
            child: HomeSplitSidebar(
              current: currentTab,
              onChanged: onTabChanged,
              layout: layout,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DesktopTopBar(
                  layout: layout,
                  showAddNews: currentTab == HomeTab.noticias,
                  onAddNews: onAddNews,
                ),
                Expanded(
                  child: _DesktopBody(tab: currentTab, layout: layout),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sidebar compartido del dashboard split y pantallas hijas (p. ej. añadir noticia).
class HomeSplitSidebar extends ConsumerWidget {
  const HomeSplitSidebar({
    super.key,
    required this.current,
    required this.onChanged,
    this.layout = DashboardLayout.desktop,
  });

  final HomeTab current;
  final ValueChanged<HomeTab> onChanged;
  final DashboardLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppTheme.fieldDark : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  BrandAssets.symbolNav,
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: layout.brandSize,
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _SidebarPropertySwitcher(layout: layout),
            const SizedBox(height: 32),
            for (final tab in HomeTab.values) ...[
              _SidebarItem(
                tab: tab,
                selected: tab == current,
                badge: tab == HomeTab.mensajes ? '4' : null,
                onTap: () => onChanged(tab),
              ),
              const SizedBox(height: 6),
            ],
            const Spacer(),
            _SidebarUserCard(layout: layout),
          ],
        ),
      ),
    );
  }
}

/// Selector de propiedad/rol en sidebar split
/// (desktop `#35:233`/`#35:353` · tablet land `#35:487`/`#35:606`).
class _SidebarPropertySwitcher extends ConsumerWidget {
  const _SidebarPropertySwitcher({required this.layout});

  final DashboardLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active =
        ref.watch(activeContextProvider) ?? mockSingleContext;
    final contexts = ref.watch(availableContextsProvider);
    final canSwitch = contexts.length > 1;

    final pillFill = layout.propertyPillFill(isDark);
    final pillBorder = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final titleColor = isDark ? Colors.white : AppTheme.ink;
    final subtitleColor = isDark ? AppTheme.slateLight : AppTheme.slate;
    final chevronColor = isDark ? AppTheme.slateLight : AppTheme.slate;

    Widget pillContent = Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active.iconBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            active.iconAsset,
            width: 16,
            height: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            active.propertyName,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        if (canSwitch) ...[
          const SizedBox(width: 8),
          Transform.rotate(
            angle: 1.5708,
            child: SvgPicture.asset(
              BrandAssets.iconChevronRight,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(chevronColor, BlendMode.srcIn),
            ),
          ),
        ],
      ],
    );

    final pill = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: pillFill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: pillBorder),
      ),
      alignment: Alignment.centerLeft,
      child: pillContent,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canSwitch)
            MenuAnchor(
              style: MenuStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    ),
                  ),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  isDark ? AppTheme.cardDark : Colors.white,
                ),
                elevation: WidgetStatePropertyAll(8),
              ),
              builder: (context, controller, child) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: pill,
                  ),
                );
              },
              menuChildren: [
                for (final ctx in contexts)
                  PropertyContextMenuItem(
                    access: ctx,
                    selected: ctx.id == active.id,
                    isDark: isDark,
                    onTap: () async {
                      if (ctx.id == active.id) return;
                      await ref
                          .read(sessionProvider.notifier)
                          .selectContext(ctx.id);
                    },
                  ),
              ],
            )
          else
            pill,
          const SizedBox(height: 4),
          Text(
            active.roleLabel,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subtitleColor,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.tab,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final HomeTab tab;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Dark Figma `#35:353` / `#35:606`: slate panel + sky active.
    final fg = selected
        ? (isDark ? AppTheme.accentSky : AppTheme.seedColor)
        : (isDark ? AppTheme.slateLight : AppTheme.slate);
    final bg = selected
        ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE))
        : Colors.transparent;
    final border = selected
        ? (isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE))
        : null;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: border != null ? BorderSide(color: border) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SvgPicture.asset(
                tab.iconAsset,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tab.desktopLabel,
                  style: TextStyle(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarUserCard extends ConsumerWidget {
  const _SidebarUserCard({required this.layout});

  final DashboardLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName =
        ref.watch(sessionDisplayNameProvider) ?? 'Carlos Méndez';
    final active = ref.watch(activeContextProvider) ?? mockSingleContext;
    final roleLabel = active.sidebarRoleLabel;
    final initials = _initialsFor(displayName);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: layout.userAvatar,
            height: layout.userAvatar,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.brandGradient,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: layout.userNameSize,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  roleLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppTheme.slateLight : AppTheme.slate,
                    fontSize: layout.userRoleSize,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            BrandAssets.iconChevronRight,
            width: layout == DashboardLayout.tabletLandscape ? 14 : 16,
            height: layout == DashboardLayout.tabletLandscape ? 14 : 16,
            colorFilter: ColorFilter.mode(
              isDark ? AppTheme.slateLight : AppTheme.slate,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({
    required this.layout,
    this.showAddNews = false,
    this.onAddNews,
  });

  final DashboardLayout layout;
  final bool showAddNews;
  final VoidCallback? onAddNews;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final muted = isDark ? AppTheme.slateLight : AppTheme.slate;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: layout.topBarHPad,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Novedades de la Comunidad',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.ink,
                fontWeight: FontWeight.w700,
                fontSize: layout.titleSize,
              ),
            ),
          ),
          if (showAddNews && onAddNews != null) ...[
            SizedBox(width: layout.headerActionsGap),
            FilledButton.icon(
              onPressed: onAddNews,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.ink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Añadir noticia',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
          SizedBox(width: layout.headerActionsGap),
          SizedBox(
            width: layout.searchWidth,
            child: TextField(
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.ink,
                fontSize: layout.searchHintSize,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar novedades...',
                hintStyle: TextStyle(
                  color: muted,
                  fontSize: layout.searchHintSize,
                ),
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
                    color: isDark ? AppTheme.accentTeal : AppTheme.seedColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: layout.headerActionsGap),
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
          SizedBox(width: layout.headerActionsGap),
          Container(
            width: layout.headerAvatar,
            height: layout.headerAvatar,
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
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopBody extends StatelessWidget {
  const _DesktopBody({required this.tab, required this.layout});

  final HomeTab tab;
  final DashboardLayout layout;

  @override
  Widget build(BuildContext context) {
    if (tab != HomeTab.noticias) {
      return HomePlaceholderTab(title: tab.desktopLabel);
    }

    return Padding(
      padding: EdgeInsets.all(layout.contentPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _NewsGrid(
                items: mockNoticias,
                dense: layout.denseCards,
              ),
            ),
          ),
          SizedBox(width: layout.contentGap),
          SizedBox(
            width: layout.eventsPanelWidth,
            child: _EventsPanel(layout: layout),
          ),
        ],
      ),
    );
  }
}

class _NewsGrid extends StatelessWidget {
  const _NewsGrid({required this.items, required this.dense});

  final List<NoticiaItem> items;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = dense ? 16.0 : 20.0;
        final runGap = dense ? 20.0 : 24.0;
        final cardWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: runGap,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: NewsCard(item: item, dense: dense),
              ),
          ],
        );
      },
    );
  }
}

class _EventsPanel extends StatelessWidget {
  const _EventsPanel({required this.layout});

  final DashboardLayout layout;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Container(
      padding: EdgeInsets.all(layout.eventsPad),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                    fontSize: layout.eventsTitleSize,
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
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final event in mockEventos) ...[
            _EventRow(event: event, layout: layout),
            const SizedBox(height: 4),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reservar zona — próximamente'),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Text(
                      'Reservar Zona Común',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.layout});

  final ComunidadEvento event;
  final DashboardLayout layout;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final eventTitleSize = layout == DashboardLayout.tabletLandscape ? 13.0 : 14.0;
    final eventDetailSize = layout == DashboardLayout.tabletLandscape ? 11.0 : 12.0;
    final monthSize = layout == DashboardLayout.tabletLandscape ? 10.0 : 11.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: layout.eventBoxWidth,
            padding: EdgeInsets.symmetric(
              vertical: layout == DashboardLayout.tabletLandscape ? 6 : 8,
            ),
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
                    fontSize: monthSize,
                  ),
                ),
                Text(
                  event.day,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: layout.eventDaySize,
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
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: eventTitleSize,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.detail,
                  style: TextStyle(
                    color: isDark ? AppTheme.slateLight : AppTheme.slate,
                    fontSize: eventDetailSize,
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

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.length >= 2
        ? parts.first.substring(0, 2).toUpperCase()
        : parts.first.toUpperCase();
  }
  return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
}
