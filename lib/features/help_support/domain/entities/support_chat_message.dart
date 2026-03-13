enum SupportChatSender { support, user }

class SupportChatMessage {
  const SupportChatMessage({
    required this.sender,
    required this.text,
    required this.timeLabel,
  });

  final SupportChatSender sender;
  final String text;
  final String timeLabel;
}

