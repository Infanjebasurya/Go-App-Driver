import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/pages/emergency/emergency_support_article_screen.dart';

class EmergencyAccidentScreen extends StatelessWidget {
  const EmergencyAccidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmergencySupportArticleScreen(
      title: 'I had an accident',
      showDefaultGetHelpLine: false,
      content: [
        Text.rich(
          TextSpan(
            style: EmergencyArticleText.body,
            children: [
              TextSpan(
                text:
                    'Your safety is our priority. We\'re sorry to hear about the accident and hope you are safe.\n\n',
              ),
              TextSpan(text: 'For immediate assistance, please contact '),
              TextSpan(
                text: 'Support Chat',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' or '),
              TextSpan(
                text: 'Customer Care',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' by tapping '),
              TextSpan(
                text: 'Get Help',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' below.'),
            ],
          ),
        ),
      ],
    );
  }
}
