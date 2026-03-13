part of '../earnings_help_repository_mock.dart';

HelpArticleContent? _transferEarningsToBankArticle(String faqTitle) {
  switch (faqTitle) {
    case 'What is money transfer?':
      return const HelpArticleContent(
        title: 'What is money transfer?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Money Transfer is the process of transferring money\nfrom your '),
            HelpTextRun('GoApp Wallet', bold: true),
            HelpTextRun(' to your '),
            HelpTextRun('bank account', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Your earnings are stored in the '),
            HelpTextRun('GoApp Wallet', bold: true),
            HelpTextRun(', and you\ncan transfer them to your '),
            HelpTextRun('bank account or UPI', bold: true),
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
    case 'How do I add my bank account?':
      return const HelpArticleContent(
        title: 'How do I add my bank account?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('To add your bank account or UPI details:'),
          ]),
          HelpSpacerBlock(14),
          HelpBulletsBlock([
            [
              HelpTextRun('Go to the '),
              HelpTextRun('Documents section from the menu.', bold: true),
            ],
            [HelpTextRun('Tap on '), HelpTextRun('Bank Details.', bold: true)],
            [
              HelpTextRun('Enter your '),
              HelpTextRun('bank account details.', bold: true),
            ],
            [HelpTextRun('Tap '), HelpTextRun('Confirm.', bold: true)],
            [
              HelpTextRun('You will receive an '),
              HelpTextRun('OTP', bold: true),
              HelpTextRun(' on your registered\nmobile number.'),
            ],
            [
              HelpTextRun('Enter the '),
              HelpTextRun('OTP', bold: true),
              HelpTextRun(' to verify.'),
            ],
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Your bank account will be added successfully.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case 'How do I transfer money to my bank account?':
      return const HelpArticleContent(
        title: 'Transfer money to my bank account?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('To transfer money from your '),
            HelpTextRun('GoApp Wallet', bold: true),
            HelpTextRun(' to your\n'),
            HelpTextRun('bank account', bold: true),
            HelpTextRun(':'),
          ]),
          HelpSpacerBlock(14),
          HelpBulletsBlock([
            [
              HelpTextRun('Go to the '),
              HelpTextRun('Documents section from the menu.', bold: true),
            ],
            [HelpTextRun('Tap on '), HelpTextRun('Bank Details.', bold: true)],
            [
              HelpTextRun('If your wallet balance is greater than '),
              HelpTextRun('30', bold: true),
              HelpTextRun(', select\n'),
              HelpTextRun('Money Transfer.', bold: true),
            ],
            [
              HelpTextRun('Choose your '),
              HelpTextRun('bank account or UPI.', bold: true),
            ],
            [HelpTextRun('Tap '), HelpTextRun('Transfer.', bold: true)],
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('In most cases, the money will be '),
            HelpTextRun('transferred\nimmediately.', bold: true),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case 'How can I change my bank account?':
      return const HelpArticleContent(
        title: 'How can I change my bank account?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('To update your bank account or UPI details:'),
          ]),
          HelpSpacerBlock(14),
          HelpBulletsBlock([
            [
              HelpTextRun('Go to the '),
              HelpTextRun('Documents section from the menu.', bold: true),
            ],
            [HelpTextRun('Tap on '), HelpTextRun('Bank Details.', bold: true)],
            [HelpTextRun('Select '), HelpTextRun('Add Bank details.', bold: true)],
            [
              HelpTextRun('Enter your updated '),
              HelpTextRun('bank account details.', bold: true),
            ],
            [HelpTextRun('Tap '), HelpTextRun('Confirm.', bold: true)],
            [
              HelpTextRun('Enter the '),
              HelpTextRun('OTP', bold: true),
              HelpTextRun(' received on your registered\nmobile number.'),
            ],
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Your bank account details will be updated successfully.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If you need further help, tap '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below'),
          ]),
        ],
      );
    case 'How many times can I transfer money?':
      return const HelpArticleContent(
        title: 'How many times can I transfer money?',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('To update your bank account or UPI details:'),
          ]),
          HelpSpacerBlock(14),
          HelpBulletsBlock([
            [
              HelpTextRun('Go to the '),
              HelpTextRun('Documents section from the menu.', bold: true),
            ],
            [HelpTextRun('Tap on '), HelpTextRun('Bank Details.', bold: true)],
            [
              HelpTextRun('Select '),
              HelpTextRun('Money Transfer Left.', bold: true),
            ],
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You will see how many money '),
            HelpTextRun('transfers are available\nfor the day or week.', bold: true),
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

