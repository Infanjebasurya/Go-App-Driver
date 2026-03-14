import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/pages/account/account_support_article_screen.dart';

class UpdateMobileNumberScreen extends StatelessWidget {
  const UpdateMobileNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Update mobile number',
      showDefaultGetHelpLine: false,
      content: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 2,
            ),
            children: [
              TextSpan(text: 'Your mobile number must be '),
              TextSpan(
                text: 'active',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' to log in and receive orders.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 2,
            ),
            children: [
              TextSpan(text: 'To update your number, please contact '),
              TextSpan(
                text: 'Support Chat',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(
                text: ' or Customer Care',
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
        SizedBox(height: 22),
        Text('Please Note :', style: ArticleText.sectionTitle),
        SizedBox(height: 14),
        ArticleBulletList(
          items: [
            [
              TextSpan(text: 'Your ', style: TextStyle(fontSize: 14)),
              TextSpan(
                text: 'wallet balance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' must be ', style: TextStyle(fontSize: 14)),
              TextSpan(
                text: '₹0',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'The ', style: TextStyle(fontSize: 14)),
              TextSpan(
                text: 'new mobile number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(
                text: ' should not already be ',
                style: TextStyle(fontSize: 14),
              ),
              TextSpan(
                text: ' registered with GoApp',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                  height: 2,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
