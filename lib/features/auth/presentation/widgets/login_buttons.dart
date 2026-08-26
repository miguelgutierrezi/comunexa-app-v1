import 'package:comunexa/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoginGradientButton extends StatelessWidget {
  const LoginGradientButton({
    super.key,
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

class LoginOrDivider extends StatelessWidget {
  const LoginOrDivider({
    super.key,
    required this.muted,
    required this.line,
  });

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

class LoginSocialButton extends StatelessWidget {
  const LoginSocialButton({
    super.key,
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
