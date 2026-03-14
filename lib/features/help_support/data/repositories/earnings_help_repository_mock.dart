import 'package:goapp/features/help_support/domain/entities/help_article_content.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/entities/help_faq_item.dart';
import 'package:goapp/features/help_support/domain/entities/help_text_run.dart';
import 'package:goapp/features/help_support/domain/entities/help_content_block.dart';
import 'package:goapp/features/help_support/domain/repositories/earnings_help_repository.dart';

part 'mock/earnings_help_repository_mock_issue_transferring_to_bank.dart';
part 'mock/earnings_help_repository_mock_issue_with_order_earnings.dart';
part 'mock/earnings_help_repository_mock_learn_about_earnings.dart';
part 'mock/earnings_help_repository_mock_learn_about_incentives.dart';
part 'mock/earnings_help_repository_mock_route_or_location_issues.dart';
part 'mock/earnings_help_repository_mock_transfer_earnings_to_bank.dart';

class EarningsHelpRepositoryMock implements EarningsHelpRepository {
  const EarningsHelpRepositoryMock();

  @override
  Future<List<HelpArticleLink>> getEarningsHelpLinks() async {
    return const <HelpArticleLink>[
      HelpArticleLink(
        id: 'learn_about_earnings',
        title: 'Learn about earnings',
      ),
      HelpArticleLink(
        id: 'issue_with_order_earnings',
        title: 'Issue with order earnings',
      ),
      HelpArticleLink(
        id: 'route_or_location_issues',
        title: 'Route or location issues',
      ),
      HelpArticleLink(
        id: 'learn_about_incentives',
        title: 'Learn about incentives',
      ),
      HelpArticleLink(
        id: 'transfer_earnings_to_bank',
        title: 'Transfer earnings to bank',
      ),
      HelpArticleLink(
        id: 'issue_transferring_to_bank',
        title: 'Issue transferring to bank',
      ),
    ];
  }

  @override
  Future<List<HelpFaqItem>> getEarningsHelpFaqs({
    required String linkId,
  }) async {
    switch (linkId) {
      case 'learn_about_earnings':
        return const <HelpFaqItem>[
          HelpFaqItem(title: 'What is the rate card?'),
          HelpFaqItem(title: 'How are my earnings calculated?'),
          HelpFaqItem(title: 'Where can i check my order earnings?'),
          HelpFaqItem(title: 'What is a customer cancellation fare?'),
          HelpFaqItem(title: 'What is a long pickup fee?'),
          HelpFaqItem(title: 'How do tips work?'),
        ];
      case 'issue_with_order_earnings':
        return const <HelpFaqItem>[
          HelpFaqItem(title: "I didn't receive earnings for an order"),
          HelpFaqItem(title: 'Money was deducted after a cash payment'),
          HelpFaqItem(title: "I didn't receive the cancellation fee"),
          HelpFaqItem(title: "Customer didn't pay for the order"),
          HelpFaqItem(title: "I didn't receive the long pickup fee"),
          HelpFaqItem(title: 'Distance calculation is incorrect'),
        ];
      case 'route_or_location_issues':
        return const <HelpFaqItem>[
          HelpFaqItem(title: 'Issue with the route'),
          HelpFaqItem(title: 'Customer asked to take a different route'),
          HelpFaqItem(title: 'Customer asked to drop at a different location'),
          HelpFaqItem(title: 'Issue with the pickup location'),
          HelpFaqItem(title: 'Issue with the drop location'),
        ];
      case 'learn_about_incentives':
        return const <HelpFaqItem>[
          HelpFaqItem(title: 'What are incentives?'),
          HelpFaqItem(title: 'How can I check my incentives?'),
          HelpFaqItem(title: "Why can't I see incentives for today?"),
          HelpFaqItem(
            title: "Why wasn't my incentive added after reaching the target?",
          ),
          HelpFaqItem(title: 'How can I track my incentive progress?'),
        ];
      case 'transfer_earnings_to_bank':
        return const <HelpFaqItem>[
          HelpFaqItem(title: 'What is money transfer?'),
          HelpFaqItem(title: 'How do I add my bank account?'),
          HelpFaqItem(title: 'How do I transfer money to my bank account?'),
          HelpFaqItem(title: 'How can I change my bank account?'),
          HelpFaqItem(title: 'How many times can I transfer money?'),
        ];
      case 'issue_transferring_to_bank':
        return const <HelpFaqItem>[
          HelpFaqItem(title: 'Transfer request is awaiting approval'),
          HelpFaqItem(title: 'Transfer request is on hold'),
          HelpFaqItem(title: 'Transfer request was rejected'),
          HelpFaqItem(
            title: 'Transfer request is initiated but not completed',
          ),
          HelpFaqItem(title: 'Transfer request failed'),
          HelpFaqItem(
            title: 'Money is credited but not showing in my bank account',
          ),
        ];
      default:
        return const <HelpFaqItem>[];
    }
  }

  @override
  Future<HelpArticleContent?> getEarningsHelpArticle({
    required String linkId,
    required String faqTitle,
  }) async {
    switch (linkId) {
      case 'learn_about_earnings':
        return _learnAboutEarningsArticle(faqTitle);
      case 'issue_with_order_earnings':
        return _issueWithOrderEarningsArticle(faqTitle);
      case 'route_or_location_issues':
        return _routeOrLocationIssuesArticle(faqTitle);
      case 'learn_about_incentives':
        return _learnAboutIncentivesArticle(faqTitle);
      case 'transfer_earnings_to_bank':
        return _transferEarningsToBankArticle(faqTitle);
      case 'issue_transferring_to_bank':
        return _issueTransferringToBankArticle(faqTitle);
      default:
        return null;
    }
  }
}
