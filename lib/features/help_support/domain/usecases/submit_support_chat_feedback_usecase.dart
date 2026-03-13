import 'package:goapp/features/help_support/domain/repositories/support_chat_repository.dart';

class SubmitSupportChatFeedbackUseCase {
  const SubmitSupportChatFeedbackUseCase(this._repo);

  final SupportChatRepository _repo;

  Future<void> call({required int rating, required bool? resolved}) {
    return _repo.submitFeedback(rating: rating, resolved: resolved);
  }
}

