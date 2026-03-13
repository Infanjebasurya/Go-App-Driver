import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';

class EarningsHelpState {
  const EarningsHelpState({required this.links});

  factory EarningsHelpState.initial() =>
      const EarningsHelpState(links: <HelpArticleLink>[]);

  final List<HelpArticleLink> links;

  EarningsHelpState copyWith({List<HelpArticleLink>? links}) {
    return EarningsHelpState(links: links ?? this.links);
  }
}
