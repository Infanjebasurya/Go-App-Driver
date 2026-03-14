import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';

abstract class AccountHelpRepository {
  Future<List<HelpArticleLink>> getAccountHelpLinks();
}
