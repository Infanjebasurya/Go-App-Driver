import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/domain/entities/support_chat_message.dart';
import 'package:goapp/features/help_support/domain/usecases/get_support_chat_transcript_usecase.dart';
import 'package:goapp/features/help_support/domain/usecases/submit_support_chat_feedback_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_state.dart';

class SupportChatCubit extends Cubit<SupportChatState> {
  SupportChatCubit({
    required GetSupportChatTranscriptUseCase getTranscript,
    required SubmitSupportChatFeedbackUseCase submitFeedback,
    Duration feedbackDelay = const Duration(milliseconds: 600),
  })  : _getTranscript = getTranscript,
        _submitFeedback = submitFeedback,
        _feedbackDelay = feedbackDelay,
        super(SupportChatState.initial());

  final GetSupportChatTranscriptUseCase _getTranscript;
  final SubmitSupportChatFeedbackUseCase _submitFeedback;
  final Duration _feedbackDelay;

  Future<void> init() async {
    final transcript = await _getTranscript();
    emit(
      state.copyWith(
        messages: transcript,
        showQuickActions: true,
        showFeedback: false,
        navAction: null,
      ),
    );
  }

  void setRating(int rating) {
    final int clamped = rating.clamp(1, 5);
    emit(state.copyWith(rating: clamped, navAction: null));
  }

  Future<void> sendText(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;

    emit(
      state.copyWith(
        messages: <SupportChatMessage>[
          ...state.messages,
          SupportChatMessage(
            sender: SupportChatSender.user,
            text: trimmed,
            timeLabel: '12:05 PM',
          ),
        ],
        showQuickActions: false,
        navAction: null,
      ),
    );

    final String normalized = trimmed.toLowerCase();
    if (normalized == 'yes') {
      await _endConversation(resolved: true);
    } else if (normalized == 'no') {
      await _endConversation(resolved: false);
    }
  }

  Future<void> sendQuickAction(String value) async {
    await sendText(value);
  }

  Future<void> _endConversation({required bool resolved}) async {
    if (state.showFeedback) return;
    emit(state.copyWith(resolved: resolved, navAction: null));
    await Future<void>.delayed(_feedbackDelay);
    emit(state.copyWith(showFeedback: true, navAction: null));
  }

  Future<void> submitFeedback() async {
    await _submitFeedback(rating: state.rating, resolved: state.resolved);
    emit(state.copyWith(navAction: SupportChatNavAction.backToExplore));
  }

  void consumeNavAction() {
    if (state.navAction == null) return;
    emit(state.copyWith(navAction: null));
  }
}

