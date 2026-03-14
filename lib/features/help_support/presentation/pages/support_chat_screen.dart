import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/domain/entities/support_chat_message.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_state.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Pure UI trigger: load initial transcript.
    context.read<SupportChatCubit>().init();
  }

  @override
  void dispose() {
    _composer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _goBackToExplore() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) {
        final String? name = route.settings.name;
        return name == HelpSupportRoutes.explore || route.isFirst;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupportChatCubit, SupportChatState>(
      listenWhen: (prev, next) {
        return prev.messages.length != next.messages.length ||
            prev.showFeedback != next.showFeedback ||
            prev.navAction != next.navAction;
      },
      listener: (context, state) {
        if (state.messages.isNotEmpty) {
          _scrollToBottom();
        }

        if (state.navAction == SupportChatNavAction.backToExplore) {
          context.read<SupportChatCubit>().consumeNavAction();
          _goBackToExplore();
        }
      },
      builder: (context, state) {
        final cubit = context.read<SupportChatCubit>();
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            titleWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emerald.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.headset_mic_outlined,
                    size: 18,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support Chat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: AppColors.white,
            elevation: 0,
            bottom: const HelpSupportAppBarBottomDivider(),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.strokeLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final message in state.messages)
                      _MessageBubble(message: message),
                    if (state.showQuickActions) ...[
                      const SizedBox(height: 22),
                      const Text(
                        'QUICK ACTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _QuickActionButton(
                        label: 'Yes',
                        onPressed: () => cubit.sendQuickAction('Yes'),
                      ),
                      const SizedBox(height: 10),
                      _QuickActionButton(
                        label: 'No',
                        onPressed: () => cubit.sendQuickAction('No'),
                      ),
                    ],
                    if (state.showFeedback) ...[
                      const SizedBox(height: 18),
                      Container(
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'This Conversation Has Ended',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _MessageBubble(
                        message: SupportChatMessage(
                          sender: SupportChatSender.support,
                          text:
                              'Please fell free to reach out to\n'
                              'us if you have any other\n'
                              'concerns. Thank you. Have a\n'
                              'nice day 🥰',
                          timeLabel: '12:05 PM',
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Rate Our Support',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your feedback will help our service better',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final int value = i + 1;
                          final bool filled = value <= state.rating;
                          return IconButton(
                            onPressed: () => cubit.setRating(value),
                            icon: Icon(
                              Icons.star,
                              color: filled
                                  ? const Color(0xFFFBBF24)
                                  : AppColors.silver,
                              size: 26,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => cubit.submitFeedback(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Submit Feedback'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!state.showFeedback)
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    color: AppColors.white,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                            border: Border.all(color: AppColors.borderSoft),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppColors.borderSoft),
                            ),
                            padding: const EdgeInsets.only(left: 14, right: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _composer,
                                    decoration: const InputDecoration(
                                      hintText: 'Type a message...',
                                      hintStyle: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.transparent,
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (value) async {
                                      _composer.clear();
                                      await cubit.sendText(value);
                                    },
                                  ),
                                ),
                                const Icon(
                                  Icons.mic_none_rounded,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final String text = _composer.text;
                                      _composer.clear();
                                      await cubit.sendText(text);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: AppColors.emerald,
                                      foregroundColor: AppColors.white,
                                      shape: const CircleBorder(),
                                      elevation: 0,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SupportChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.sender == SupportChatSender.user;
    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'You',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.done_all,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message.timeLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emerald.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              size: 18,
              color: AppColors.emerald,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.strokeLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: AppColors.textBody,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.timeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.emerald.withValues(alpha: 0.35)),
          foregroundColor: AppColors.emerald,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}
