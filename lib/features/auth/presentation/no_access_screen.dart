import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/presentation/login_screen.dart';
import 'package:comunexa/features/auth/presentation/post_login_navigation.dart';
import 'package:comunexa/features/auth/presentation/widgets/auth_hero_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Sin membresías activas tras autenticación (Fase C).
///
/// Layout alineado con login / selector de contexto:
/// mobile · tablet portrait · tablet landscape · desktop.
class NoAccessScreen extends ConsumerWidget {
  const NoAccessScreen({
    super.key,
    this.userName,
  });

  /// Override para tests; en producción se lee de [sessionProvider].
  final String? userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = userName ??
        ref.watch(sessionDisplayNameProvider) ??
        ref.watch(sessionProvider).valueOrNull?.email ??
        '';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.ink : AppTheme.bgLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final density = _densityFor(constraints);

          if (density.isSplit) {
            return _SplitNoAccessBody(
              density: density,
              isDark: isDark,
              displayName: displayName,
              onLogout: () => navigateAfterLogout(context, ref),
            );
          }

          if (density.isTabletPortrait) {
            return _TabletPortraitNoAccessBody(
              isDark: isDark,
              displayName: displayName,
              onLogout: () => navigateAfterLogout(context, ref),
            );
          }

          return _MobileNoAccessBody(
            isDark: isDark,
            displayName: displayName,
            onLogout: () => navigateAfterLogout(context, ref),
          );
        },
      ),
    );
  }
}

enum _NoAccessDensity { mobile, tabletPortrait, tabletLandscape, desktop }

extension on _NoAccessDensity {
  bool get isSplit =>
      this == _NoAccessDensity.tabletLandscape ||
      this == _NoAccessDensity.desktop;

  bool get isTabletPortrait => this == _NoAccessDensity.tabletPortrait;
}

_NoAccessDensity _densityFor(BoxConstraints constraints) {
  final width = constraints.maxWidth;
  final height = constraints.maxHeight;
  if (width >= LoginScreen.desktopBreakpoint) {
    return _NoAccessDensity.desktop;
  }
  if (width >= LoginScreen.tabletLandscapeBreakpoint && width >= height) {
    return _NoAccessDensity.tabletLandscape;
  }
  if (width >= LoginScreen.tabletPortraitBreakpoint && height > width) {
    return _NoAccessDensity.tabletPortrait;
  }
  return _NoAccessDensity.mobile;
}

class _NoAccessMessage extends StatelessWidget {
  const _NoAccessMessage({
    required this.displayName,
    required this.density,
  });

  final String displayName;
  final _NoAccessDensity density;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName =
        displayName.trim().isEmpty ? 'Usuario' : displayName.split(' ').first;
    final titleColor = isDark ? Colors.white : AppTheme.ink;
    final bodyColor = isDark ? AppTheme.slateLight : AppTheme.slate;
    final isSplit = density.isSplit;
    final isTabletPortrait = density.isTabletPortrait;

    final titleSize = isSplit
        ? 32.0
        : isTabletPortrait
            ? 32.0
            : 24.0;
    final bodySize = isSplit
        ? 16.0
        : isTabletPortrait
            ? 18.0
            : 15.0;
    final iconSize = isTabletPortrait ? 64.0 : 52.0;
    final cardIconSize = isTabletPortrait ? 28.0 : 24.0;

    return Column(
      crossAxisAlignment:
          isSplit ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (!isSplit) ...[
          SvgPicture.asset(
            BrandAssets.symbolLarge,
            width: iconSize,
            height: iconSize,
          ),
          SizedBox(height: isTabletPortrait ? 28 : 24),
        ],
        Text(
          'Hola, $firstName',
          textAlign: isSplit ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: titleSize,
            letterSpacing: isSplit ? -0.5 : 0,
          ),
        ),
        SizedBox(height: isSplit ? 12 : 8),
        Text(
          'Aún no tienes acceso',
          textAlign: isSplit ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
            fontSize: isSplit ? 22 : 20,
          ),
        ),
        SizedBox(height: isSplit ? 16 : 12),
        Text(
          'Tu cuenta está activa, pero no tienes membresías en ninguna '
          'propiedad. Si crees que es un error, contacta al administrador '
          'de tu edificio o conjunto.',
          textAlign: isSplit ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            color: bodyColor,
            fontSize: bodySize,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: isTabletPortrait ? 32 : 24),
        _NoAccessInfoCard(
          isDark: isDark,
          iconSize: cardIconSize,
          isWide: isSplit || isTabletPortrait,
        ),
      ],
    );
  }
}

class _NoAccessInfoCard extends StatelessWidget {
  const _NoAccessInfoCard({
    required this.isDark,
    required this.iconSize,
    required this.isWide,
  });

  final bool isDark;
  final double iconSize;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final fill = isDark ? AppTheme.cardDark : Colors.white;
    final titleColor = isDark ? Colors.white : AppTheme.ink;
    final bodyColor = isDark ? AppTheme.slateLight : AppTheme.slate;

    return Container(
      width: isWide ? double.infinity : null,
      padding: EdgeInsets.all(isWide ? 20 : 16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconSize + 12,
            height: iconSize + 12,
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              BrandAssets.iconAlertCircle,
              width: iconSize,
              height: iconSize,
              colorFilter: const ColorFilter.mode(
                AppTheme.accentTeal,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué puedes hacer?',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: isWide ? 16 : 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pide una invitación al administrador o espera a que '
                  'activen tu membresía. Luego vuelve a iniciar sesión.',
                  style: TextStyle(
                    color: bodyColor,
                    fontSize: isWide ? 15 : 14,
                    height: 1.4,
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

class _MobileNoAccessBody extends StatelessWidget {
  const _MobileNoAccessBody({
    required this.isDark,
    required this.displayName,
    required this.onLogout,
  });

  final bool isDark;
  final String displayName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: _NoAccessMessage(
                displayName: displayName,
                density: _NoAccessDensity.mobile,
              ),
            ),
          ),
          _NoAccessLogoutLink(onTap: onLogout, density: _NoAccessDensity.mobile),
        ],
      ),
    );
  }
}

class _TabletPortraitNoAccessBody extends StatelessWidget {
  const _TabletPortraitNoAccessBody({
    required this.isDark,
    required this.displayName,
    required this.onLogout,
  });

  final bool isDark;
  final String displayName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 64, 40, 80),
        child: Column(
          children: [
            _NoAccessMessage(
              displayName: displayName,
              density: _NoAccessDensity.tabletPortrait,
            ),
            const SizedBox(height: 40),
            _NoAccessLogoutLink(
              onTap: onLogout,
              density: _NoAccessDensity.tabletPortrait,
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitNoAccessBody extends StatelessWidget {
  const _SplitNoAccessBody({
    required this.density,
    required this.isDark,
    required this.displayName,
    required this.onLogout,
  });

  final _NoAccessDensity density;
  final bool isDark;
  final String displayName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final isTablet = density == _NoAccessDensity.tabletLandscape;
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
                          _NoAccessMessage(
                            displayName: displayName,
                            density: density,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: _NoAccessLogoutLink(
                              onTap: onLogout,
                              density: density,
                            ),
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
}

class _NoAccessLogoutLink extends StatelessWidget {
  const _NoAccessLogoutLink({
    required this.onTap,
    required this.density,
  });

  final VoidCallback onTap;
  final _NoAccessDensity density;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.slateLight : AppTheme.slate;

    if (density.isTabletPortrait) {
      return Center(
        child: Material(
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
        ),
      );
    }

    return Padding(
      padding: density.isSplit
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
