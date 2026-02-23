import 'package:flutter/material.dart';

import '../theme/onboarding_ui_tokens.dart';

class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.height = 46,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OnboardingUiColors.brandGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: OnboardingUiColors.brandGreen,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: OnboardingUiTextStyles.button,
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}
