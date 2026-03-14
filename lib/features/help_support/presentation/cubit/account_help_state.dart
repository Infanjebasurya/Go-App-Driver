import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/entities/help_support_links.dart';

class AccountHelpState {
  const AccountHelpState({required this.links});

  factory AccountHelpState.initial() =>
      const AccountHelpState(links: kAccountHelpLinks);

  final List<HelpArticleLink> links;

  AccountHelpState copyWith({List<HelpArticleLink>? links}) {
    return AccountHelpState(links: links ?? this.links);
  }
}
