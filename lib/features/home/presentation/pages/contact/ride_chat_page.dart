import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/home/presentation/pages/contact/ride_call_page.dart';
import 'package:goapp/features/home/presentation/widgets/home_no_device_back.dart';
import 'package:goapp/features/home/presentation/widgets/quick_message_chip.dart';
import 'package:goapp/features/home/presentation/widgets/rider_contact_header.dart';

class RideChatPage extends StatefulWidget {
  const RideChatPage({super.key});

  @override
  State<RideChatPage> createState() => _RideChatPageState();
}

class _RideChatPageState extends State<RideChatPage> {
  static const List<String> _quickReplies = <String>[
    "I'm here",
    'At the entrance',
    'Coming now',
  ];

  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _applyQuickReply(String text) {
    _messageController
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  Widget build(BuildContext context) {
    return HomeNoDeviceBack(
      child: Scaffold(
        backgroundColor: AppColors.surfaceF5,
        body: Column(
          children: <Widget>[
            RiderContactHeader(
              onBackTap: () => Navigator.of(context).pop(),
              onActionTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const RideCallPage()),
                );
              },
              actionIcon: Icons.call,
            ),
            Expanded(child: Container(color: AppColors.neutralDDD)),
            Container(
              color: AppColors.surfaceF5,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickReplies
                            .map(
                              (reply) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: QuickMessageChip(
                                  label: reply,
                                  onTap: () => _applyQuickReply(reply),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        _RoundIconButton(
                          icon: Icons.add,
                          onTap: () {},
                          iconColor: AppColors.neutral666,
                          backgroundColor: AppColors.surfaceF0,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceF0,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.transparent,
                                      border: InputBorder.none,
                                      hintText: 'Type a message...',
                                      hintStyle: TextStyle(
                                        color: AppColors.neutral888,
                                        fontSize: 14 / 1.08,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.mic,
                                  color: AppColors.neutralAAA,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RoundIconButton(
                          icon: Icons.arrow_upward,
                          onTap: () {},
                          iconColor: AppColors.white,
                          backgroundColor: AppColors.headingNavy,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
