import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/pages/getting_started/getting_started_article_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/getting_started/getting_started_support_article_screen.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class HowToTransferMoneyToBankAccountScreen extends StatelessWidget {
  const HowToTransferMoneyToBankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _TransferHelpTopic.topics;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'How to transfer money to bank account',
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
                  builder: (_) => item.needsSupportBar
                      ? GettingStartedSupportArticleScreen(
                          title: item.title,
                          content: item.content,
                        )
                      : GettingStartedArticleScreen(
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

class _TransferHelpTopic {
  const _TransferHelpTopic({
    required this.title,
    required this.content,
    required this.needsSupportBar,
  });

  final String title;
  final List<Widget> content;
  final bool needsSupportBar;

  static const topics = <_TransferHelpTopic>[
    _TransferHelpTopic(
      title: 'How do I transfer money from my wallet?',
      needsSupportBar: true,
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'To transfer money from your '),
              TextSpan(text: 'GoApp Wallet', style: GettingStartedText.bold),
              TextSpan(text: ' to your '),
              TextSpan(text: 'bank account', style: GettingStartedText.bold),
              TextSpan(text: ':'),
            ],
          ),
        ),
        SizedBox(height: 18),
        GettingStartedBulletList(
          items: [
            [
              TextSpan(text: 'Go to the '),
              TextSpan(
                text: 'Documents section',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ' from the menu.'),
            ],
            [
              TextSpan(text: 'Tap on '),
              TextSpan(text: 'Bank Details', style: GettingStartedText.bold),
              TextSpan(text: '.'),
            ],
            [
              TextSpan(text: 'If your wallet balance is greater than '),
              TextSpan(text: '30', style: GettingStartedText.bold),
              TextSpan(text: ', select '),
              TextSpan(text: 'Money Transfer', style: GettingStartedText.bold),
              TextSpan(text: '.'),
            ],
            [
              TextSpan(text: 'Choose your '),
              TextSpan(
                text: 'bank account or UPI',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: '.'),
            ],
            [
              TextSpan(text: 'Tap '),
              TextSpan(text: 'Transfer', style: GettingStartedText.bold),
              TextSpan(text: '.'),
            ],
          ],
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'In most cases, the money will be '),
              TextSpan(
                text: 'transferred immediately.',
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
              TextSpan(text: 'If you need further help, tap '),
              TextSpan(text: 'Get Help', style: GettingStartedText.bold),
              TextSpan(text: ' below'),
            ],
          ),
        ),
      ],
    ),
    _TransferHelpTopic(
      title: 'My transfer request is on hold',
      needsSupportBar: true,
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Your money transfer request may be placed '),
              TextSpan(text: 'on hold', style: GettingStartedText.bold),
              TextSpan(text: ' if the system detects '),
              TextSpan(
                text: 'unusual activity or verification is required.',
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
              TextSpan(
                text:
                    'In such cases, the request will be reviewed by our team. This process may take ',
              ),
              TextSpan(text: 'up to 48 hours.', style: GettingStartedText.bold),
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
    _TransferHelpTopic(
      title: 'A penalty was deducted from my wallet',
      needsSupportBar: true,
      content: [
        Text(
          'Penalties may be charged if a ride violates GoApp policies or if fraudulent activity is detected.',
          style: GettingStartedText.body,
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text: 'If you need further clarification, please contact ',
              ),
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
    _TransferHelpTopic(
      title: 'My transfer request is not credited yet',
      needsSupportBar: true,
      content: [
        Text(
          'Sometimes banks take time to process the credit.',
          style: GettingStartedText.body,
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text: 'The amount should reflect in your bank account within ',
              ),
              TextSpan(
                text: '4-7 working days.',
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
              TextSpan(text: 'You can also use the '),
              TextSpan(
                text: 'Bank Reference Number',
                style: GettingStartedText.bold,
              ),
              TextSpan(
                text:
                    ' shown in the app to confirm the transaction with your bank.',
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text:
                    'If the incentive is still not credited after the day ends, please contact ',
              ),
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
  ];
}
