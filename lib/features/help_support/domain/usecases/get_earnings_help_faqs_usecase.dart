import 'package:goapp/features/help_support/domain/entities/help_faq_item.dart';
import 'package:goapp/features/help_support/domain/repositories/earnings_help_repository.dart';

class GetEarningsHelpFaqsUseCase {
  const GetEarningsHelpFaqsUseCase(this._repo);

  final EarningsHelpRepository _repo;

  Future<List<HelpFaqItem>> call({required String linkId}) {
    return _repo.getEarningsHelpFaqs(linkId: linkId);
  }
}
