import 'package:goapp/features/help_support/domain/entities/support_chat_message.dart';

abstract interface class SupportChatRepository {
  Future<List<SupportChatMessage>> getInitialTranscript();

  Future<void> submitFeedback({required int rating, required bool? resolved});
}
