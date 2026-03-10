import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';

/// Shared visual tokens for auth presentation only.
abstract final class OnboardingUiColors {
  static const brandGreen = AppColors.emerald;
  static const textDark = AppColors.black;
  static const textDarkAlt = AppColors.headingDark;
  static const textMuted = AppColors.textMuted;
  static const danger = AppColors.validationRed;
  static const dotInactive = AppColors.inactive;
}

/// Shared text styles to keep Saira usage consistent across auth screens.
abstract final class OnboardingUiTextStyles {
  static const heading = TextStyle(
    fontFamily: 'Saira',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: OnboardingUiColors.textDarkAlt,
    letterSpacing: -0.2,
  );

  static const body = TextStyle(
    fontFamily: 'Saira',
    fontSize: 13.5,
    height: 1.45,
    color: OnboardingUiColors.textMuted,
  );

  static const button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontFamily: 'Saira',
  );
}



