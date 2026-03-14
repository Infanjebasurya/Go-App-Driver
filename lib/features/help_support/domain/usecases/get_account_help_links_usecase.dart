import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/repositories/account_help_repository.dart';

class GetAccountHelpLinksUseCase {
  const GetAccountHelpLinksUseCase(this._repo);

  final AccountHelpRepository _repo;

  Future<List<HelpArticleLink>> call() => _repo.getAccountHelpLinks();
}
