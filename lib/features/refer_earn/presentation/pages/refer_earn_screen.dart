// ignore_for_file: unused_element

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/widgets/shadow_button.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/core/di/injection.dart';

import '../../domain/entities/referral.dart';
import '../cubit/referral_cubit.dart';
import '../cubit/referral_state.dart';
import '../widget/key_star_badge.dart';
import 'refer_earn_screen/referral_components.dart';
import 'refer_earn_screen/referral_history_list.dart';
import 'invite_friends_screen.dart';
import 'total_earning_screen.dart';

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReferralCubit>(),
      child: const _ReferEarnView(),
    );
  }
}

class _ReferEarnView extends StatelessWidget {
  const _ReferEarnView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReferralCubit, ReferralState>(
      builder: (context, state) {
        if (state is ReferralLoading || state is ReferralInitial) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(color: AuthUiColors.brandGreen),
            ),
          );
        }
        if (state is ReferralLoaded) {
          return _MainReferScreen(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MainReferScreen extends StatelessWidget {
  const _MainReferScreen({required this.state});

  final ReferralLoaded state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context, 'Refer & Earn'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: const Text(
                      'Grow the Elite\nCircle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: AppColors.headingDark,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  KeyWithStarBadge(size: 260),

                  _HeroCard(
                    totalEarnings: state.totalEarnings,
                    onChevronTap: () => _openTotalEarnings(context),
                  ),
                  const SizedBox(height: 22),

                  const _SectionLabel(text: 'ACTIVE CAMPAIGNS'),
                  const SizedBox(height: 10),
                  ...state.campaigns.map(
                    (c) => _CampaignRow(
                      campaign: c,
                      onTap: () => _openCampaignDetail(context, c),
                    ),
                  ),

                  const SizedBox(height: 22),
                  const _SectionLabel(text: 'YOUR REFERRAL CODE IS'),
                  const SizedBox(height: 10),
                  _ReferralCodeBox(
                    code: state.referralCode,
                    copied: state.codeCopied,
                    onCopy: () => context.read<ReferralCubit>().copyCode(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _InviteButton(
        onTap: () => _openInviteFriends(context),
      ),
    );
  }

  void _openInviteFriends(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InviteFriendsScreen(referralCode: state.referralCode),
      ),
    );
  }

  void _openTotalEarnings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ReferralCubit>(),
          child: const TotalEarningScreen(),
        ),
      ),
    );
  }

  void _openCampaignDetail(BuildContext context, ReferralCampaign campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ReferralCubit>(),
          child: _BikeReferralDetailScreen(state: state),
        ),
      ),
    );
  }
}

class _BikeReferralDetailScreen extends StatelessWidget {
  const _BikeReferralDetailScreen({required this.state});

  final ReferralLoaded state;

  @override
  Widget build(BuildContext context) {
    final pending = state.pending.length;
    final completed = state.completed.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context, 'Bike Referral Program'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Earn ₹2,000',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headingDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'For every successful bike\npartner you bring to GoApp',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray.shade500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Referrals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingDark,
                        ),
                      ),
                      const Text(
                        'ACTIVE STATUS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutralAAA,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      //   border: Border.all(color: AppColors.strokeLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ReferralCubit>(),
                                  child: _CompletedView(state: state),
                                ),
                              ),
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: _StatCol(
                                value: '$completed',
                                label: 'COMPLETED',
                                highlighted: completed > 0,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.strokeLight,
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ReferralCubit>(),
                                  child: _PendingView(state: state),
                                ),
                              ),
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: _StatCol(
                                value: '$pending',
                                label: 'PENDING',
                                highlighted: pending > 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'How it Works',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _HowItWorksStep(
                    number: '1',
                    title: 'Share your link',
                    subtitle:
                        'Send your unique invite link to professional\nbike riders in your network.',
                  ),
                  const _HowItWorksStep(
                    number: '2',
                    title: 'Friend joins GoApp',
                    subtitle:
                        'Ensure they complete their registration using\nyour referral code.',
                  ),
                  const _HowItWorksStep(
                    number: '3',
                    title: 'Friend completes 10 rides',
                    subtitle:
                        'Once they hit the milestone, the ₹3,000 reward\nis credited to your wallet.',
                    isLast: true,
                  ),
                  const SizedBox(height: 26),
                  const Center(
                    child: Text(
                      'T&C APPLY',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.neutralAAA,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _InviteButton(onTap: () {}),
    );
  }
}

class ReferralPendingScreen extends StatelessWidget {
  const ReferralPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReferralCubit>(),
      child: BlocBuilder<ReferralCubit, ReferralState>(
        builder: (context, state) {
          if (state is! ReferralLoaded) {
            return const Scaffold(
              backgroundColor: AppColors.white,
              body: Center(
                child: CircularProgressIndicator(color: AuthUiColors.brandGreen),
              ),
            );
          }
          return _PendingView(state: state);
        },
      ),
    );
  }
}

