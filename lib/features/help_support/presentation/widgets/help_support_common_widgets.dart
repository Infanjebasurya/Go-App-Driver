import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/persistent_text_controller.dart';
import 'package:goapp/core/widgets/shadow_button.dart';
import 'package:goapp/features/help_support/presentation/pages/ticket_tracking_screen.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';

class HelpSupportAppBarBottomDivider extends StatelessWidget
    implements PreferredSizeWidget {
  const HelpSupportAppBarBottomDivider({super.key, this.alpha = 0.55});

  final double alpha;

  @override
  Size get preferredSize => const Size.fromHeight(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.borderSoft.withValues(alpha: alpha),
    );
  }
}

class HelpSupportThinDivider extends StatelessWidget {
  const HelpSupportThinDivider({
    super.key,
    this.indent = 16,
    this.endIndent = 16,
    this.alpha = 0.45,
  });

  final double indent;
  final double endIndent;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderSoft.withValues(alpha: alpha),
      indent: indent,
      endIndent: endIndent,
    );
  }
}

class HelpSupportChevronListItem extends StatelessWidget {
  const HelpSupportChevronListItem({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.titleStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textBody,
    ),
    this.chevronSize = 18,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final TextStyle titleStyle;
  final double chevronSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 14)],
              Expanded(child: Text(title, style: titleStyle)),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: chevronSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpSupportChevronOnlyListItem extends StatelessWidget {
  const HelpSupportChevronOnlyListItem({
    super.key,
    required this.title,
    required this.chevronKey,
    required this.onChevronTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.titleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textBody,
    ),
    this.chevronSize = 20,
  });

  final String title;
  final String chevronKey;
  final VoidCallback onChevronTap;
  final EdgeInsetsGeometry padding;
  final TextStyle titleStyle;
  final double chevronSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: null,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              Expanded(child: Text(title, style: titleStyle)),
              InkWell(
                key: Key(chevronKey),
                onTap: onChevronTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: chevronSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const HelpSearchBar({super.key, required this.onChanged});

  @override
  State<HelpSearchBar> createState() => _HelpSearchBarState();
}

class _HelpSearchBarState extends State<HelpSearchBar> {
  late final PersistentTextController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTextController(storageKey: 'help_support.search');
    _controller.attach();
    if (_controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged(_controller.text);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Search for help topics...',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.borderSoft),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.borderSoft),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class HelpLiveChatBar extends StatelessWidget {
  const HelpLiveChatBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: ShadowButton(
        onPressed: () {},
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: const Text('START LIVE CHAT'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class HelpTicketTrackingFooter extends StatelessWidget {
  const HelpTicketTrackingFooter({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    void openTicketTracking() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: HelpSupportRoutes.ticketTracking),
          builder: (_) => const TicketTrackingScreen(),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 44,
              child: OutlinedButton(
                onPressed: onPressed ?? openTicketTracking,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textBody,
                  side: const BorderSide(color: AppColors.borderSoft),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Ticket Tracking'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Our support team typically responds within 15 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpCustomerCareSupportChatBar extends StatelessWidget {
  const HelpCustomerCareSupportChatBar({
    super.key,
    this.onCustomerCare,
    required this.onSupportChat,
  });

  final VoidCallback? onCustomerCare;
  final VoidCallback onSupportChat;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onCustomerCare ?? () {},
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Customer Care'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.strokeLight,
                    foregroundColor: AppColors.textSecondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onSupportChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Support Chat'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpRoundedListSection extends StatelessWidget {
  const HelpRoundedListSection({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.borderRadius = 12,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: contentPadding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Column(
            children: [
              for (int i = 0; i < itemCount; i++) ...[
                itemBuilder(context, i),
                if (i != itemCount - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderSoft.withValues(alpha: 0.45),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
