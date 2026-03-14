part of '../earnings_help_repository_mock.dart';

HelpArticleContent? _learnAboutIncentivesArticle(String faqTitle) {
  final String normalizedTitle =
      faqTitle.replaceAll(RegExp(r'\s+'), ' ').trim();
  switch (normalizedTitle) {
    case 'What are incentives?':
      return const HelpArticleContent(
        title: 'What are incentives?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Incentives help you earn '),
            HelpTextRun('extra rewards', bold: true),
            HelpTextRun(' by completing certain targets.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Targets may be based on the '),
            HelpTextRun(
              'number of orders or kilometers completed',
              bold: true,
            ),
            HelpTextRun(' within a '),
            HelpTextRun('daily, weekly, or bonus period', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Once you achieve the target, the '),
            HelpTextRun(
              'incentive amount is automatically credited to your wallet',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You can check available incentives by opening '),
            HelpTextRun('Menu → Incentives', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further assistance, please contact '),
            HelpTextRun('Support Chat or Customer Care', bold: true),
            HelpTextRun(' by tapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    case 'How can I check my incentives?':
      return const HelpArticleContent(
        title: 'How can I check my incentives?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('You can view your eligible incentives on the '),
            HelpTextRun('Incentives page', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Open '),
            HelpTextRun('Menu → Incentives', bold: true),
            HelpTextRun(
              ' to see the available incentive programs and details.',
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
    case "Why can't I see incentives for today?":
      return const HelpArticleContent(
        title: "Why can't I see incentives for today?",
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Incentives on '),
            HelpTextRun('GoApp', bold: true),
            HelpTextRun(' are '),
            HelpTextRun('subject to availability', bold: true),
            HelpTextRun(', so they may not be available every day.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You can check the '),
            HelpTextRun('Incentives', bold: true),
            HelpTextRun(
              ' page from the menu to see the incentives currently available to you.',
            ),
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
    case "Why wasn't my incentive added after reaching the target?":
      return const HelpArticleContent(
        title: "Why wasn't my incentive added after reaching the target?",
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('The incentive amount is usually '),
            HelpTextRun(
              'credited immediately after you meet the target',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('In some cases, it may be credited by '),
            HelpTextRun('the end of the day', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'If the incentive is still not credited after the day ends, please contact ',
            ),
            HelpTextRun('Support Chat or Customer Care', bold: true),
            HelpTextRun(' by tapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    case 'How can I track my incentive progress?':
      return const HelpArticleContent(
        title: 'How can I track my incentive progress?',
        showBottomActions: false,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('You can track your progress on the '),
            HelpTextRun('Incentives page', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Open '),
            HelpTextRun('Menu → Incentives', bold: true),
            HelpTextRun(' to view your '),
            HelpTextRun(
              'daily, weekly, or bonus incentive progress',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
        ],
      );
    default:
      return null;
  }
}
