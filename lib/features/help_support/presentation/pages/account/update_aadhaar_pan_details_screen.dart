import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/pages/account/account_support_article_screen.dart';

class UpdateAadhaarPanDetailsScreen extends StatelessWidget {
  const UpdateAadhaarPanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Update Aadhaar / PAN details',
      showDefaultGetHelpLine: false,
      content: [
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'Once uploaded and verified, the '),
              TextSpan(
                text: 'Aadhaar or PAN cannot be updated',
                style: TextStyle(
                  height: 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'If you need help, please contact '),
              TextSpan(
                text: 'Support Chat or',
                style: TextStyle(
                  height: 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),

              TextSpan(
                text: ' Customer Care',
                style: TextStyle(
                  height: 2,
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
