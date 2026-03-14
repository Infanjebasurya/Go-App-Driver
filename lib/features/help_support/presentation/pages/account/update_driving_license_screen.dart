import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/pages/account/account_support_article_screen.dart';

class UpdateDrivingLicenseScreen extends StatelessWidget {
  const UpdateDrivingLicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Update driving license',
      showDefaultGetHelpLine: false,
      content: [
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'Once uploaded and verified, the '),
              TextSpan(
                text: 'driving license cannot\nbe updated',
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
              TextSpan(text: 'If you need further assistance, please contact '),
              TextSpan(
                text: 'Support\nChat or Customer Care',
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
