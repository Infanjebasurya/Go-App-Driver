import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/domain/usecases/get_earnings_help_article_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_article_state.dart';

class EarningsHelpArticleCubit extends Cubit<EarningsHelpArticleState> {
  EarningsHelpArticleCubit({
    required GetEarningsHelpArticleUseCase getArticle,
    required String linkId,
    required String faqTitle,
  }) : _getArticle = getArticle,
       _linkId = linkId,
       _faqTitle = faqTitle,
       super(EarningsHelpArticleState.initial());

  final GetEarningsHelpArticleUseCase _getArticle;
  final String _linkId;
  final String _faqTitle;

  Future<void> init() async {
    final content = await _getArticle(linkId: _linkId, faqTitle: _faqTitle);
    emit(state.copyWith(content: content));
  }
}
