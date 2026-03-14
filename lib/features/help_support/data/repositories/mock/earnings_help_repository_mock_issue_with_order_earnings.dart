part of '../earnings_help_repository_mock.dart';

HelpArticleContent? _issueWithOrderEarningsArticle(String faqTitle) {
  switch (faqTitle) {
    case "I didn't receive earnings for an order":
    case 'I didnâ€™t receive earnings for an order':
      return const HelpArticleContent(
        title: "I didn’t receive earnings for an order",
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Your earnings are updated '),
            HelpTextRun('after every completed ride', bold: true),
            HelpTextRun(' in the '),
            HelpTextRun('Earnings', bold: true),
            HelpTextRun(' section and automatically reflected in your '),
            HelpTextRun('wallet', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If the amount is missing, please contact '),
            HelpTextRun('Support Chat or Customer Care', bold: true),
            HelpTextRun(' by tapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    case 'Money was deducted after a cash payment':
      return const HelpArticleContent(
        title: 'Money deducted after a cash payment',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun(
              'Your earnings remain the same whether the customer pays ',
            ),
            HelpTextRun('cash', bold: true),
            HelpTextRun(' or '),
            HelpTextRun('online', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('For '),
            HelpTextRun('cash rides', bold: true),
            HelpTextRun(
              ', the customer pays the total amount directly to you. From this amount, ',
            ),
            HelpTextRun(
              'GoApp deducts the commission and GST from your wallet',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If the customer had any '),
            HelpTextRun('pending balance from a previous ride', bold: true),
            HelpTextRun(
              ', you may collect it, and the same amount will be deducted from your wallet.',
            ),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You can check the full details in the '),
            HelpTextRun('Order Details', bold: true),
            HelpTextRun(' page.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case "I didn't receive the cancellation fee":
    case 'I didnâ€™t receive the cancellation fee':
      return const HelpArticleContent(
        title: "I didn’t receive the cancellation fee",
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('If a customer cancels an order and you are '),
            HelpTextRun('eligible for a cancellation fare', bold: true),
            HelpTextRun(', the amount is '),
            HelpTextRun('automatically added to your wallet', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You can check your '),
            HelpTextRun('Wallet', bold: true),
            HelpTextRun(' to confirm if the amount has been credited.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'Eligibility for the cancellation fare depends on the ',
            ),
            HelpTextRun(
              'distance traveled towards the pickup location',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Please check your '),
            HelpTextRun('Rate Card', bold: true),
            HelpTextRun(' to see the '),
            HelpTextRun('maximum cancellation fare', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If the issue continues, please contact '),
            HelpTextRun('Support Chat or Customer Care', bold: true),
            HelpTextRun(' by tapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    case "Customer didn't pay for the order":
    case 'Customer didnâ€™t pay for the order':
      return const HelpArticleContent(
        title: "Customer didn’t pay for the order",
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('You must collect the '),
            HelpTextRun('amount shown in the app', bold: true),
            HelpTextRun(' directly from the customer.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'If the customer refuses to pay or there is any issue, please contact ',
            ),
            HelpTextRun('Support Chat or Customer Care', bold: true),
            HelpTextRun(' immediately while the customer is still present.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case "I didn't receive the long pickup fee":
      return const HelpArticleContent(
        title: "I didn't receive the long pickup fee",
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('If you are '),
            HelpTextRun('eligible for a Long Pickup Fare', bold: true),
            HelpTextRun(', the amount is '),
            HelpTextRun(
              'automatically added to your total order earnings',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You can check this in the '),
            HelpTextRun('Order Details', bold: true),
            HelpTextRun(' page.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Please check your '),
            HelpTextRun('Rate Card', bold: true),
            HelpTextRun(' to know:'),
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
              HelpTextRun('Long Pickup fare per km', bold: true),
            ],
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If the amount is missing, please contact '),
            HelpTextRun('Support Chat or Customer Care', bold: true),
            HelpTextRun(' by tapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    case 'Distance calculation is incorrect':
      return const HelpArticleContent(
        title: 'Distance calculation is incorrect',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Your earnings are calculated based on the '),
            HelpTextRun('route suggested by GoApp', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Please follow the suggested route whenever possible.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you had to take a '),
            HelpTextRun('different route', bold: true),
            HelpTextRun(', contact '),
            HelpTextRun('Customer Care or Support Chat', bold: true),
            HelpTextRun(
              ' and explain the reason so the team can review and make any required adjustments to your wallet.',
            ),
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
