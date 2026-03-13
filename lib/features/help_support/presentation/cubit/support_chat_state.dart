import 'package:goapp/features/help_support/domain/entities/support_chat_message.dart';

enum SupportChatNavAction { backToExplore }

class SupportChatState {
  const SupportChatState({
    required this.messages,
    required this.showQuickActions,
    required this.showFeedback,
    required this.rating,
    required this.resolved,
    required this.navAction,
  });

  factory SupportChatState.initial() => const SupportChatState(
    messages: <SupportChatMessage>[],
    showQuickActions: true,
    showFeedback: false,
    rating: 4,
    resolved: null,
    navAction: null,
  );

  final List<SupportChatMessage> messages;
  final bool showQuickActions;
  final bool showFeedback;
  final int rating;
  final bool? resolved;
  final SupportChatNavAction? navAction;

  static const Object _navSentinel = Object();

  SupportChatState copyWith({
    List<SupportChatMessage>? messages,
    bool? showQuickActions,
    bool? showFeedback,
    int? rating,
    bool? resolved,
    Object? navAction = _navSentinel,
  }) {
    return SupportChatState(
      messages: messages ?? this.messages,
      showQuickActions: showQuickActions ?? this.showQuickActions,
      showFeedback: showFeedback ?? this.showFeedback,
      rating: rating ?? this.rating,
      resolved: resolved ?? this.resolved,
      navAction: navAction == _navSentinel
          ? this.navAction
          : navAction as SupportChatNavAction?,
    );
  }
}
