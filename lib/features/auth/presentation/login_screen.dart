import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Login responsive:
/// - móvil: `login-light-screen` / `login-dark-screen`
/// - tablet landscape: `tablet-login-light` (≥900)
/// - desktop: `desktop-login-light` / `desktop-login-dark` (≥1280)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1280;
  static const String appVersion = '1.0.0';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginDensity { mobile, tablet, desktop }

_LoginDensity _densityForWidth(double width) {
  if (width >= LoginScreen.desktopBreakpoint) return _LoginDensity.desktop;
  if (width >= LoginScreen.tabletBreakpoint) return _LoginDensity.tablet;
  return _LoginDensity.mobile;
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auth con Supabase se conectará en el siguiente paso.'),
      ),
    );
  }

  void _soon(String label) {
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
      backgroundColor: isDark ? AppTheme.ink : const Color(0xFFF1F5F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final density = _densityForWidth(constraints.maxWidth);
          if (density != _LoginDensity.mobile) {
            // Figma tablet 530:664 · desktop 792:648
            final heroFlex = density == _LoginDensity.tablet ? 44 : 55;
            final formFlex = density == _LoginDensity.tablet ? 56 : 45;
            final formPadding = density == _LoginDensity.tablet
                ? const EdgeInsets.symmetric(horizontal: 72, vertical: 48)
                : const EdgeInsets.all(80);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: heroFlex,
                  child: _HeroPanel(
                    version: LoginScreen.appVersion,
                    density: density,
                  ),
                ),
                Expanded(
                  flex: formFlex,
                  child: ColoredBox(
                    // Figma form-panel-light #FFFFFF / form-panel-dark #0D1B2A
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
                                maxWidth: density == _LoginDensity.tablet
                                    ? 520
                                    : 488,
                              ),
                              child: _LoginForm(
                                colors: colors,
                                density: density,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                submitting: _submitting,
                                onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                onSubmit: _onSubmit,
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

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  child: _LoginForm(
                    colors: colors,
                    density: _LoginDensity.mobile,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    submitting: _submitting,
                    onToggleObscure: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    onSubmit: _onSubmit,
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

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.version,
    required this.density,
  });

  final String version;
  final _LoginDensity density;

  @override
  Widget build(BuildContext context) {
    final isTablet = density == _LoginDensity.tablet;
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.colors,
    required this.density,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.submitting,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onSoon,
  });

  final _LoginColors colors;
  final _LoginDensity density;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool submitting;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final void Function(String) onSoon;

  bool get _isSplit => density != _LoginDensity.mobile;
  bool get _isTablet => density == _LoginDensity.tablet;

  @override
  Widget build(BuildContext context) {
    final titleSize = switch (density) {
      _LoginDensity.desktop => 32.0,
      _LoginDensity.tablet => 28.0,
      _LoginDensity.mobile => 22.0,
    };
    final subtitleSize = _isTablet ? 14.0 : 15.0;
    final fieldGap = _isTablet ? 20.0 : (_isSplit ? 24.0 : 16.0);
    final labelSize = _isTablet ? 12.0 : 13.0;
    final forgotSize = _isTablet ? 12.0 : 13.0;
    final footerSize = _isTablet ? 13.0 : 14.0;
    final submitHeight = _isTablet ? 48.0 : 52.0;
    final submitRadius = _isTablet ? 12.0 : 14.0;
    final socialHeight = _isTablet ? 44.0 : 48.0;
    final submitLabelSize = _isTablet ? 14.0 : 15.0;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isSplit) ...[
          _BrandHeader(
            markAsset: colors.markAsset,
            ink: colors.ink,
            muted: colors.muted,
            highlightExa: colors.highlightExa,
          ),
          const SizedBox(height: 32),
        ],
        Text(
          'Bienvenido de nuevo',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: titleSize,
            letterSpacing: -0.5,
            color: colors.ink,
          ),
        ),
        if (_isSplit) ...[
          SizedBox(height: _isTablet ? 8 : 12),
          Text(
            'Gestiona tu residencia de la forma más rápida y sencilla.',
            style: TextStyle(
              fontSize: subtitleSize,
              color: colors.muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );

    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          border: colors.fieldBorder,
          hintColor: colors.muted,
          iconAsset: BrandAssets.iconMail,
          iconColor: colors.muted,
          focusBorder: colors.focusBorder,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: fieldGap),
        if (_isSplit)
          Row(
            children: [
              _FieldLabel(
                text: 'Contraseña',
                color: colors.ink,
                fontSize: labelSize,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => onSoon('Recuperar contraseña'),
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
          border: colors.fieldBorder,
          hintColor: colors.muted,
          iconAsset: BrandAssets.iconLock,
          iconColor: colors.muted,
          focusBorder: colors.focusBorder,
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
        if (!_isSplit) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onSoon('Recuperar contraseña'),
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
        SizedBox(height: _isTablet ? 20 : 24),
        _OrDivider(muted: colors.muted, line: colors.fieldBorder),
        SizedBox(height: _isTablet ? 12 : 16),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Google',
                fill: colors.socialFill,
                border: colors.fieldBorder,
                labelColor: colors.ink,
                height: socialHeight,
                labelSize: _isTablet ? 13 : 14,
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
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: 'Apple',
                fill: colors.socialFill,
                border: colors.fieldBorder,
                labelColor: colors.ink,
                height: socialHeight,
                labelSize: _isTablet ? 13 : 14,
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
        ),
      ],
    );

    final footer = Center(
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
            borderSide: BorderSide(color: border),
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
