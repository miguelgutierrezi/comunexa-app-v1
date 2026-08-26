import 'package:comunexa/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginFieldLabel extends StatelessWidget {
  const LoginFieldLabel({
    super.key,
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

class LoginAuthField extends StatelessWidget {
  const LoginAuthField({
    super.key,
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
