import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/features/auth/domain/auth_failure.dart';
import 'package:comunexa/features/auth/presentation/login_alerts.dart';
import 'package:comunexa/features/auth/presentation/login_breakpoints.dart';
import 'package:comunexa/features/auth/presentation/login_colors.dart';
import 'package:comunexa/features/auth/presentation/login_form.dart';
import 'package:comunexa/features/auth/presentation/login_form_logic.dart';
import 'package:comunexa/features/auth/presentation/login_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login responsive:
/// - móvil: `login-light-screen` / `login-dark-screen`
/// - tablet portrait: `tablet-portrait-login-light` / `tablet-portrait-login-dark`
/// - tablet landscape: `tablet-login-light` / `tablet-login-dark`
/// - desktop: `desktop-login-light` / `desktop-login-dark`
///
/// Sign in with Apple solo en plataformas Apple (iOS / macOS), incluido web
/// cuando el host es Apple. Override vía [showAppleSignIn] para tests.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.showAppleSignIn});

  /// `null` → detectar plataforma. Tests pueden forzar `true`/`false`.
  final bool? showAppleSignIn;

  /// Reexportados para pantallas auth afines (selector, no-access).
  static const double tabletPortraitBreakpoint =
      LoginBreakpoints.tabletPortrait;
  static const double tabletLandscapeBreakpoint =
      LoginBreakpoints.tabletLandscape;
  static const double desktopBreakpoint = LoginBreakpoints.desktop;
  static const String appVersion = LoginBreakpoints.appVersion;

  static bool platformOffersAppleSignIn() =>
      LoginBreakpoints.platformOffersAppleSignIn();

  bool get offersAppleSignIn =>
      showAppleSignIn ?? platformOffersAppleSignIn();

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
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

  void _setFormAlert(LoginAlertKind? alert) {
    setState(() => _formAlert = alert);
  }

  Future<void> _onSubmit() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    final validation = validateLoginInput(email: email, password: password);
    switch (validation) {
      case LoginValidationShowLocked():
        _setFormAlert(null);
        await showAccountLockedDialog(context);
        return;
      case LoginValidationShowOffline():
        _setFormAlert(null);
        showNetworkErrorToast(context, onRetry: _onSubmit);
        return;
      case LoginValidationShowAlert(:final alert):
        _setFormAlert(alert);
        return;
      case LoginValidationProceed(:final email, :final password):
        setState(() {
          _formAlert = null;
          _submitting = true;
        });
        try {
          await submitLogin(
            context: context,
            ref: ref,
            email: email,
            password: password,
          );
        } on AuthFailure catch (e) {
          if (!mounted) return;
          setState(() => _submitting = false);
          await handleAuthFailure(
            context: context,
            failure: e,
            onFormAlert: _setFormAlert,
            onRetrySubmit: _onSubmit,
          );
        } catch (_) {
          if (!mounted) return;
          setState(() {
            _submitting = false;
            _formAlert = LoginAlertKind.invalidCredentials;
          });
        }
    }
  }

  Future<void> _onForgotPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    await sendForgotPassword(
      context: context,
      ref: ref,
      email: email,
      onFormAlert: _setFormAlert,
      onRetrySubmit: _onSubmit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = LoginColors.of(isDark);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.ink : AppTheme.bgLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final density = LoginBreakpoints.densityFor(constraints);
          return LoginResponsiveLayout(
            density: density,
            isDark: isDark,
            form: LoginForm(
              colors: colors,
              density: density,
              showAppleSignIn: widget.offersAppleSignIn,
              formAlert: _formAlert,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              submitting: _submitting,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onSubmit: _onSubmit,
              onForgotPassword: _onForgotPassword,
              onSoon: (label) => showLoginComingSoon(context, label),
            ),
          );
        },
      ),
    );
  }
}
