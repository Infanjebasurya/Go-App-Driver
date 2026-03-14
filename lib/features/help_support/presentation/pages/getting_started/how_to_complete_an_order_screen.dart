import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/pages/getting_started/getting_started_article_screen.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class HowToCompleteAnOrderScreen extends StatelessWidget {
  const HowToCompleteAnOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _OrderHelpTopic.topics;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'How to complete an order',
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
                  builder: (_) => GettingStartedArticleScreen(
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

class _OrderHelpTopic {
  const _OrderHelpTopic({required this.title, required this.content});

  final String title;
  final List<Widget> content;

  static const topics = <_OrderHelpTopic>[
    _OrderHelpTopic(
      title: 'How do I get orders?',
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Once your '),
              TextSpan(
                text: 'GoApp Driver account',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ' is activated, you can start receiving orders'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'To receive orders, first go '),
              TextSpan(text: 'On Duty', style: GettingStartedText.bold),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Open the app and use the '),
              TextSpan(text: 'On Duty toggle', style: GettingStartedText.bold),
              TextSpan(
                text: ' on the home screen to start receiving ride requests.',
              ),
            ],
          ),
        ),
      ],
    ),
    _OrderHelpTopic(
      title: 'How do I accept an order?',
      content: [
        Text(
          'When a customer nearby requests a ride, you will receive a notification in the app.',
          style: GettingStartedText.body,
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'You can either '),
              TextSpan(text: 'Accept Ride', style: GettingStartedText.bold),
              TextSpan(text: ' to take the order or '),
              TextSpan(text: 'Skip', style: GettingStartedText.bold),
              TextSpan(text: ' to ignore it.'),
            ],
          ),
        ),
      ],
    ),
    _OrderHelpTopic(
      title: 'How do I start an order?',
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'After accepting the ride, move towards the '),
              TextSpan(
                text: 'pickup location',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Use the '),
              TextSpan(text: 'Navigate', style: GettingStartedText.bold),
              TextSpan(
                text:
                    ' icon to find the route to the customer’s pickup point.',
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text('After reaching the location:', style: GettingStartedText.body),
        SizedBox(height: 14),
        GettingStartedBulletList(
          items: [
            [
              TextSpan(text: 'Tap '),
              TextSpan(text: 'Arrived', style: GettingStartedText.bold),
              TextSpan(text: ' to notify the customer.'),
            ],
            [
              TextSpan(text: 'Once the customer enters the vehicle, ask for '),
              TextSpan(text: 'the 4-digit PIN', style: GettingStartedText.bold),
              TextSpan(text: '.'),
            ],
            [
              TextSpan(text: 'Enter the PIN in the app to '),
              TextSpan(text: 'start the ride', style: GettingStartedText.bold),
              TextSpan(text: '.'),
            ],
          ],
        ),
      ],
    ),
    _OrderHelpTopic(
      title: 'How do I contact the customer?',
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'To contact the customer, tap the '),
              TextSpan(text: 'Chat/Call', style: GettingStartedText.bold),
              TextSpan(text: ' icon in the app.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text('You will see two options:', style: GettingStartedText.body),
        SizedBox(height: 12),
        GettingStartedBulletList(
          items: [
            [
              TextSpan(text: 'Call', style: GettingStartedText.bold),
              TextSpan(text: ' the customer'),
            ],
            [
              TextSpan(text: 'Chat', style: GettingStartedText.bold),
              TextSpan(text: ' with the customer'),
            ],
          ],
        ),
      ],
    ),
    _OrderHelpTopic(
      title: 'How do I get support during an order?',
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text:
                    'If you need assistance during an order, you can contact ',
              ),
              TextSpan(
                text: 'Customer Care or Support Chat',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Tap the '),
              TextSpan(text: 'Chat/Call', style: GettingStartedText.bold),
              TextSpan(text: ' icon on the home screen.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Then select '),
              TextSpan(text: 'Get Help', style: GettingStartedText.bold),
              TextSpan(
                text: ' and choose the reason for support to connect with ',
              ),
              TextSpan(
                text: 'Customer Care or Support Chat',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    ),
    _OrderHelpTopic(
      title: 'How will I receive my ride earnings?',
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'If the customer pays '),
              TextSpan(text: 'online', style: GettingStartedText.bold),
              TextSpan(text: ', your earnings will be added to your '),
              TextSpan(text: 'wallet', style: GettingStartedText.bold),
              TextSpan(text: '.'),
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
                    'If the customer pays cash, you can collect the ride fare directly. The ',
              ),
              TextSpan(text: 'platform fee', style: GettingStartedText.bold),
              TextSpan(text: ' will be deducted from your wallet.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'If the payment is '),
              TextSpan(
                text: 'partially online and partially cash',
                style: GettingStartedText.bold,
              ),
              TextSpan(
                text:
                    ', the remaining amount will be adjusted in your wallet after deducting the platform fee.',
              ),
            ],
          ),
        ),
      ],
    ),
    _OrderHelpTopic(
      title: 'How can I get more orders?',
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'To receive more orders while you are '),
              TextSpan(text: 'On Duty', style: GettingStartedText.bold),
              TextSpan(text: ', enable '),
              TextSpan(
                text: 'High Demand Areas',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ' on the home screen.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text(
          'This will highlight nearby locations with high demand. Moving towards these areas can help you get more ride requests.',
          style: GettingStartedText.body,
        ),
      ],
    ),
    _OrderHelpTopic(
      title: 'What is routing booking?',
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text:
                    'When this option is enabled, the app will try to assign rides ',
              ),
              TextSpan(
                text: 'towards your home route',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'To use this feature, you must first '),
              TextSpan(
                text: 'save your home address',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ' in the app.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'You can use '),
              TextSpan(
                text: 'My Routing Booking',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ' up to '),
              TextSpan(
                text: 'two times per day',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ', and it will automatically disable after '),
              TextSpan(text: 'two hours', style: GettingStartedText.bold),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    ),
    _OrderHelpTopic(
      title: 'What is on-ride booking?',
      content: [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'When '),
              TextSpan(text: 'On-Ride Booking', style: GettingStartedText.bold),
              TextSpan(text: ' is enabled, '),
              TextSpan(text: 'GoApp', style: GettingStartedText.bold),
              TextSpan(text: ' may assign your '),
              TextSpan(text: 'next ride', style: GettingStartedText.bold),
              TextSpan(text: ' before you complete the current one.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'You will see the details of the next order '),
              TextSpan(
                text: 'after finishing the ongoing ride',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text('Note:', style: GettingStartedText.noteLabel),
        Text(
          'Enabling this option does not guarantee that you will receive another ride immediately. Order availability depends on demand in the area.',
          style: GettingStartedText.body,
        ),
      ],
    ),
  ];
}
