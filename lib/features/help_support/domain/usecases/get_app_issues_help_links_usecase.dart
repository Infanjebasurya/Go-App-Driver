import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/repositories/app_issues_help_repository.dart';

class GetAppIssuesHelpLinksUseCase {
  const GetAppIssuesHelpLinksUseCase(this._repo);

  final AppIssuesHelpRepository _repo;

  Future<List<HelpArticleLink>> call() => _repo.getAppIssuesHelpLinks();
}
