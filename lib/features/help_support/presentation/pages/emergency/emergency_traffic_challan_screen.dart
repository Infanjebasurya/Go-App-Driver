import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/pages/emergency/emergency_support_article_screen.dart';

class EmergencyTrafficChallanScreen extends StatelessWidget {
  const EmergencyTrafficChallanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmergencySupportArticleScreen(
      title: 'I received a traffic challan',
      showDefaultGetHelpLine: false,
      content: [
        Text.rich(
          TextSpan(
            style: EmergencyArticleText.body,
            children: [
              TextSpan(
                text: 'GoApp Drivers must always follow traffic regulations.\n\n',
              ),
              TextSpan(
                text:
                    'If you received a traffic challan due to any other reason, please contact ',
              ),
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
