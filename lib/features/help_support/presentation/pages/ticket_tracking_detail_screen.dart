import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';

class TicketTrackingDetailScreen extends StatelessWidget {
  const TicketTrackingDetailScreen({super.key, required this.model});

  final TicketTrackingDetailModel model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textBody),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Tickets Tracking', style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Text(
            model.issueType.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          _TicketSummaryCard(model: model),
          const SizedBox(height: 16),
          _TimelineCard(model: model),
          const SizedBox(height: 14),
          const Text(
            'Issue not resolving? Our team is available 24/7.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TicketSummaryCard extends StatelessWidget {
  const _TicketSummaryCard({required this.model});

  final TicketTrackingDetailModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'TICKET ID',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              _StatusChip(
                label: model.statusLabel,
                background: model.statusPillColor,
                text: model.statusTextColor,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '#${model.ticketId}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  model.rideId,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                model.issueType.toLowerCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${model.message}"',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _RideCard(model: model),
        ],
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.model});

  final TicketTrackingDetailModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
        color: AppColors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSoft),
              color: AppColors.white,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.rideTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBody,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  model.rideSubtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              model.amountLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.model});

  final TicketTrackingDetailModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UPDATE TIMELINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          _TimelineRow(
            icon: Icons.check_circle,
            iconColor: AppColors.emerald,
            title: 'Ticket Raised',
            subtitle: model.timelineRaised,
            showLine: true,
          ),
          _TimelineRow(
            icon: Icons.support_agent_outlined,
            iconColor: AppColors.emerald,
            title: 'Under Review',
            subtitle: 'Support team is currently looking into the issue.',
            showLine: true,
          ),
          _TimelineRow(
            icon: Icons.circle_outlined,
            iconColor: AppColors.neutralCCC,
            title: 'Resolved',
            subtitle: model.timelineResolved,
            showLine: false,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.showLine,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: iconColor == AppColors.neutralCCC
                            ? AppColors.surfaceF5
                            : AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 14,
                        color: iconColor == AppColors.neutralCCC
                            ? AppColors.neutral666
                            : AppColors.white,
                      ),
                    ),
                    if (showLine)
                      Container(
                        width: 2,
                        height: 34,
                        color: AppColors.borderSoft,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBody,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.text,
  });

  final String label;
  final Color background;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class TicketTrackingDetailModel {
  const TicketTrackingDetailModel({
    required this.issueType,
    required this.ticketId,
    required this.statusLabel,
    required this.statusPillColor,
    required this.statusTextColor,
    required this.rideId,
    required this.message,
    required this.rideTitle,
    required this.rideSubtitle,
    required this.amountLabel,
    required this.timelineRaised,
    required this.timelineResolved,
  });

  final String issueType;
  final String ticketId;
  final String statusLabel;
  final Color statusPillColor;
  final Color statusTextColor;
  final String rideId;
  final String message;
  final String rideTitle;
  final String rideSubtitle;
  final String amountLabel;
  final String timelineRaised;
  final String timelineResolved;

  factory TicketTrackingDetailModel.paymentIssueExample({
    String statusLabel = 'OPEN',
    Color statusPillColor = AppColors.hex3325C59A,
    Color statusTextColor = AppColors.hexFF0EA271,
  }) {
    return TicketTrackingDetailModel(
      issueType: 'Payment issue',
      ticketId: '98231',
      statusLabel: statusLabel,
      statusPillColor: statusPillColor,
      statusTextColor: statusTextColor,
      rideId: 'RIDE123456',
      message: 'The Rider to rude and he not pay full amount.',
      rideTitle: 'Ride to Arumbakkam',
      rideSubtitle: '12 Jan, 10:15 AM',
      amountLabel: '₹62',
      timelineRaised: '24 Feb, 2026 • 10:35 AM',
      timelineResolved: 'Estimated by 2:00 PM today',
    );
  }
}
