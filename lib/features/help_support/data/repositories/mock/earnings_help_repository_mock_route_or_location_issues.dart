part of '../earnings_help_repository_mock.dart';

HelpArticleContent? _routeOrLocationIssuesArticle(String faqTitle) {
  switch (faqTitle) {
    case 'Issue with the route':
      return const HelpArticleContent(
        title: 'Issue with the route',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Your earnings are calculated based on the '),
            HelpTextRun('route\nsuggested by GoApp', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Please follow the suggested route whenever possible.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further assistance, please contact '),
            HelpTextRun('Support\nChat or Customer Care', bold: true),
            HelpTextRun(' by tapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    case 'Customer asked to take a different route':
      return const HelpArticleContent(
        title: 'Customer asked to take a different route',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Please follow the '),
            HelpTextRun('route suggested by GoApp', bold: true),
            HelpTextRun('\nwhenever possible.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'If a customer asks you to take a different route or\nchange the drop location, you may follow the\ncustomer’s request.',
            ),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'Your earnings will be calculated based on the final\n',
            ),
            HelpTextRun('drop location', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case 'Customer asked to drop at a different location':
      return const HelpArticleContent(
        title: 'Customer asked to drop different location',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('If a customer asks you to drop them at a '),
            HelpTextRun('different\nlocation', bold: true),
            HelpTextRun(', please follow the customer’s instructions.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Your '),
            HelpTextRun(
              'earnings will be calculated based on the new\ndrop location',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If the issue continues, please contact '),
            HelpTextRun('Support Chat or\nCustomer Care', bold: true),
            HelpTextRun(' by tapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    case 'Issue with the pickup location':
      return const HelpArticleContent(
        title: 'Issue with the pickup location',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('The '),
            HelpTextRun('GoApp Driver app', bold: true),
            HelpTextRun(' helps you navigate to the\ncorrect pickup point.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Please use the '),
            HelpTextRun('Navigation', bold: true),
            HelpTextRun(' option in the app to reach\nthe pickup location.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case 'Issue with the drop location':
      return const HelpArticleContent(
        title: 'Issue with the drop location',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('The '),
            HelpTextRun('GoApp Driver app', bold: true),
            HelpTextRun(' helps you navigate to the\ncorrect drop location.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Please use the '),
            HelpTextRun('Navigation', bold: true),
            HelpTextRun(' option in the app.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Your earnings will be calculated based on the '),
            HelpTextRun('route\nsuggested by GoApp', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If the amount is missing, please contact '),
            HelpTextRun('Support Chat\nor Customer Care', bold: true),
            HelpTextRun(' by tapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    default:
      return null;
  }
}
