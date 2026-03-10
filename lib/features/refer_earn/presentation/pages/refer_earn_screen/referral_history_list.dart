import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/referral.dart';

class ReferralHistoryList extends StatelessWidget {
  const ReferralHistoryList({
    super.key,
    required this.people,
    required this.label,
    required this.subLabel,
  });

  final List<ReferralPerson> people;
  final String label;
  final String subLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReferralSummaryBanner(
          count: people.length,
          label: label,
          subLabel: subLabel,
          icon: Icons.pending_actions,
        ),
        const SizedBox(height: 12),
        ...people.map((p) => ReferralPersonCard(person: p)),
      ],
    );
  }
}

class EarningsCard extends StatelessWidget {
  const EarningsCard({super.key, required this.earnings, required this.label});

  final int earnings;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceFDF8,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.payments_sharp,
              color: AuthUiColors.brandGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutralAAA,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                '₹$earnings',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReferralSummaryBanner extends StatelessWidget {
  const ReferralSummaryBanner({
    super.key,
    required this.count,
    required this.label,
    required this.subLabel,
    required this.icon,
  });

  final int count;
  final String label;
  final String subLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: AppColors.black, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count $label',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutralAAA,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReferralPersonCard extends StatelessWidget {
  const ReferralPersonCard({super.key, required this.person});

  final ReferralPerson person;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    person.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.headingDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (person.rewardCredited == true)
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.gold,
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Reward Credited',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        person.sentAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (person.completedDate != null)
                      Text(
                        'COMPLETED ON ${person.completedDate}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutralAAA,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${person.estimatedReward}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: person.status == ReferralStatus.completed
                          ? AuthUiColors.brandGreen
                          : AppColors.headingDark,
                    ),
                  ),
                  Text(
                    person.status == ReferralStatus.completed
                        ? 'PAID OUT'
                        : 'EST. REWARD',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralAAA,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (person.status == ReferralStatus.pending &&
              person.ridesCompleted != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${person.ridesCompleted}/${person.totalRidesRequired} rides completed',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.neutral555,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(person.progressPercent * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.neutral555,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: person.progressPercent,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceF0,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (person.status == ReferralStatus.pending &&
              (person.ridesCompleted == null || person.ridesCompleted == 0)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_moon_outlined,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Joined GoApp',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingDark,
                        ),
                      ),
                      Text(
                        'Documents under review',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutralAAA,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
