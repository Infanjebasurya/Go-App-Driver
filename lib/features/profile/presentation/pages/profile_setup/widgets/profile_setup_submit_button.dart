import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:goapp/core/widgets/keyboard_aware_bottom.dart';
import 'package:goapp/core/widgets/shadow_button.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_state.dart';

class ProfileSetupSubmitButton extends StatelessWidget {
  const ProfileSetupSubmitButton({
    super.key,
    required this.profileState,
    required this.isFormValid,
    required this.onSubmit,
    required this.termsTap,
  });

  final ProfileState profileState;
  final bool isFormValid;
  final VoidCallback onSubmit;
  final TapGestureRecognizer termsTap;

  @override
  Widget build(BuildContext context) {
    final failure = profileState is ProfileFailure ? profileState as ProfileFailure : null;
    return KeyboardAwareBottom(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (profileState is ProfileLoading)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ShadowButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                onPressed: profileState is ProfileLoading
                    ? null
                    : () {
                        if (!isFormValid) {
                          onSubmit();
                          return;
                        }
                        onSubmit();
                      },
                child: const Text(
                  'Save & Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (failure != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                failure.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.helperText,
                ),
                children: [
                  const TextSpan(
                    text: 'By tapping Save & Continue, you agree to our ',
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: termsTap,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
