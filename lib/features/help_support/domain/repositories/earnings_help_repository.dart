import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_content.dart';
import 'package:goapp/features/help_support/domain/entities/help_faq_item.dart';

abstract interface class EarningsHelpRepository {
  Future<List<HelpArticleLink>> getEarningsHelpLinks();

  Future<List<HelpFaqItem>> getEarningsHelpFaqs({required String linkId});

  Future<HelpArticleContent?> getEarningsHelpArticle({
    required String linkId,
    required String faqTitle,
  });
}
