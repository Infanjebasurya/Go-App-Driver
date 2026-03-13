import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/help_support/domain/entities/support_chat_message.dart';
import 'package:goapp/features/help_support/domain/repositories/support_chat_repository.dart';
import 'package:goapp/features/help_support/domain/usecases/get_support_chat_transcript_usecase.dart';
import 'package:goapp/features/help_support/domain/usecases/submit_support_chat_feedback_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_state.dart';

class _FakeSupportChatRepo implements SupportChatRepository {
  List<SupportChatMessage> transcript = const <SupportChatMessage>[
    SupportChatMessage(
      sender: SupportChatSender.support,
      text: 'Hello',
      timeLabel: '12:05 PM',
    ),
  ];

  int? lastRating;
  bool? lastResolved;

  @override
  Future<List<SupportChatMessage>> getInitialTranscript() async => transcript;

  @override
  Future<void> submitFeedback({required int rating, required bool? resolved}) async {
    lastRating = rating;
    lastResolved = resolved;
  }
}

void main() {
  group('SupportChatCubit', () {
    late _FakeSupportChatRepo repo;
    late SupportChatCubit cubit;

    setUp(() {
      repo = _FakeSupportChatRepo();
      cubit = SupportChatCubit(
        getTranscript: GetSupportChatTranscriptUseCase(repo),
        submitFeedback: SubmitSupportChatFeedbackUseCase(repo),
        feedbackDelay: Duration.zero,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('init loads transcript and shows quick actions', () async {
      await cubit.init();
      expect(cubit.state.messages, isNotEmpty);
      expect(cubit.state.showQuickActions, isTrue);
      expect(cubit.state.showFeedback, isFalse);
    });

    test('sendText appends user message and hides quick actions', () async {
      await cubit.init();
      await cubit.sendText('Hi');
      expect(cubit.state.showQuickActions, isFalse);
      expect(cubit.state.messages.last.sender, SupportChatSender.user);
      expect(cubit.state.messages.last.text, 'Hi');
    });

    test('sendText yes ends conversation and shows feedback', () async {
      await cubit.init();
      await cubit.sendText('Yes');
      expect(cubit.state.resolved, isTrue);
      expect(cubit.state.showFeedback, isTrue);
    });

    test('submitFeedback triggers navigation action', () async {
      await cubit.init();
      await cubit.sendText('Yes');
      cubit.setRating(5);
      await cubit.submitFeedback();
      expect(repo.lastRating, 5);
      expect(repo.lastResolved, isTrue);
      expect(cubit.state.navAction, SupportChatNavAction.backToExplore);
    });
  });
}

