import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/pages/getting_started/getting_started_article_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/getting_started/getting_started_support_article_screen.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class HowToEarnMoreScreen extends StatelessWidget {
  const HowToEarnMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _EarnMoreTopic.items;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'How to earn more',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: const HelpSupportAppBarBottomDivider(),
      ),
      bottomNavigationBar: const HelpTicketTrackingFooter(),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 8),
        itemCount: items.length,
        separatorBuilder: (_, _) => const HelpSupportThinDivider(),
        itemBuilder: (context, index) {
          final item = items[index];
          return HelpSupportChevronListItem(
            title: item.title,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GettingStartedSupportArticleScreen(
                    title: item.title,
                    content: item.content,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EarnMoreTopic {
  const _EarnMoreTopic({required this.title, required this.content});

  final String title;
  final List<Widget> content;

  static final List<_EarnMoreTopic> items = <_EarnMoreTopic>[
    _EarnMoreTopic(
      title: 'What are incentives?',
      content: const [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Incentives help you '),
              TextSpan(
                text: 'earn extra rewards',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ' by completing certain targets.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Targets may be based on the '),
              TextSpan(
                text: 'number of orders or kilometers completed',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ' within a '),
              TextSpan(
                text: 'daily, weekly, or Bonus period.',
                style: GettingStartedText.bold,
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Once you achieve the target, the '),
              TextSpan(
                text:
                    'incentive amount is automatically credited to your wallet.',
                style: GettingStartedText.bold,
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'You can check available incentives by opening '),
              TextSpan(
                text: 'Menu \u2192 Incentives.',
                style: GettingStartedText.bold,
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'If you need further assistance, please contact '),
              TextSpan(
                text: 'Support Chat or Customer Care',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ' by tapping '),
              TextSpan(text: 'Get Help', style: GettingStartedText.bold),
              TextSpan(text: ' below.'),
            ],
          ),
        ),
      ],
    ),
    _EarnMoreTopic(
      title: 'What are referrals?',
      content: const [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'You can invite friends to join '),
              TextSpan(text: 'GoApp', style: GettingStartedText.bold),
              TextSpan(text: ' using your Referral Code.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'If the eligibility criteria are met, the '),
              TextSpan(text: 'referral bonus', style: GettingStartedText.bold),
              TextSpan(text: ' will be credited to your '),
              TextSpan(text: 'GoApp Wallet', style: GettingStartedText.bold),
              TextSpan(text: ', which you can '),
              TextSpan(
                text: 'transfer to your bank account.',
                style: GettingStartedText.bold,
              ),
            ],
          ),
        ),
      ],
    ),
  ];
}
