part of '../earnings_help_repository_mock.dart';

HelpArticleContent? _learnAboutEarningsArticle(String faqTitle) {
  switch (faqTitle) {
    case 'What is the rate card?':
      return const HelpArticleContent(
        title: 'What is the rate card?',
        showBottomActions: false,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('The '),
            HelpTextRun('Rate Card', bold: true),
            HelpTextRun(' shows how your earnings are calculated\non GoApp.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('It may vary depending on the '),
            HelpTextRun('service type and the city', bold: true),
            HelpTextRun(' you\noperate in.'),
          ]),
        ],
      );
    case 'How are my earnings calculated?':
      return const HelpArticleContent(
        title: 'How are my earnings calculated?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Your total earnings for an order are calculated as:'),
          ]),
          HelpSpacerBlock(12),
          HelpParagraphBlock([
            HelpTextRun(
              'Order Fare + Extra Fare (if applicable) – Commission –\nGST',
              bold: true,
            ),
          ]),
          HelpSpacerBlock(16),
          HelpParagraphBlock([
            HelpTextRun('You can check the detailed breakdown in your '),
            HelpTextRun('Rate\nCard', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpHeadingBlock('To view the Rate Card :'),
          HelpSpacerBlock(10),
          HelpBulletsBlock([
            [HelpTextRun('Open '), HelpTextRun('Menu', bold: true)],
            [HelpTextRun('Tap '), HelpTextRun('Earnings & Wallet', bold: true)],
            [HelpTextRun('Tap '), HelpTextRun('Rate Card', bold: true)],
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case 'Where can i check my order earnings?':
      return const HelpArticleContent(
        title: 'Where can i check my order earnings?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('To view earnings for previous orders:'),
          ]),
          HelpSpacerBlock(14),
          HelpBulletsBlock([
            [
              HelpTextRun('Open '),
              HelpTextRun('Earnings', bold: true),
              HelpTextRun(' from the menu'),
            ],
            [
              HelpTextRun('Tap '),
              HelpTextRun('All Orders', bold: true),
              HelpTextRun(' in the '),
              HelpTextRun('All Earnings', bold: true),
              HelpTextRun(' tab'),
            ],
            [
              HelpTextRun('Select a '),
              HelpTextRun('Date, Week, Or Month', bold: true),
            ],
            [
              HelpTextRun('Choose an order to view the '),
              HelpTextRun('Earnings Details', bold: true),
            ],
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case 'What is a customer cancellation fare?':
      return const HelpArticleContent(
        title: 'What is a customer cancellation fare?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('If a customer cancels a ride, you '),
            HelpTextRun('may receive a\ncancellation fare', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Eligibility depends on the '),
            HelpTextRun(
              'distance traveled towards\nthe pickup location',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you are eligible, the '),
            HelpTextRun(
              'cancellation amount will be\nautomatically added to your wallet',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You can check your '),
            HelpTextRun('Rate Card', bold: true),
            HelpTextRun(' to see the maximum\ncancellation fare.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case 'What is a long pickup fee?':
      return const HelpArticleContent(
        title: 'What is a long pickup fee?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun(
              'If the pickup location is far away, you may receive a ',
            ),
            HelpTextRun('Long Pickup Fare', bold: true),
            HelpTextRun(
              ' for the extra distance traveled to\nreach the pickup point.',
            ),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If applicable, this amount will be '),
            HelpTextRun('automatically added\nto your order earnings', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You can view it in the '),
            HelpTextRun('Order Details', bold: true),
            HelpTextRun(' page.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Check your '),
            HelpTextRun('Rate Card', bold: true),
            HelpTextRun(' to see:'),
          ]),
          HelpSpacerBlock(14),
          HelpBulletsBlock([
            [
              HelpTextRun('The '),
              HelpTextRun('Minimum distance', bold: true),
              HelpTextRun(' for long pickup eligibility'),
            ],
            [
              HelpTextRun('The '),
              HelpTextRun('Fare per km', bold: true),
            ],
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case 'How do tips work?':
      return const HelpArticleContent(
        title: 'How do tips work?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('When customers tip you for good service, you keep\n'),
            HelpTextRun('100% of the tip amount', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'If a customer adds a tip to the ride, it will be credited to\nyour wallet or You can collect the cash based on\npayment.',
            ),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You can view the tip in '),
            HelpTextRun('Transaction History', bold: true),
            HelpTextRun(' under the\n'),
            HelpTextRun('Wallet', bold: true),
            HelpTextRun(' tab in the '),
            HelpTextRun('Earnings', bold: true),
            HelpTextRun(' section.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    default:
      return null;
  }
}

