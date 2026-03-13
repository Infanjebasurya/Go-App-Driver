import 'package:goapp/features/help_support/domain/entities/support_chat_message.dart';
import 'package:goapp/features/help_support/domain/repositories/support_chat_repository.dart';

class SupportChatRepositoryMock implements SupportChatRepository {
  const SupportChatRepositoryMock();

  @override
  Future<List<SupportChatMessage>> getInitialTranscript() async {
    return const <SupportChatMessage>[
      SupportChatMessage(
        sender: SupportChatSender.support,
        text: 'Welcome to Goapp Support.\nHow can we assist you?',
        timeLabel: '12:05 PM',
      ),
      SupportChatMessage(
        sender: SupportChatSender.support,
        text:
            'You’re already in a high-\n'
            'demand area. Please wait - you\n'
            'should start receiving orders\n'
            'soon.',
        timeLabel: '12:05 PM',
      ),
      SupportChatMessage(
        sender: SupportChatSender.support,
        text: 'Did we resolve your issue?',
        timeLabel: '12:05 PM',
      ),
    ];
  }

  @override
  Future<void> submitFeedback({
    required int rating,
    required bool? resolved,
  }) async {
    return;
  }
}
