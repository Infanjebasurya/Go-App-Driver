part of '../earnings_help_repository_mock.dart';

HelpArticleContent? _issueTransferringToBankArticle(String faqTitle) {
  switch (faqTitle) {
    case 'Transfer request is awaiting approval':
      return const HelpArticleContent(
        title: 'Transfer request is awaiting approval',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Your money transfer request has been sent for '),
            HelpTextRun('manual\napproval', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('This process may take '),
            HelpTextRun('up to 24 hours', bold: true),
            HelpTextRun(
              '. Once approved,\nthe amount will be transferred to your bank account.',
            ),
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
    case 'Transfer request is on hold':
      return const HelpArticleContent(
        title: 'Transfer request is on hold',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Your money transfer request may be placed '),
            HelpTextRun('on hold', bold: true),
            HelpTextRun(' if\nthe system detects '),
            HelpTextRun(
              'unusual activity or verification is\nrequired',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'In such cases, the request will be reviewed by our\nteam. This process may take ',
            ),
            HelpTextRun('up to 48 hours', bold: true),
            HelpTextRun('.'),
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
    case 'Transfer request was rejected':
      return const HelpArticleContent(
        title: 'Transfer request was rejected',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('This means the money transfer request '),
            HelpTextRun('could not be\nprocessed', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'In some cases, deductions or penalties may apply if\n',
            ),
            HelpTextRun(
              'policy violations or suspicious activity are detected',
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
    case 'Transfer request is initiated but not\ncompleted':
      return const HelpArticleContent(
        title: 'Transfer request is initiated',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Your transfer request has been '),
            HelpTextRun('successfully initiated', bold: true),
            HelpTextRun('\nand is currently being processed by the bank.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('Sometimes delays can occur due to '),
            HelpTextRun('bank processing\ntime', bold: true),
            HelpTextRun(' or '),
            HelpTextRun('technical issues', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'Please wait for some time. The amount will be credited\nto your bank account once processing is complete',
            ),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('If the transfer status shows '),
            HelpTextRun('Failed', bold: true),
            HelpTextRun(', the amount will be\nreturned to your '),
            HelpTextRun('GoApp Wallet', bold: true),
            HelpTextRun(', and you can try the\ntransfer again.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'If the incentive is still not credited after the day ends,\nplease contact ',
            ),
            HelpTextRun('Support Chat or Customer Care', bold: true),
            HelpTextRun(' by\ntapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    case 'Transfer request failed':
      return const HelpArticleContent(
        title: 'Transfer request failed',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('This can happen if there is an '),
            HelpTextRun(
              'issue with the bank or a\ntechnical problem during the transaction',
              bold: true,
            ),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('In such cases, the amount will be '),
            HelpTextRun('returned to your\nGoApp Wallet', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'You can try transferring the amount again after some\ntime.',
            ),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'If the incentive is still not credited after the day ends,\nplease contact ',
            ),
            HelpTextRun('Support Chat or Customer Care', bold: true),
            HelpTextRun(' by\ntapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    case 'Money is credited but not showing in my\nbank account':
      return const HelpArticleContent(
        title: 'Money not showing in my bank account',
        showBottomActions: true,
        blocks: [
          HelpParagraphBlock([
            HelpTextRun('Sometimes banks take time to process the credit.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'The amount should reflect in your bank account within\n',
            ),
            HelpTextRun('4-7 working days', bold: true),
            HelpTextRun('.'),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun('You can also use the '),
            HelpTextRun('Bank Reference Number', bold: true),
            HelpTextRun(
              ' shown\nin the app to confirm the transaction with your bank.',
            ),
          ]),
          HelpSpacerBlock(18),
          HelpParagraphBlock([
            HelpTextRun(
              'If the incentive is still not credited after the day ends,\nplease contact ',
            ),
            HelpTextRun('Support Chat or Customer Care', bold: true),
            HelpTextRun(' by\ntapping '),
            HelpTextRun('Get Help', bold: true),
            HelpTextRun(' below.'),
          ]),
        ],
      );
    default:
      return null;
  }
}
