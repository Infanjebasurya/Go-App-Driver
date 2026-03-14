import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/entities/help_support_links.dart';
import 'package:goapp/features/help_support/domain/repositories/account_help_repository.dart';

class AccountHelpRepositoryMock implements AccountHelpRepository {
  const AccountHelpRepositoryMock();

  @override
  Future<List<HelpArticleLink>> getAccountHelpLinks() async {
    return kAccountHelpLinks;
  }
}
