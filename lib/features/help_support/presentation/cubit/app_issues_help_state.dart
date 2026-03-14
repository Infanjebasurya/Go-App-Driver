import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/entities/help_support_links.dart';

class AppIssuesHelpState {
  const AppIssuesHelpState({required this.links});

  factory AppIssuesHelpState.initial() =>
      const AppIssuesHelpState(links: kAppIssuesHelpLinks);

  final List<HelpArticleLink> links;

  AppIssuesHelpState copyWith({List<HelpArticleLink>? links}) {
    return AppIssuesHelpState(links: links ?? this.links);
  }
}
