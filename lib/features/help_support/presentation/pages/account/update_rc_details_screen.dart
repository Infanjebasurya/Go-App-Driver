import 'package:flutter/material.dart';
import 'package:goapp/features/help_support/presentation/pages/account/account_support_article_screen.dart';

class UpdateRcDetailsScreen extends StatelessWidget {
  const UpdateRcDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Update RC details',
      content: [
        Text(
          'You can update your vehicle details from the app.',
          style: ArticleText.body,
        ),
        SizedBox(height: 18),
        Text('Follow these steps:', style: ArticleText.body),
        SizedBox(height: 10),
        ArticleBulletList(
          items: [
            [
              TextSpan(text: 'Open '),
              TextSpan(text: 'Menu', style: ArticleText.bold),
            ],
            [
              TextSpan(text: 'Tap '),
              TextSpan(
                text: 'Documents & Details → RC',
                style: ArticleText.bold,
              ),
            ],
            [
              TextSpan(text: 'Enter the '),
              TextSpan(text: 'vehicle number', style: ArticleText.bold),
              TextSpan(text: ' and '),
              TextSpan(text: 'Upload photo', style: ArticleText.bold),
              TextSpan(text: ' and tap '),
              TextSpan(text: 'Save', style: ArticleText.bold),
            ],
          ],
        ),
        SizedBox(height: 18),
        Text(
          'Your vehicle details will be updated after verification.',
          style: ArticleText.body,
        ),
      ],
    );
  }
}
