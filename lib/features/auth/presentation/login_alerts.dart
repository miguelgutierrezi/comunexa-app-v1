import 'package:comunexa/core/theme/app_theme.dart';
import 'package:comunexa/core/theme/brand_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Estados de alerta del login (Figma desktop/tablet alerts).
enum LoginAlertKind {
  /// Banner rojo + bordes de error en campos.
  invalidCredentials,

  /// Banner ámbar + “Este campo es obligatorio”.
  emptyFields,

  /// Modal overlay “Acceso Bloqueado”.
  accountLocked,

  /// Toast superior “Sin conexión”.
  networkError,
}

/// Banner inline encima del formulario.
class LoginAlertBanner extends StatelessWidget {
  const LoginAlertBanner({super.key, required this.kind});

  final LoginAlertKind kind;

  @override
  Widget build(BuildContext context) {
    final isEmpty = kind == LoginAlertKind.emptyFields;
    final bg = isEmpty ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2);
    final border = isEmpty ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2);
    final fg = isEmpty ? AppTheme.warningAmber : AppTheme.dangerRed;
    final icon =
        isEmpty ? BrandAssets.iconAlertTriangle : BrandAssets.iconAlertOctagon;
    final message = isEmpty
        ? 'Por favor, completa todos los campos obligatorios.'
        : 'Correo electrónico o contraseña incorrectos. Inténtalo de nuevo.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal “Acceso Bloqueado” (Figma `desktop-alert-account-locked`).
Future<void> showAccountLockedDialog(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (ctx) {
      return Dialog(
        backgroundColor: isDark ? AppTheme.fieldDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    BrandAssets.iconLockModal,
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.dangerRed,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Acceso Bloqueado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu cuenta ha sido bloqueada temporalmente por múltiples '
                  'intentos fallidos de inicio de sesión para proteger tu '
                  'información.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppTheme.slateLight : AppTheme.slate,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.borderDark : AppTheme.bgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Intenta de nuevo en 14:59',
                    style: TextStyle(
                      color: isDark ? AppTheme.accentTeal : AppTheme.seedColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : AppTheme.ink,
                      foregroundColor: isDark ? AppTheme.ink : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Toast “Sin conexión” (Figma `desktop-alert-network-error`).
void showNetworkErrorToast(
  BuildContext context, {
  VoidCallback? onRetry,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 6),
      content: _NetworkErrorToastCard(
        onRetry: () {
          messenger.hideCurrentSnackBar();
          onRetry?.call();
        },
      ),
    ),
  );
}

class _NetworkErrorToastCard extends StatelessWidget {
  const _NetworkErrorToastCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Material(
          color: isDark ? AppTheme.socialDark : Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1A12)
                        : const Color(0xFFFFFBEB),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    BrandAssets.iconWifiOff,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.warningAmber,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sin conexión a internet',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verifica tu red e inténtalo de nuevo.',
                        style: TextStyle(
                          color: isDark ? AppTheme.slateLight : AppTheme.slate,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: AppTheme.warningAmber,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onRetry,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text(
                        'Reintentar',
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
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

/// Modal / bottom sheet “Disponible Próximamente” (Google / Apple).
Future<void> showComingSoonDialog(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final useSheet = width < LoginAlertBreakpoints.tabletPortrait;

  if (useSheet) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppTheme.ink.withValues(alpha: 0.31),
      builder: (ctx) => const _ComingSoonSheet(),
    );
  }

  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<void>(
    context: context,
    barrierColor: AppTheme.ink.withValues(alpha: 0.31),
    builder: (ctx) {
      return Dialog(
        backgroundColor: isDark ? AppTheme.fieldDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: _ComingSoonContent(
              onUseEmail: () => Navigator.of(ctx).pop(),
              onDismiss: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      );
    },
  );
}

abstract final class LoginAlertBreakpoints {
  static const double tabletPortrait = 700;
}

class _ComingSoonSheet extends StatelessWidget {
  const _ComingSoonSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppTheme.fieldDark : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 28),
              _ComingSoonContent(
                onUseEmail: () => Navigator.of(context).pop(),
                onDismiss: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonContent extends StatelessWidget {
  const _ComingSoonContent({
    required this.onUseEmail,
    required this.onDismiss,
  });

  final VoidCallback onUseEmail;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkColor = isDark ? AppTheme.accentTeal : AppTheme.seedColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            BrandAssets.iconSparkles,
            width: 28,
            height: 28,
            colorFilter: const ColorFilter.mode(
              AppTheme.seedColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Disponible Próximamente',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.ink,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'El inicio de sesión con Google y Apple estará disponible muy '
          'pronto. Por ahora, puedes registrarte con tu correo electrónico.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppTheme.slateLight : AppTheme.slate,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.seedColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onUseEmail,
                borderRadius: BorderRadius.circular(14),
                child: const Center(
                  child: Text(
                    'Usar Correo Electrónico',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onDismiss,
          child: Text(
            'Entendido',
            style: TextStyle(
              color: linkColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
