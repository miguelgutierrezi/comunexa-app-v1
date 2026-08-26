import 'package:comunexa/core/router/app_routes.dart';
import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/domain/user_access_context.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:comunexa/features/auth/presentation/post_login_navigation.dart';
import 'package:comunexa/features/auth/presentation/widgets/auth_hero_panel.dart';
import 'package:comunexa/features/home/presentation/home_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Selector multirrol:
/// - mobile: Figma `#99:5` light / `#99:67` dark
/// - tablet portrait: Figma `#100:475` light / `#100:547` dark (≥700, alto > ancho)
/// - tablet landscape: Figma `#100:331` light / `#100:402` dark (≥900, ancho ≥ alto)
/// - desktop: Figma `#99:185` light / `#99:256` dark (≥1280)
enum _ContextSelectDensity { mobile, tabletPortrait, tabletLandscape, desktop }

extension on _ContextSelectDensity {
  bool get isSplit =>
      this == _ContextSelectDensity.tabletLandscape ||
      this == _ContextSelectDensity.desktop;

  bool get isTabletPortrait => this == _ContextSelectDensity.tabletPortrait;
}

_ContextSelectDensity _densityFor(BoxConstraints constraints) {
  final width = constraints.maxWidth;
  final height = constraints.maxHeight;
  if (width >= LoginScreen.desktopBreakpoint) {
    return _ContextSelectDensity.desktop;
  }
  if (width >= LoginScreen.tabletLandscapeBreakpoint && width >= height) {
    return _ContextSelectDensity.tabletLandscape;
  }
  if (width >= LoginScreen.tabletPortraitBreakpoint && height > width) {
    return _ContextSelectDensity.tabletPortrait;
  }
  return _ContextSelectDensity.mobile;
}

class ContextSelectScreen extends ConsumerStatefulWidget {
  const ContextSelectScreen({
    super.key,
    this.userName,
    this.contexts,
  });

  /// Overrides para tests; en producción se leen de [sessionProvider].
  final String? userName;
  final List<UserAccessContext>? contexts;

  @override
  ConsumerState<ContextSelectScreen> createState() =>
      _ContextSelectScreenState();
}

class _ContextSelectScreenState extends ConsumerState<ContextSelectScreen> {
  late String _highlightedId;

  String get _userName =>
      widget.userName ??
      ref.read(sessionProvider).valueOrNull?.displayName ??
      '';

  List<UserAccessContext> get _contexts =>
      widget.contexts ??
      ref.read(sessionProvider).valueOrNull?.availableContexts ??
      const [];

  @override
  void initState() {
    super.initState();
    _syncHighlightedId();
  }

  @override
  void didUpdateWidget(covariant ContextSelectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncHighlightedId();
  }

  void _syncHighlightedId() {
    final contexts = _contexts;
    if (contexts.isEmpty) {
      _highlightedId = '';
      return;
    }
    _highlightedId = contexts
        .firstWhere(
          (c) => c.isLastUsed,
          orElse: () => contexts.first,
        )
        .id;
  }

