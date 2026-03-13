import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/repositories/earnings_help_repository.dart';

class GetEarningsHelpLinksUseCase {
  const GetEarningsHelpLinksUseCase(this._repo);

  final EarningsHelpRepository _repo;

  Future<List<HelpArticleLink>> call() => _repo.getEarningsHelpLinks();
}

