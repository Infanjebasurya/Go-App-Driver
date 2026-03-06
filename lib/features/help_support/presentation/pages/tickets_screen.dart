import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/domain/entities/help_entities.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';

class TicketsScreen extends StatelessWidget {
  final List<SupportTicket> tickets;

  const TicketsScreen({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.textBody,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Recent Support Tickets',style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        itemCount: tickets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _TicketCard(ticket: tickets[index]),
      ),
      bottomNavigationBar: const HelpLiveChatBar(),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ID: #${ticket.id}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              _StatusChip(status: ticket.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ticket.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.description,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.border),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: style.text,
        ),
      ),
    );
  }

  _StatusStyle _statusStyle(TicketStatus status) {
    switch (status) {
      case TicketStatus.resolved:
        return const _StatusStyle(
          label: 'Resolved',
          background: Color(0x1A00A86B),
          border: Color(0x3300A86B),
          text: Color(0xFF00A86B),
        );
      case TicketStatus.closed:
        return const _StatusStyle(
          label: 'Closed',
          background: Color(0xFFF5F5F4),
          border: Color(0xFFE7E5E4),
          text: Color(0xFF78716C),
        );
      case TicketStatus.open:
      case TicketStatus.pending:
        return const _StatusStyle(
          label: 'Open',
          background: Color(0x1AF59E0B),
          border: Color(0x33F59E0B),
          text: Color(0xFFB45309),
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.border,
    required this.text,
  });

  final String label;
  final Color background;
  final Color border;
  final Color text;
}
