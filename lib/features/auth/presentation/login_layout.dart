import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/auth/presentation/login_breakpoints.dart';
import 'package:comunexa/features/auth/presentation/login_form.dart';
import 'package:comunexa/features/auth/presentation/widgets/auth_hero_panel.dart';
import 'package:comunexa/features/auth/presentation/widgets/login_portrait_hero_panel.dart';
import 'package:flutter/material.dart';

/// Shell responsive del login: elige layout según [LoginDensity].
class LoginResponsiveLayout extends StatelessWidget {
  const LoginResponsiveLayout({
    super.key,
    required this.density,
    required this.isDark,
    required this.form,
  });

  final LoginDensity density;
  final bool isDark;
  final LoginForm form;

  @override
  Widget build(BuildContext context) {
    return switch (density) {
      LoginDensity.tabletLandscape || LoginDensity.desktop =>
        _SplitLoginLayout(
          isDark: isDark,
          isTablet: density == LoginDensity.tabletLandscape,
          isDesktop: density == LoginDensity.desktop,
          form: form,
        ),
      LoginDensity.tabletPortrait => _TabletPortraitLoginLayout(
          isDark: isDark,
          form: form,
        ),
      LoginDensity.mobile => _MobileLoginLayout(form: form),
    };
  }
}

class _SplitLoginLayout extends StatelessWidget {
  const _SplitLoginLayout({
    required this.isDark,
    required this.isTablet,
    required this.isDesktop,
    required this.form,
  });

  final bool isDark;
  final bool isTablet;
  final bool isDesktop;
  final LoginForm form;

  @override
  Widget build(BuildContext context) {
    final heroFlex = isTablet ? 44 : 55;
    final formFlex = isTablet ? 56 : 45;
    final formPadding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 72, vertical: 48)
        : const EdgeInsets.all(80);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: heroFlex,
          child: AuthHeroPanel(
            version: LoginBreakpoints.appVersion,
            density: isDesktop
                ? AuthHeroDensity.desktop
                : AuthHeroDensity.tabletLandscape,
          ),
        ),
        Expanded(
          flex: formFlex,
          child: ColoredBox(
            color: isDark ? AppTheme.ink : Colors.white,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, panelConstraints) {
                  final verticalPad = formPadding.vertical;
                  return SingleChildScrollView(
                    padding: formPadding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (panelConstraints.maxHeight - verticalPad)
                            .clamp(0, double.infinity),
                        maxWidth: isTablet ? 520 : 488,
                      ),
                      child: form,
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

class _TabletPortraitLoginLayout extends StatelessWidget {
  const _TabletPortraitLoginLayout({
    required this.isDark,
    required this.form,
  });

  final bool isDark;
  final LoginForm form;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heroHeight =
            (constraints.maxHeight * 0.377).clamp(320.0, 450.0);
        const formPadding = EdgeInsets.symmetric(horizontal: 80, vertical: 48);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: heroHeight,
              child: const LoginPortraitHeroPanel(),
            ),
            Expanded(
              child: ColoredBox(
                color: isDark ? AppTheme.ink : Colors.white,
                child: SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    builder: (context, panelConstraints) {
                      return SingleChildScrollView(
                        padding: formPadding,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: (panelConstraints.maxHeight -
                                      formPadding.vertical)
                                  .clamp(0, double.infinity),
                              maxWidth: 500,
                            ),
                            child: form,
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
      },
    );
  }
}

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout({required this.form});

  final LoginForm form;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: form,
          ),
        ),
      ),
    );
  }
}
