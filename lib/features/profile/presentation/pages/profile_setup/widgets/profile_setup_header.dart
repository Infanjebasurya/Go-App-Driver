import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

class ProfileSetupHeader extends StatelessWidget {
  const ProfileSetupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          'Complete Your Profile',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Welcome to the inner circle. Let\'s personalize\nyour journey to premium Earnings.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.45,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