class _PendingView extends StatelessWidget {
  const _PendingView({required this.state});

  final ReferralLoaded state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceF5,
      appBar: buildReferEarnAppBar(context, 'Pending'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            EarningsCard(
              earnings: state.pending.fold<int>(
                0,
                (sum, r) => sum + r.estimatedReward,
              ),
              label: 'TOTAL EARNINGS',
            ),
            const SizedBox(height: 16),
            ReferralHistoryList(
              people: state.pending,
              label: 'Referrals in Progress',
              subLabel: 'KEEP TRACKING YOUR REWARDS',
            ),
          ],
        ),
      ),
    );
  }
}

class ReferralCompletedScreen extends StatelessWidget {
  const ReferralCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReferralCubit>(),
      child: BlocBuilder<ReferralCubit, ReferralState>(
        builder: (context, state) {
          if (state is! ReferralLoaded) {
            return const Scaffold(
              backgroundColor: AppColors.white,
              body: Center(
                child: CircularProgressIndicator(color: AuthUiColors.brandGreen),
              ),
            );
          }
          return _CompletedView(state: state);
        },
      ),
    );
  }
}

class _CompletedView extends StatelessWidget {
  const _CompletedView({required this.state});

  final ReferralLoaded state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context, 'Completed'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            EarningsCard(
              earnings: state.completed.fold<int>(
                0,
                (sum, r) => sum + r.estimatedReward,
              ),
              label: 'TOTAL EARNINGS',
            ),
            const SizedBox(height: 24),
            ReferralHistoryList(
              people: state.completed,
              label: 'Referrals in Completed',
              subLabel: 'GETTING YOUR REWARDS',
            ),
          ],
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
  return AppAppBar(
    backgroundColor: AppColors.white,
    elevation: 0,
    centerTitle: true,
    title: Text(title),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: AppColors.strokeLight, height: 1),
    ),
  );
}

class _HeroCard extends StatelessWidget {
  final int totalEarnings;
  final VoidCallback onChevronTap;
  const _HeroCard({required this.totalEarnings, required this.onChevronTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceFDF8,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.payments_sharp,
                  color: AuthUiColors.brandGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL EARNINGS',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralAAA,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    '₹${totalEarnings.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.headingDark,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: onChevronTap,
                icon: const Icon(Icons.chevron_right, color: AppColors.gray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampaignRow extends StatelessWidget {
  final ReferralCampaign campaign;
  final VoidCallback onTap;
  const _CampaignRow({required this.campaign, required this.onTap});

  IconData get _icon {
    switch (campaign.type) {
      case CampaignType.bike:
        return Icons.two_wheeler;
      case CampaignType.auto:
        return Icons.electric_rickshaw;
      case CampaignType.cab:
        return Icons.local_taxi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceF5,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: AppColors.neutral444, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                campaign.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.headingDark,
                ),
              ),
            ),
            Text(
              '= ₹${campaign.reward}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: AppColors.headingDark,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.gray, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ReferralCodeBox extends StatelessWidget {
  final String code;
  final bool copied;
  final VoidCallback onCopy;
  const _ReferralCodeBox({
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.strokeLight),
      ),
      child: Row(
        children: [
          Text(
            code,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AppColors.headingDark,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              onCopy();
            },
            icon: Icon(
              copied ? Icons.check : Icons.copy,
              size: 16,
              color: AuthUiColors.brandGreen,
            ),
            label: Text(
              copied ? 'Copied!' : 'Copy',
              style: const TextStyle(
                color: AuthUiColors.brandGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral888,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _InviteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: SizedBox(
        height: 54,
        child: ShadowButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AuthUiColors.brandGreen,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Text(
            'Invite Riders',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          label: const Icon(Icons.arrow_forward, size: 18),
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final int earnings;
  final String label;
  const _EarningsCard({required this.earnings, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
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

class _ReferralSummaryBanner extends StatelessWidget {
  final int count;
  final String label;
  final String subLabel;
  final IconData icon;
  const _ReferralSummaryBanner({
    required this.count,
    required this.label,
    required this.subLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
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

class _ReferralPersonCard extends StatelessWidget {
  final ReferralPerson person;
  const _ReferralPersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
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
                  color: AppColors.hexFF2C2C2C,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    person.initials,
                    style: const TextStyle(
                      color: AppColors.white,
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
                              color: AppColors.gray,
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
                          color: AppColors.gray,
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
              (person.ridesCompleted == null ||
                  person.ridesCompleted == 0)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.hexFFF1F5F9,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_moon_outlined,
                    color: AppColors.hexFF3B82F6,
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

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isLast;
  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutralDDD, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral888,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(width: 1.5, height: 44, color: AppColors.strokeLight),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.headingDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral888,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: isLast ? 0 : 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCol extends StatelessWidget {
  final String value;
  final String label;
  final bool highlighted;
  const _StatCol({
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: highlighted ? AppColors.headingDark : AppColors.headingDark,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralAAA,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}







