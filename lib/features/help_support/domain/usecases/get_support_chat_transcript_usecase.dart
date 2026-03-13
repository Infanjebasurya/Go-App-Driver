import 'package:goapp/features/help_support/domain/entities/support_chat_message.dart';
import 'package:goapp/features/help_support/domain/repositories/support_chat_repository.dart';

class GetSupportChatTranscriptUseCase {
  const GetSupportChatTranscriptUseCase(this._repo);

  final SupportChatRepository _repo;

  Future<List<SupportChatMessage>> call() => _repo.getInitialTranscript();
}
