import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_content.dart';
import 'package:goapp/features/help_support/domain/entities/help_faq_item.dart';
import 'package:goapp/features/help_support/domain/repositories/earnings_help_repository.dart';
import 'package:goapp/features/help_support/domain/usecases/get_earnings_help_faqs_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_detail_cubit.dart';

class _FakeEarningsHelpRepo implements EarningsHelpRepository {
  @override
  Future<List<HelpArticleLink>> getEarningsHelpLinks() async {
    return const <HelpArticleLink>[];
  }

  @override
  Future<List<HelpFaqItem>> getEarningsHelpFaqs({required String linkId}) async {
    if (linkId == 'learn_about_earnings') {
      return const <HelpFaqItem>[
        HelpFaqItem(title: 'What is the rate card?'),
      ];
    }
    if (linkId == 'learn_about_incentives') {
      return const <HelpFaqItem>[
        HelpFaqItem(title: 'What are incentives?'),
      ];
    }
    return const <HelpFaqItem>[];
  }

  @override
  Future<HelpArticleContent?> getEarningsHelpArticle({
    required String linkId,
    required String faqTitle,
  }) async {
    return null;
  }
}

void main() {
  group('EarningsHelpDetailCubit', () {
    test('init loads FAQ items for linkId', () async {
      final repo = _FakeEarningsHelpRepo();
      final cubit = EarningsHelpDetailCubit(
        getFaqs: GetEarningsHelpFaqsUseCase(repo),
        linkId: 'learn_about_earnings',
      );

      await cubit.init();

      expect(cubit.state.items, isNotEmpty);
      expect(cubit.state.items.first.title, 'What is the rate card?');
      await cubit.close();
    });

    test('init supports incentives faq', () async {
      final repo = _FakeEarningsHelpRepo();
      final cubit = EarningsHelpDetailCubit(
        getFaqs: GetEarningsHelpFaqsUseCase(repo),
        linkId: 'learn_about_incentives',
      );

      await cubit.init();

      expect(cubit.state.items.first.title, 'What are incentives?');
      await cubit.close();
    });
  });
}
