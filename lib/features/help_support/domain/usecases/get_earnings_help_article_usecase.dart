import 'package:goapp/features/help_support/domain/entities/help_article_content.dart';
import 'package:goapp/features/help_support/domain/repositories/earnings_help_repository.dart';

class GetEarningsHelpArticleUseCase {
  const GetEarningsHelpArticleUseCase(this._repo);

  final EarningsHelpRepository _repo;

  Future<HelpArticleContent?> call({
    required String linkId,
    required String faqTitle,
  }) {
    return _repo.getEarningsHelpArticle(linkId: linkId, faqTitle: faqTitle);
  }
}

