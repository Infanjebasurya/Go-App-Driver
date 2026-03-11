import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/features/refer_earn/domain/entities/referral.dart';
import 'package:goapp/features/refer_earn/presentation/cubit/referral_cubit.dart';
import 'package:goapp/features/refer_earn/presentation/cubit/total_earning_cubit.dart';

class TotalEarningScreen extends StatelessWidget {
  const TotalEarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TotalEarningCubit(referralCubit: context.read<ReferralCubit>()),
      child: const _TotalEarningView(),
    );
  }
}

class _TotalEarningView extends StatelessWidget {
  const _TotalEarningView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.headingDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Total Earning',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.headingDark,
          ),
        ),
      ),
      body: BlocBuilder<TotalEarningCubit, TotalEarningState>(
        builder: (context, state) {
          if (state is TotalEarningLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AuthUiColors.brandGreen),
            );
          }
          if (state is TotalEarningFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          final TotalEarningLoaded s = state as TotalEarningLoaded;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TotalCard(amount: s.totalEarnings),
                const SizedBox(height: 18),
                const Text(
                  'RECENT ACTIVITY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralAAA,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                if (s.activities.isEmpty)
                  const _EmptyActivity()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: s.activities.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 18,
                      color: Color(0xFFF1F1F1),
                    ),
                    itemBuilder: (_, i) => _ActivityRow(
                      activity: s.activities[i],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE9FBF3),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AuthUiColors.brandGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL REFERRAL EARNINGS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralAAA,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹ ${_formatInr(amount)}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AuthUiColors.brandGreen,
                    letterSpacing: -0.3,
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

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final TotalEarningActivity activity;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _InitialAvatar(initials: activity.initials),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutralAAA,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(status: activity.status),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+₹${_formatInr(activity.amount)}',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.headingDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              activity.label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralAAA,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final String text = initials.trim().isEmpty ? '?' : initials.trim();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFE6F7EF), Color(0xFFCFF3E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFEAF1EE)),
      ),
      alignment: Alignment.center,
      child: Text(
        text.length > 2 ? text.substring(0, 2).toUpperCase() : text.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AuthUiColors.brandGreen,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ReferralStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color fg) = switch (status) {
      ReferralStatus.completed => (
        'COMPLETED',
        const Color(0xFFE9FBF3),
        const Color(0xFF12A05C),
      ),
      ReferralStatus.joined => (
        'JOINED',
        const Color(0xFFEAF2FF),
        const Color(0xFF2C5BD5),
      ),
      ReferralStatus.pending => (
        'PENDING',
        const Color(0xFFFFF6E5),
        const Color(0xFFB67600),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'No recent activity yet.',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.neutralAAA,
        ),
      ),
    );
  }
}

String _formatInr(int amount) {
  final String s = amount.abs().toString();
  return s.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}
