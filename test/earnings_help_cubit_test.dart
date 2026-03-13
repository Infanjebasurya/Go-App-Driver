import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_content.dart';
import 'package:goapp/features/help_support/domain/entities/help_faq_item.dart';
import 'package:goapp/features/help_support/domain/repositories/earnings_help_repository.dart';
import 'package:goapp/features/help_support/domain/usecases/get_earnings_help_links_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_cubit.dart';

class _FakeEarningsHelpRepo implements EarningsHelpRepository {
  @override
  Future<List<HelpArticleLink>> getEarningsHelpLinks() async {
    return const <HelpArticleLink>[
      HelpArticleLink(
        id: 'learn_about_earnings',
        title: 'Learn about earnings',
      ),
    ];
  }

  @override
  Future<List<HelpFaqItem>> getEarningsHelpFaqs({
    required String linkId,
  }) async {
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
  group('EarningsHelpCubit', () {
    test('init loads earnings help links', () async {
      final cubit = EarningsHelpCubit(
        getLinks: GetEarningsHelpLinksUseCase(_FakeEarningsHelpRepo()),
      );

      await cubit.init();

      expect(cubit.state.links, isNotEmpty);
      expect(cubit.state.links.first.title, 'Learn about earnings');
      await cubit.close();
    });
  });
}
