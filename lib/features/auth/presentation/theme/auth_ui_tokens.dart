import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared visual tokens for auth presentation only.
abstract final class AuthUiColors {
  static const brandGreen = AppColors.emerald;
  static const textDark = AppColors.hexFF111217;
  static const textDarkAlt = AppColors.hexFF16181D;
  static const textMuted = AppColors.hexFF6E6E6E;
  static const danger = AppColors.hexFFE02828;
  static const dotInactive = AppColors.hexFFD5D5D5;
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

  static const button = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
}




