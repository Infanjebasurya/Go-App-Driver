import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_content.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/entities/help_content_block.dart';
import 'package:goapp/features/help_support/domain/entities/help_faq_item.dart';
import 'package:goapp/features/help_support/domain/entities/help_text_run.dart';
import 'package:goapp/features/help_support/domain/repositories/earnings_help_repository.dart';
import 'package:goapp/features/help_support/domain/usecases/get_earnings_help_article_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_article_cubit.dart';

class _FakeRepo implements EarningsHelpRepository {
  @override
  Future<List<HelpArticleLink>> getEarningsHelpLinks() async => const [];

  @override
  Future<List<HelpFaqItem>> getEarningsHelpFaqs({required String linkId}) async =>
      const [];

  @override
  Future<HelpArticleContent?> getEarningsHelpArticle({
    required String linkId,
    required String faqTitle,
  }) async {
    if (linkId == 'learn_about_earnings' && faqTitle == 'What is the rate card?') {
      return const HelpArticleContent(
        title: 'What is the rate card?',
        showBottomActions: false,
        blocks: [
          HelpParagraphBlock([HelpTextRun('Hello')]),
        ],
      );
    }
    return null;
  }
}

void main() {
  group('EarningsHelpArticleCubit', () {
    test('init loads article content', () async {
      final cubit = EarningsHelpArticleCubit(
        getArticle: GetEarningsHelpArticleUseCase(_FakeRepo()),
        linkId: 'learn_about_earnings',
        faqTitle: 'What is the rate card?',
      );

      await cubit.init();

      expect(cubit.state.content, isNotNull);
      expect(cubit.state.content!.title, 'What is the rate card?');
      await cubit.close();
    });
  });
}

