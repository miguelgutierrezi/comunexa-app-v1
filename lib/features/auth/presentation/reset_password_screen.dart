import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:comunexa/features/auth/domain/auth_failure.dart';
import 'package:comunexa/features/auth/presentation/post_login_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Nueva contraseña tras deep link de recuperación (Supabase `PASSWORD_RECOVERY`).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Completa ambos campos.');
      return;
    }
    if (password.length < 8) {
      setState(
        () => _errorMessage = 'La contraseña debe tener al menos 8 caracteres.',
      );
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _submitting = true;
    });

    try {
      await navigateAfterPasswordReset(
        context,
        ref,
        password: password,
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = 'No se pudo actualizar la contraseña. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.ink : AppTheme.bgLight;
    final titleColor = isDark ? Colors.white : AppTheme.ink;
    final bodyColor = isDark ? AppTheme.slateLight : AppTheme.slate;
    final fill = isDark ? AppTheme.fieldDark : AppTheme.fieldLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final hintColor = isDark ? AppTheme.slateLight : AppTheme.slate;
    final iconColor = isDark ? AppTheme.slateLight : AppTheme.slate;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      BrandAssets.symbolLarge,
                      width: 52,
                      height: 52,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nueva contraseña',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige una contraseña segura para tu cuenta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: bodyColor, fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'CONTRASEÑA',
                    style: TextStyle(
                      color: bodyColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PasswordField(
                    controller: _passwordController,
                    hint: 'Mínimo 8 caracteres',
                    fill: fill,
                    border: border,
                    hintColor: hintColor,
                    iconColor: iconColor,
                    obscureText: _obscurePassword,
                    onToggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CONFIRMAR',
                    style: TextStyle(
                      color: bodyColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PasswordField(
                    controller: _confirmController,
                    hint: 'Repite la contraseña',
                    fill: fill,
                    border: border,
                    hintColor: hintColor,
                    iconColor: iconColor,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onSubmit(),
                    onToggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppTheme.dangerRed,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _onSubmit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar contraseña'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => navigateAfterLogout(context, ref),
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(color: bodyColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.fill,
    required this.border,
    required this.hintColor,
    required this.iconColor,
    required this.obscureText,
    required this.onToggleObscure,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final Color fill;
  final Color border;
  final Color hintColor;
  final Color iconColor;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
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
              BrandAssets.iconLock,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 46),
          suffixIcon: IconButton(
            onPressed: onToggleObscure,
            icon: SvgPicture.asset(
              obscureText ? BrandAssets.iconEye : BrandAssets.iconEyeSlash,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.seedColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
