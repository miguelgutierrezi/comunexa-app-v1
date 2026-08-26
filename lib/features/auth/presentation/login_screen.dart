import 'package:comunexa/core/session/session_provider.dart';
import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/domain/auth_failure.dart';
import 'package:comunexa/features/auth/presentation/login_alerts.dart';
import 'package:comunexa/features/auth/presentation/post_login_navigation.dart';
import 'package:comunexa/features/auth/presentation/widgets/auth_hero_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Login responsive:
/// - móvil: `login-light-screen` / `login-dark-screen`
/// - tablet portrait: `tablet-portrait-login-light` / `tablet-portrait-login-dark` (≥700, alto > ancho)
/// - tablet landscape: `tablet-login-light` / `tablet-login-dark` (≥900)
/// - desktop: `desktop-login-light` / `desktop-login-dark` (≥1280)
///
/// Sign in with Apple solo en plataformas Apple (iOS / macOS), incluido web
/// cuando el host es Apple. Override vía [showAppleSignIn] para tests.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.showAppleSignIn});

  /// `null` → detectar plataforma. Tests pueden forzar `true`/`false`.
  final bool? showAppleSignIn;

  static const double tabletPortraitBreakpoint = 700;
  static const double tabletLandscapeBreakpoint = 900;
  static const double desktopBreakpoint = 1280;
  static const String appVersion = '1.0.0';

  /// Apple Sign-In en UI: iOS y macOS (también web sobre esos hosts).
  static bool platformOffersAppleSignIn() {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  bool get offersAppleSignIn =>
      showAppleSignIn ?? platformOffersAppleSignIn();

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginDensity { mobile, tabletPortrait, tabletLandscape, desktop }

_LoginDensity _densityFor(BoxConstraints constraints) {
  final width = constraints.maxWidth;
  final height = constraints.maxHeight;
  if (width >= LoginScreen.desktopBreakpoint) {
    return _LoginDensity.desktop;
  }
  if (width >= LoginScreen.tabletLandscapeBreakpoint && width >= height) {
    return _LoginDensity.tabletLandscape;
  }
  if (width >= LoginScreen.tabletPortraitBreakpoint && height > width) {
    return _LoginDensity.tabletPortrait;
  }
  return _LoginDensity.mobile;
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  LoginAlertKind? _formAlert;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Auth email/password. Prefijos `demo:` solo previsualizan alerts Figma.
  Future<void> _onSubmit() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.startsWith('demo:locked')) {
      setState(() => _formAlert = null);
      await showAccountLockedDialog(context);
      return;
    }
    if (email.startsWith('demo:offline')) {
      setState(() => _formAlert = null);
      showNetworkErrorToast(context, onRetry: _onSubmit);
      return;
    }
    if (email.startsWith('demo:invalid')) {
      setState(() => _formAlert = LoginAlertKind.invalidCredentials);
      return;
    }
    if (email.startsWith('demo:empty')) {
      setState(() => _formAlert = LoginAlertKind.emptyFields);
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      setState(() => _formAlert = LoginAlertKind.emptyFields);
      return;
    }

    setState(() {
      _formAlert = null;
      _submitting = true;
    });

    try {
      await navigateAfterLogin(
        context,
        ref,
        email: email,
        password: password,
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      await _handleAuthFailure(e);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _formAlert = LoginAlertKind.invalidCredentials;
      });
    }
  }

  Future<void> _handleAuthFailure(AuthFailure e) async {
    switch (e.kind) {
      case AuthFailureKind.invalidCredentials:
        setState(() => _formAlert = LoginAlertKind.invalidCredentials);
      case AuthFailureKind.network:
        showNetworkErrorToast(context, onRetry: _onSubmit);
      case AuthFailureKind.notConfigured:
      case AuthFailureKind.rateLimited:
      case AuthFailureKind.unknown:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
    }
  }

  Future<void> _onForgotPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || email.startsWith('demo:')) {
      setState(() => _formAlert = LoginAlertKind.emptyFields);
      return;
    }

    try {
      await ref.read(sessionProvider.notifier).sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Si el correo existe, recibirás un enlace para restablecer tu contraseña.',
          ),
        ),
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      await _handleAuthFailure(e);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar el correo de recuperación.'),
        ),
      );
    }
  }

  void _onSocial(String provider) {
    showComingSoonDialog(context);
  }

  void _soon(String label) {
    if (label.contains('Google') || label.contains('Apple')) {
      _onSocial(label);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _LoginColors.of(isDark);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.ink : AppTheme.bgLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final density = _densityFor(constraints);

          if (density == _LoginDensity.tabletLandscape ||
              density == _LoginDensity.desktop) {
            // Figma tablet landscape 530:664 · desktop 792:648
            final isTablet = density == _LoginDensity.tabletLandscape;
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
                    version: LoginScreen.appVersion,
                    density: density == _LoginDensity.desktop
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
                                minHeight: (panelConstraints.maxHeight -
                                        verticalPad)
                                    .clamp(0, double.infinity),
                                maxWidth: isTablet ? 520 : 488,
                              ),
                              child: _LoginForm(
                                colors: colors,
                                density: density,
                                showAppleSignIn: widget.offersAppleSignIn,
                                formAlert: _formAlert,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                submitting: _submitting,
                                onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                onSubmit: _onSubmit,
                                onForgotPassword: _onForgotPassword,
                                onSoon: _soon,
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

          if (density == _LoginDensity.tabletPortrait) {
            // Figma tablet-portrait-login: hero 450 + form fill
            final heroHeight =
                (constraints.maxHeight * 0.377).clamp(320.0, 450.0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: heroHeight,
                  child: const _PortraitHeroPanel(),
                ),
                Expanded(
                  child: ColoredBox(
                    color: isDark ? AppTheme.ink : Colors.white,
                    child: SafeArea(
                      top: false,
                      child: LayoutBuilder(
                        builder: (context, panelConstraints) {
                          const formPadding = EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 48,
                          );
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
                                child: _LoginForm(
                                  colors: colors,
                                  density: density,
                                  showAppleSignIn: widget.offersAppleSignIn,
                                  formAlert: _formAlert,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  submitting: _submitting,
                                  onToggleObscure: () => setState(
                                    () =>
                                        _obscurePassword = !_obscurePassword,
                                  ),
                                  onSubmit: _onSubmit,
                                  onForgotPassword: _onForgotPassword,
                                  onSoon: _soon,
                                ),
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

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  child: _LoginForm(
                    colors: colors,
                    density: _LoginDensity.mobile,
                    showAppleSignIn: widget.offersAppleSignIn,
                    formAlert: _formAlert,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    submitting: _submitting,
                    onToggleObscure: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    onSubmit: _onSubmit,
                    onForgotPassword: _onForgotPassword,
                    onSoon: _soon,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginColors {
  const _LoginColors({
    required this.isDark,
    required this.ink,
    required this.muted,
    required this.fieldFill,
    required this.fieldBorder,
    required this.socialFill,
    required this.accentLink,
    required this.focusBorder,
    required this.markAsset,
    required this.highlightExa,
  });

  final bool isDark;
  final Color ink;
  final Color muted;
  final Color fieldFill;
  final Color fieldBorder;
  final Color socialFill;
  final Color accentLink;
  final Color focusBorder;
  final String markAsset;
  final bool highlightExa;

  factory _LoginColors.of(bool isDark) {
    return _LoginColors(
      isDark: isDark,
      ink: isDark ? Colors.white : AppTheme.ink,
      muted: isDark ? AppTheme.slateLight : AppTheme.slate,
      // Figma dark inputs #111E2E / border #203545 / social #152535
      fieldFill: isDark ? AppTheme.fieldDark : Colors.white,
      fieldBorder: isDark ? AppTheme.borderDark : AppTheme.borderLight,
      socialFill: isDark ? AppTheme.socialDark : Colors.white,
      accentLink: isDark ? AppTheme.accentTeal : AppTheme.seedColor,
      focusBorder: isDark ? AppTheme.accentTeal : AppTheme.seedColor,
      markAsset: isDark ? BrandAssets.markNegative : BrandAssets.markColor,
      highlightExa: !isDark,
    );
  }
}

/// Hero superior de tablet portrait (sin watermark ni footer).
class _PortraitHeroPanel extends StatelessWidget {
  const _PortraitHeroPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 48),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  BrandAssets.symbolLarge,
                  width: 84,
                  height: 84,
                ),
                const SizedBox(height: 16),
                const Text(
                  'COMUNEXA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  BrandAssets.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.colors,
    required this.density,
    required this.showAppleSignIn,
    required this.formAlert,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.submitting,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onSoon,
  });

  final _LoginColors colors;
  final _LoginDensity density;
  final bool showAppleSignIn;
  final LoginAlertKind? formAlert;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool submitting;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final void Function(String) onSoon;

  bool get _isSplit =>
      density == _LoginDensity.tabletLandscape ||
      density == _LoginDensity.desktop;
  bool get _isTabletLandscape => density == _LoginDensity.tabletLandscape;
  bool get _isTabletPortrait => density == _LoginDensity.tabletPortrait;
  bool get _showSubtitle => _isSplit || _isTabletPortrait;
  bool get _inlineForgot => _isSplit || _isTabletPortrait;

  @override
  Widget build(BuildContext context) {
    final titleSize = switch (density) {
      _LoginDensity.desktop => 32.0,
      _LoginDensity.tabletLandscape ||
      _LoginDensity.tabletPortrait =>
        28.0,
      _LoginDensity.mobile => 22.0,
    };
    final subtitleSize = _isTabletLandscape ? 14.0 : 15.0;
    final fieldGap = (_isTabletLandscape || _isTabletPortrait)
        ? 20.0
        : (_isSplit ? 24.0 : 16.0);
    final labelSize = _isTabletLandscape ? 12.0 : 13.0;
    final forgotSize = _isTabletLandscape ? 12.0 : 13.0;
    final footerSize = _isTabletLandscape ? 13.0 : 14.0;
    final submitHeight = _isTabletLandscape ? 48.0 : 52.0;
    final submitRadius = (_isTabletLandscape || _isTabletPortrait) ? 12.0 : 14.0;
    final socialHeight = _isTabletLandscape ? 44.0 : 48.0;
    final submitLabelSize = _isTabletLandscape ? 14.0 : 15.0;
    final socialLabelSize = _isTabletLandscape ? 13.0 : 14.0;
    final actionsGap = _isTabletLandscape ? 20.0 : 24.0;
    final dividerGap = _isTabletLandscape ? 12.0 : 16.0;
    final showInlineBanner = formAlert == LoginAlertKind.invalidCredentials ||
        formAlert == LoginAlertKind.emptyFields;
    final fieldsHaveError = showInlineBanner;
    final showRequiredHints = formAlert == LoginAlertKind.emptyFields;
    final errorBorder = AppTheme.dangerRed;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (density == _LoginDensity.mobile) ...[
          _BrandHeader(
            markAsset: colors.markAsset,
            ink: colors.ink,
            muted: colors.muted,
            highlightExa: colors.highlightExa,
          ),
          const SizedBox(height: 32),
        ],
        Text(
          'Bienvenido',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: titleSize,
            letterSpacing: -0.5,
            color: colors.ink,
          ),
        ),
        if (_showSubtitle) ...[
          SizedBox(
            height: (_isTabletLandscape || _isTabletPortrait) ? 8 : 12,
          ),
          Text(
            'Gestiona tu residencia de la forma más rápida y sencilla.',
            style: TextStyle(
              fontSize: subtitleSize,
              height: _isTabletPortrait ? 1.4 : null,
              color: colors.muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        if (showInlineBanner) ...[
          const SizedBox(height: 20),
          LoginAlertBanner(kind: formAlert!),
        ],
      ],
    );

    Widget fieldLabelRow(String text) {
      return Row(
        children: [
          Expanded(
            child: _FieldLabel(
              text: text,
              color: colors.ink,
              fontSize: labelSize,
            ),
          ),
          if (showRequiredHints)
            SvgPicture.asset(
              BrandAssets.iconAlertCircle,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppTheme.dangerRed,
                BlendMode.srcIn,
              ),
            ),
        ],
      );
    }

    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showRequiredHints)
          fieldLabelRow('Correo Electrónico')
        else
          _FieldLabel(
            text: 'Correo Electrónico',
            color: colors.ink,
            fontSize: labelSize,
          ),
        const SizedBox(height: 8),
        _AuthField(
          controller: emailController,
          hint: 'nombre@ejemplo.com',
          fill: colors.fieldFill,
          border: fieldsHaveError ? errorBorder : colors.fieldBorder,
          hintColor: colors.muted,
          iconAsset: BrandAssets.iconMail,
          iconColor: colors.muted,
          focusBorder: fieldsHaveError ? errorBorder : colors.focusBorder,
          errorBorderWidth: fieldsHaveError ? 1.5 : 1,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        if (showRequiredHints) ...[
          const SizedBox(height: 6),
          const Text(
            'Este campo es obligatorio.',
            style: TextStyle(
              color: AppTheme.dangerRed,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
        SizedBox(height: fieldGap),
        if (_inlineForgot)
          Row(
            children: [
              if (showRequiredHints)
                Expanded(child: fieldLabelRow('Contraseña'))
              else
                _FieldLabel(
                  text: 'Contraseña',
                  color: colors.ink,
                  fontSize: labelSize,
                ),
              if (!showRequiredHints) const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onForgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.accentLink,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: forgotSize,
                        color: colors.accentLink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else if (showRequiredHints)
          fieldLabelRow('Contraseña')
        else
          _FieldLabel(
            text: 'Contraseña',
            color: colors.ink,
            fontSize: labelSize,
          ),
        const SizedBox(height: 8),
        _AuthField(
          controller: passwordController,
          hint: '••••••••',
          fill: colors.fieldFill,
          border: fieldsHaveError ? errorBorder : colors.fieldBorder,
          hintColor: colors.muted,
          iconAsset: BrandAssets.iconLock,
          iconColor: colors.muted,
          focusBorder: fieldsHaveError ? errorBorder : colors.focusBorder,
          errorBorderWidth: fieldsHaveError ? 1.5 : 1,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          suffix: IconButton(
            onPressed: onToggleObscure,
            icon: SvgPicture.asset(
              obscurePassword
                  ? BrandAssets.iconEye
                  : BrandAssets.iconEyeSlash,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(colors.muted, BlendMode.srcIn),
            ),
          ),
        ),
        if (showRequiredHints) ...[
          const SizedBox(height: 6),
          const Text(
            'Este campo es obligatorio.',
            style: TextStyle(
              color: AppTheme.dangerRed,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
        if (!_inlineForgot) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: colors.accentLink,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: colors.accentLink,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GradientButton(
          label: 'Iniciar Sesión',
          loading: submitting,
          height: submitHeight,
          radius: submitRadius,
          fontSize: submitLabelSize,
          onPressed: submitting ? null : onSubmit,
        ),
        SizedBox(height: actionsGap),
        _OrDivider(muted: colors.muted, line: colors.fieldBorder),
        SizedBox(height: dividerGap),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Google',
                fill: colors.socialFill,
                border: colors.fieldBorder,
                labelColor: colors.ink,
                height: socialHeight,
                labelSize: socialLabelSize,
                icon: SvgPicture.asset(
                  BrandAssets.iconGoogle,
                  width: 18,
                  height: 18,
                  colorFilter: colors.isDark
                      ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                      : null,
                ),
                onPressed: () => onSoon('Google Sign-In'),
              ),
            ),
            if (showAppleSignIn) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _SocialButton(
                  label: 'Apple',
                  fill: colors.socialFill,
                  border: colors.fieldBorder,
                  labelColor: colors.ink,
                  height: socialHeight,
                  labelSize: socialLabelSize,
                  icon: SvgPicture.asset(
                    BrandAssets.iconApple,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      colors.isDark ? Colors.white : colors.ink,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => onSoon('Apple Sign-In'),
                ),
              ),
            ],
          ],
        ),
      ],
    );

    final footer = Center(
      child: Padding(
        padding: EdgeInsets.only(top: _isTabletPortrait ? 8 : 0),
        child: Text.rich(
          TextSpan(
            style: TextStyle(color: colors.muted, fontSize: footerSize),
            children: [
              const TextSpan(text: '¿No tienes cuenta? '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () => onSoon('Registro'),
                  child: Text(
                    'Regístrate',
                    style: TextStyle(
                      color: colors.accentLink,
                      fontWeight: FontWeight.w600,
                      fontSize: footerSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (_isSplit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          header,
          fields,
          actions,
          footer,
        ],
      );
    }

    if (_isTabletPortrait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          header,
          const SizedBox(height: 32),
          fields,
          const SizedBox(height: 32),
          actions,
          const SizedBox(height: 24),
          footer,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 20),
        fields,
        const SizedBox(height: 20),
        actions,
        const SizedBox(height: 24),
        footer,
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
    required this.color,
    this.fontSize = 13,
  });

  final String text;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.fill,
    required this.border,
    required this.hintColor,
    required this.iconAsset,
    required this.iconColor,
    this.focusBorder = AppTheme.seedColor,
    this.errorBorderWidth = 1,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final Color fill;
  final Color border;
  final Color hintColor;
  final String iconAsset;
  final Color iconColor;
  final Color focusBorder;
  final double errorBorderWidth;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          filled: true,
          fillColor: fill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: SvgPicture.asset(
              iconAsset,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 46),
          suffixIcon: suffix,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border, width: errorBorderWidth),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: focusBorder, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    required this.loading,
    this.height = 52,
    this.radius = 14,
    this.fontSize = 15,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.muted, required this.line});

  final Color muted;
  final Color line;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: line, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'o continúa con',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: muted,
            ),
          ),
        ),
        Expanded(child: Divider(color: line, height: 1)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.fill,
    required this.border,
    required this.labelColor,
    required this.icon,
    required this.onPressed,
    this.height = 48,
    this.labelSize = 14,
  });

  final String label;
  final Color fill;
  final Color border;
  final Color labelColor;
  final Widget icon;
  final VoidCallback onPressed;
  final double height;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: fill,
          foregroundColor: labelColor,
          side: BorderSide(color: border),
          minimumSize: Size(0, height),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: labelSize,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
