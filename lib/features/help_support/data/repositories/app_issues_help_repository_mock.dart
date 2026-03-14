import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/entities/help_support_links.dart';
import 'package:goapp/features/help_support/domain/repositories/app_issues_help_repository.dart';

class AppIssuesHelpRepositoryMock implements AppIssuesHelpRepository {
  const AppIssuesHelpRepositoryMock();

  @override
  Future<List<HelpArticleLink>> getAppIssuesHelpLinks() async {
    return kAppIssuesHelpLinks;
  }
}
