import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/pages/account/account_support_article_screen.dart';

class AboutGoAppIdCardScreen extends StatelessWidget {
  const AboutGoAppIdCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'About GoApp ID card',
      showDefaultGetHelpLine: false,
      content: [
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'The '),
              TextSpan(
                text: 'GoApp ID Card',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' identifies you as a '),
              TextSpan(
                text: 'GoApp Driver',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'It includes your '),
              TextSpan(
                text: 'phone number',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'driving license number',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' for verification.'),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(
          'You can show this ID while taking rides if someone asks for identification.',
          style: ArticleText.body,
        ),
        SizedBox(height: 22),
        Text('To share your ID card:', style: ArticleText.body),
        SizedBox(height: 12),
        ArticleBulletList(
          items: [
            [
              TextSpan(text: 'Open '),
              TextSpan(
                text: 'Menu → Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'Tap '),
              TextSpan(
                text: 'GoApp ID Card',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'Tap '),
              TextSpan(
                text: 'Share',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