  void _onSelect(UserAccessContext ctx) {
    setState(() => _highlightedId = ctx.id);
    if (widget.contexts != null) {
      // Override de tests sin sesión: Navigator o go_router.
      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.home);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const HomeShellScreen()),
        );
      }
      return;
    }
    navigateAfterContextSelected(context, ref, contextId: ctx.id);
  }

  void _onLogout() {
    if (widget.contexts != null) {
      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.login);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const LoginScreen(),
          ),
          (_) => false,
        );
      }
      return;
    }
    navigateAfterLogout(context, ref);
  }

  double _cardGapFor(_ContextSelectDensity density) {
    if (density.isTabletPortrait) return 16;
    if (density.isSplit) return 14;
    return 12;
  }

  Widget _buildContextList(_ContextSelectDensity density) {
    final cardGap = _cardGapFor(density);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _contexts.length; i++) ...[
          _ContextCard(
            access: _contexts[i],
            selected: _contexts[i].id == _highlightedId,
            density: density,
            onTap: () => _onSelect(_contexts[i]),
          ),
          if (i < _contexts.length - 1) SizedBox(height: cardGap),
        ],
      ],
    );
  }

  Widget _buildSplitLayout({
    required _ContextSelectDensity density,
    required bool isDark,
  }) {
    final isTablet = density == _ContextSelectDensity.tabletLandscape;
    final heroFlex = isTablet ? 44 : 55;
    final formFlex = isTablet ? 56 : 45;
    final heroDensity = isTablet
        ? AuthHeroDensity.tabletLandscape
        : AuthHeroDensity.desktop;
    final formPadding = isTablet
        ? const EdgeInsets.fromLTRB(64, 64, 64, 48)
        : const EdgeInsets.symmetric(horizontal: 80, vertical: 64);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: heroFlex,
          child: AuthHeroPanel(
            version: LoginScreen.appVersion,
            density: heroDensity,
          ),
        ),
        Expanded(
          flex: formFlex,
          child: ColoredBox(
            color: isDark ? AppTheme.ink : Colors.white,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, panelConstraints) {
                  return SingleChildScrollView(
                    padding: formPadding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (panelConstraints.maxHeight -
                                formPadding.vertical)
                            .clamp(0, double.infinity),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ContextSelectHeader(
                            userName: _userName,
                            density: density,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: _buildContextList(density),
                          ),
                          _LogoutLink(
                            onTap: _onLogout,
                            density: density,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletPortraitLayout({required bool isDark}) {
    const density = _ContextSelectDensity.tabletPortrait;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 64, 40, 80),
        child: Column(
          children: [
            _ContextSelectHeader(
              userName: _userName,
              density: density,
            ),
            const SizedBox(height: 56),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: _buildContextList(density),
            ),
            const SizedBox(height: 32),
            _LogoutLink(onTap: _onLogout, density: density),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.ink : AppTheme.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final density = _densityFor(constraints);

          if (density.isSplit) {
            return _buildSplitLayout(density: density, isDark: isDark);
          }

          if (density.isTabletPortrait) {
            return _buildTabletPortraitLayout(isDark: isDark);
          }

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ContextSelectHeader(
                  userName: _userName,
                  density: density,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    children: [_buildContextList(density)],
                  ),
                ),
                _LogoutLink(onTap: _onLogout, density: density),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContextSelectHeader extends StatelessWidget {
  const _ContextSelectHeader({
    required this.userName,
    required this.density,
  });

  final String userName;
  final _ContextSelectDensity density;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = userName.split(' ').first;

    if (density.isSplit) {
      final headerGap = density == _ContextSelectDensity.tabletLandscape
          ? 8.0
          : 12.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, $firstName',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.ink,
              fontWeight: FontWeight.w800,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: headerGap),
          Text(
            'Selecciona a dónde quieres acceder',
            style: TextStyle(
              color: isDark ? AppTheme.slateLight : AppTheme.slate,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    if (density.isTabletPortrait) {
      return Column(
        children: [
          SvgPicture.asset(
            BrandAssets.symbolLarge,
            width: 64,
            height: 64,
          ),
          const SizedBox(height: 28),
          Text(
            'Hola, $firstName',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.ink,
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona a dónde quieres acceder',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppTheme.slateLight : AppTheme.slate,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      child: Column(
        children: [
          SvgPicture.asset(
            BrandAssets.symbolLarge,
            width: 52,
            height: 52,
          ),
          const SizedBox(height: 24),
          Text(
            'Hola, $firstName',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.ink,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Selecciona a dónde quieres acceder',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppTheme.slateLight : AppTheme.slate,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.access,
    required this.selected,
    required this.density,
    required this.onTap,
  });

  final UserAccessContext access;
  final bool selected;
  final _ContextSelectDensity density;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSplit = density.isSplit;
    final isTabletPortrait = density.isTabletPortrait;
    final selectedBorder =
        (isDark || isSplit) ? AppTheme.accentTeal : AppTheme.seedColor;
    final border = selected
        ? selectedBorder
        : (isDark ? AppTheme.borderDark : AppTheme.borderLight);
    final borderWidth = selected
        ? (isSplit || isTabletPortrait ? 2.0 : 1.5)
        : (isTabletPortrait ? 1.5 : 1.0);
    final borderRadius = isTabletPortrait ? 16.0 : 12.0;

    final List<BoxShadow>? cardShadow;
    if (isTabletPortrait) {
      cardShadow = [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: isDark
                ? (selected ? 0.19 : 0.06)
                : (selected ? 0.03 : 0.02),
          ),
          blurRadius: selected ? 24 : 12,
          offset: Offset(0, selected ? 12 : 4),
        ),
      ];
    } else {
      final selectedShadowAlpha = isSplit && isDark
          ? 0.2
          : isSplit
              ? 0.13
              : isDark
                  ? 0.13
                  : 0.03;
      cardShadow = selected
          ? [
              BoxShadow(
                color: isSplit
                    ? AppTheme.accentTeal.withValues(
                        alpha: selectedShadowAlpha,
                      )
                    : Colors.black.withValues(alpha: selectedShadowAlpha),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ]
          : null;
    }

    final cardPadding = isTabletPortrait ? 20.0 : 16.0;
    final iconOuter = isTabletPortrait ? 48.0 : 40.0;
    final iconInner = isTabletPortrait ? 24.0 : 20.0;
    final iconRadius = isTabletPortrait ? 24.0 : 20.0;
    final rowGap = isTabletPortrait ? 16.0 : 14.0;
    final titleSize = isTabletPortrait ? 17.0 : 15.0;
    final roleSize = isTabletPortrait ? 14.0 : 13.0;
    final trailingSize = isTabletPortrait ? 28.0 : 24.0;
    final checkSize = isTabletPortrait ? 22.0 : 18.0;
    final chevronSize = isTabletPortrait ? 20.0 : 16.0;

    return Material(
      color: isDark ? AppTheme.cardDark : Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: border, width: borderWidth),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: cardShadow,
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                Container(
                  width: iconOuter,
                  height: iconOuter,
                  decoration: BoxDecoration(
                    color: access.iconBackground,
                    borderRadius: BorderRadius.circular(iconRadius),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    access.iconAsset,
                    width: iconInner,
                    height: iconInner,
                  ),
                ),
                SizedBox(width: rowGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        access.propertyName,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: titleSize,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        access.roleLabel,
                        style: TextStyle(
                          color: isDark ? AppTheme.slateLight : AppTheme.slate,
                          fontWeight: FontWeight.w400,
                          fontSize: roleSize,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: trailingSize,
                  height: trailingSize,
                  child: Center(
                    child: selected
                        ? SvgPicture.asset(
                            BrandAssets.iconCircleCheck,
                            width: checkSize,
                            height: checkSize,
                          )
                        : SvgPicture.asset(
                            BrandAssets.iconChevronRight,
                            width: chevronSize,
                            height: chevronSize,
                            colorFilter: ColorFilter.mode(
                              isDark ? AppTheme.slateLight : AppTheme.slate,
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutLink extends StatelessWidget {
  const _LogoutLink({
    required this.onTap,
    required this.density,
  });

  final VoidCallback onTap;
  final _ContextSelectDensity density;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.slateLight : AppTheme.slate;

    if (density.isTabletPortrait) {
      return Material(
        color: isDark ? AppTheme.cardDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  BrandAssets.iconLogOut,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(muted, BlendMode.srcIn),
                ),
                const SizedBox(width: 10),
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: density.isSplit
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(24, 48, 24, 32),
      child: Center(
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: muted,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                BrandAssets.iconLogOut,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(muted, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
