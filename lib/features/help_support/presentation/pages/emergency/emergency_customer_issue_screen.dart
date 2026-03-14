import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/pages/emergency/emergency_support_article_screen.dart';

class EmergencyCustomerIssueScreen extends StatelessWidget {
  const EmergencyCustomerIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmergencySupportArticleScreen(
      title: 'I had an issue with a customer',
      showDefaultGetHelpLine: false,
      content: [
        Text.rich(
          TextSpan(
            style: EmergencyArticleText.body,
            children: [
              TextSpan(
                text:
                    'Please avoid getting into an argument with the customer.\n\n',
              ),
              TextSpan(
                text:
                    'If a customer\'s behaviour made you feel unsafe or prevented you from starting or completing the ride, please contact ',
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
              TextSpan(text: ' below.\n\n'),
            ],
          ),
        ),
      ],
    );
  }
}
