import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared visual tokens for auth presentation only.
abstract final class AuthUiColors {
  static const brandGreen = AppColors.emerald;
  static const textDark = Color(0xFF111217);
  static const textDarkAlt = Color(0xFF16181D);
  static const textMuted = Color(0xFF6E6E6E);
  static const danger = Color(0xFFE02828);
  static const dotInactive = Color(0xFFD5D5D5);
}

/// Shared text styles to keep Saira usage consistent across auth screens.
abstract final class AuthUiTextStyles {
  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AuthUiColors.textDarkAlt,
    letterSpacing: -0.2,
  );

  static const body = TextStyle(
    fontSize: 13.5,
    height: 1.45,
    color: AuthUiColors.textMuted,
  );

  static const button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
}
