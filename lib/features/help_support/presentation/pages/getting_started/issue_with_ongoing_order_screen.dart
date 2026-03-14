import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/pages/getting_started/getting_started_article_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/getting_started/getting_started_support_article_screen.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class IssueWithAnOngoingOrderScreen extends StatelessWidget {
  const IssueWithAnOngoingOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _OngoingOrderTopic.items;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Issue with an ongoing order',
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

class _OngoingOrderTopic {
  const _OngoingOrderTopic({required this.title, required this.content});

  final String title;
  final List<Widget> content;

  static final List<_OngoingOrderTopic> items = <_OngoingOrderTopic>[
    _OngoingOrderTopic(
      title: 'Unable to find the pickup location',
      content: const [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text:
                    'If you are unable to find the pickup location, try contacting the ',
              ),
              TextSpan(text: 'rider', style: GettingStartedText.bold),
              TextSpan(text: ' for additional directions.'),
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
                    'If you are still unable to reach the pickup location or connect with the rider, please contact ',
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
    _OngoingOrderTopic(
      title: 'Unable to find the drop location',
      content: const [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Please contact the '),
              TextSpan(text: 'rider', style: GettingStartedText.bold),
              TextSpan(text: ' to confirm the correct drop location.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text(
          'You should drop the rider at their preferred location. Your earnings will be recalculated based on the updated drop location.',
          style: GettingStartedText.body,
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text:
                    'If you face any issues with your earnings, please contact ',
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
    _OngoingOrderTopic(
      title: 'Issue with the route',
      content: const [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'We recommend using the '),
              TextSpan(text: 'Navigation', style: GettingStartedText.bold),
              TextSpan(text: ' option in the '),
              TextSpan(text: 'GoApp app', style: GettingStartedText.bold),
              TextSpan(text: ' and following the suggested route.'),
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
                    'If you had to take a different route due to on-ground conditions and your ',
              ),
              TextSpan(
                text: 'earnings were not calculated correctly',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ', please contact '),
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
    _OngoingOrderTopic(
      title: 'Customer asked to cancel the order',
      content: const [
        Text(
          'If the rider asks you to cancel the ride:',
          style: GettingStartedText.body,
        ),
        SizedBox(height: 14),
        GettingStartedBulletList(
          items: [
            [
              TextSpan(text: 'Tap '),
              TextSpan(text: 'Cancel My Order', style: GettingStartedText.bold),
            ],
            [
              TextSpan(text: 'Select the reason '),
              TextSpan(
                text: 'Rider Asked to Cancel',
                style: GettingStartedText.bold,
              ),
            ],
          ],
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text: 'If you face any issues while canceling, please contact ',
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
    _OngoingOrderTopic(
      title: 'Pickup distance is too long',
      content: const [
        Text(
          'The long pickup fare will be shown on the order accept screen and after you accept the ride.',
          style: GettingStartedText.body,
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text:
                    'If eligible, the additional pickup distance fare will be ',
              ),
              TextSpan(
                text: 'automatically added to your earnings.',
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
                    'Extra payment is applied only for the distance traveled ',
              ),
              TextSpan(
                text: 'beyond the defined limit for your city.',
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
    _OngoingOrderTopic(
      title: 'Earnings not credited to my wallet',
      content: const [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text:
                    'Your earnings are updated after every ride and automatically reflected in your ',
              ),
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
                text: 'If the earnings are not updated, please contact ',
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
    _OngoingOrderTopic(
      title: 'Will I get a cancellation fee for the previous order?',
      content: const [
        Text(
          'Eligibility for receiving the cancellation fare depends on the distance and time traveled and may vary by city.',
          style: GettingStartedText.body,
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(
                text: 'If you are eligible, the cancellation amount will be ',
              ),
              TextSpan(
                text: 'automatically added to your wallet.',
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
    _OngoingOrderTopic(
      title: 'Drop location was changed',
      content: const [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'Your '),
              TextSpan(
                text: 'earnings will be recalculated',
                style: GettingStartedText.bold,
              ),
              TextSpan(text: ' based on the updated drop location.'),
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
                    'If you notice any issues with the updated earnings, please contact ',
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
    _OngoingOrderTopic(
      title: 'I didn’t follow the route shown in the app',
      content: const [
        Text.rich(
          TextSpan(
            style: GettingStartedText.body,
            children: [
              TextSpan(text: 'We recommend using the '),
              TextSpan(text: 'Navigation', style: GettingStartedText.bold),
              TextSpan(text: ' option in the '),
              TextSpan(text: 'GoApp', style: GettingStartedText.bold),
              TextSpan(text: ' app and following the suggested route. '),
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
                    'If you had to take a different route due to on-ground conditions, your earnings will be ',
              ),
              TextSpan(
                text: 'recalculated accordingly.',
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
                text: 'If the earnings appear incorrect, please contact ',
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
