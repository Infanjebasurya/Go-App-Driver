import 'package:goapp/features/help_support/domain/entities/help_article_content.dart';

class EarningsHelpArticleState {
  const EarningsHelpArticleState({required this.content});

  factory EarningsHelpArticleState.initial() =>
      const EarningsHelpArticleState(content: null);

  final HelpArticleContent? content;

  EarningsHelpArticleState copyWith({HelpArticleContent? content}) {
    return EarningsHelpArticleState(content: content);
  }
}
