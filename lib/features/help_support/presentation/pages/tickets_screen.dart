import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/domain/entities/help_entities.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class TicketsScreen extends StatelessWidget {
  final List<SupportTicket> tickets;

  const TicketsScreen({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Make Complaint'),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'RECENT SUPPORT TICKETS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...tickets.map((t) => _TicketCard(ticket: t)),
        ],
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _StatusBadge(status: ticket.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case TicketStatus.resolved:
        bg = AppColors.successSoft;
        fg = AppColors.greenStrong;
        label = 'RESOLVED';
        break;
      case TicketStatus.closed:
        bg = AppColors.graySoft;
        fg = AppColors.textSecondary;
        label = 'CLOSED';
        break;
      default:
        bg = AppColors.warningSoft;
        fg = AppColors.warningText;
        label = 'OPEN';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
