import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/presentation/login_alerts.dart';
import 'package:comunexa/features/auth/presentation/login_breakpoints.dart';
import 'package:comunexa/features/auth/presentation/login_colors.dart';
import 'package:comunexa/features/auth/presentation/widgets/login_auth_field.dart';
import 'package:comunexa/features/auth/presentation/widgets/login_brand_header.dart';
import 'package:comunexa/features/auth/presentation/widgets/login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
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

  final LoginColors colors;
  final LoginDensity density;
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
      density == LoginDensity.tabletLandscape ||
      density == LoginDensity.desktop;
  bool get _isTabletLandscape => density == LoginDensity.tabletLandscape;
  bool get _isTabletPortrait => density == LoginDensity.tabletPortrait;
  bool get _showSubtitle => _isSplit || _isTabletPortrait;
  bool get _inlineForgot => _isSplit || _isTabletPortrait;

  @override
  Widget build(BuildContext context) {
    final titleSize = switch (density) {
      LoginDensity.desktop => 32.0,
      LoginDensity.tabletLandscape || LoginDensity.tabletPortrait => 28.0,
      LoginDensity.mobile => 22.0,
    };
    final subtitleSize = _isTabletLandscape ? 14.0 : 15.0;
    final fieldGap = (_isTabletLandscape || _isTabletPortrait)
        ? 20.0
        : (_isSplit ? 24.0 : 16.0);
    final labelSize = _isTabletLandscape ? 12.0 : 13.0;
    final forgotSize = _isTabletLandscape ? 12.0 : 13.0;
    final footerSize = _isTabletLandscape ? 13.0 : 14.0;
    final submitHeight = _isTabletLandscape ? 48.0 : 52.0;
    final submitRadius =
        (_isTabletLandscape || _isTabletPortrait) ? 12.0 : 14.0;
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
        if (density == LoginDensity.mobile) ...[
          LoginBrandHeader(
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
            child: LoginFieldLabel(
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
          LoginFieldLabel(
            text: 'Correo Electrónico',
            color: colors.ink,
            fontSize: labelSize,
          ),
        const SizedBox(height: 8),
        LoginAuthField(
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
                LoginFieldLabel(
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
          LoginFieldLabel(
            text: 'Contraseña',
            color: colors.ink,
            fontSize: labelSize,
          ),
        const SizedBox(height: 8),
        LoginAuthField(
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
              obscurePassword ? BrandAssets.iconEye : BrandAssets.iconEyeSlash,
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
        LoginGradientButton(
          label: 'Iniciar Sesión',
          loading: submitting,
          height: submitHeight,
          radius: submitRadius,
          fontSize: submitLabelSize,
          onPressed: submitting ? null : onSubmit,
        ),
        SizedBox(height: actionsGap),
        LoginOrDivider(muted: colors.muted, line: colors.fieldBorder),
        SizedBox(height: dividerGap),
        Row(
          children: [
            Expanded(
              child: LoginSocialButton(
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
                child: LoginSocialButton(
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
        children: [header, fields, actions, footer],
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
