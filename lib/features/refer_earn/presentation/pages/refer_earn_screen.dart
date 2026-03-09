import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';

import '../../domain/entities/referral.dart';
import '../cubit/referral_cubit.dart';
import '../cubit/referral_state.dart';
import '../widget/key_star_badge.dart';
import 'refer_earn_screen/refer_banner.dart';
import 'refer_earn_screen/referral_components.dart';
import 'refer_earn_screen/referral_code_widget.dart';
import 'refer_earn_screen/referral_history_list.dart';
import 'refer_earn_screen/referral_rules_section.dart';

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReferralCubit(),
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
            backgroundColor: Colors.white,
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
      backgroundColor: Colors.white,
      appBar: buildReferEarnAppBar(context, 'Refer & Earn'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
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
            const KeyWithStarBadge(size: 260),
            ReferBanner(totalEarnings: state.totalEarnings),
            const SizedBox(height: 22),
            const ReferralSectionLabel(text: 'ACTIVE CAMPAIGNS'),
            const SizedBox(height: 10),
            ...state.campaigns.map(
              (c) => CampaignRow(
                campaign: c,
                onTap: () => _openCampaignDetail(context, c),
              ),
            ),
            const SizedBox(height: 22),
            const ReferralSectionLabel(text: 'YOUR REFERRAL CODE IS'),
            const SizedBox(height: 10),
            ReferralCodeWidget(
              code: state.referralCode,
              copied: state.codeCopied,
              onCopy: () => context.read<ReferralCubit>().copyCode(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: InviteButton(
        onTap: () => _openCampaignDetail(context, state.campaigns.first),
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
      backgroundColor: Colors.white,
      appBar: buildReferEarnAppBar(context, 'Bike Referral Program'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Your Referrals',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingDark,
                  ),
                ),
                Text(
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                        child: StatCol(
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
                        child: StatCol(
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
            const ReferralRulesSection(),
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
      bottomNavigationBar: const InviteButton(onTap: _noop),
    );
  }
}

class ReferralPendingScreen extends StatelessWidget {
  const ReferralPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReferralCubit(),
      child: BlocBuilder<ReferralCubit, ReferralState>(
        builder: (context, state) {
          if (state is! ReferralLoaded) {
            return const Scaffold(
              backgroundColor: Colors.white,
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
      create: (_) => ReferralCubit(),
      child: BlocBuilder<ReferralCubit, ReferralState>(
        builder: (context, state) {
          if (state is! ReferralLoaded) {
            return const Scaffold(
              backgroundColor: Colors.white,
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
      backgroundColor: Colors.white,
      appBar: buildReferEarnAppBar(context, 'Completed'),
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

void _noop() {}
