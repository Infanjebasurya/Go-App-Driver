import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/refer_earn/presentation/cubit/referral_cubit.dart';
import 'package:goapp/features/refer_earn/presentation/cubit/referral_state.dart';
import 'package:goapp/features/refer_earn/domain/entities/referral.dart';
import 'package:goapp/features/refer_earn/presentation/widget/key_star_badge.dart';

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
            body: Center(
              child: CircularProgressIndicator(color: AppColors.emerald),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Grow the Elite\nCircle',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            const KeyWithStarBadge(size: 240),
            const SizedBox(height: 12),
            _EarningsCard(
              earnings: state.totalEarnings,
              label: 'TOTAL EARNINGS',
            ),
            const SizedBox(height: 18),
            const Text(
              'ACTIVE CAMPAIGNS',
              style: TextStyle(
                color: AppColors.neutral888,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            ...state.campaigns.map(
              (c) => _CampaignRow(
                campaign: c,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _CampaignDetailScreen(
                      campaign: c,
                      pending: state.pending.length,
                      completed: state.completed.length,
                      state: state,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _ReferralCodeBox(
              code: state.referralCode,
              copied: state.codeCopied,
              onCopy: () => context.read<ReferralCubit>().copyCode(),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: _InviteButton(
        onTap: () {
          Clipboard.setData(ClipboardData(text: state.referralCode));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code copied. Share with riders.')),
          );
        },
      ),
    );
  }
}

class _CampaignDetailScreen extends StatelessWidget {
  const _CampaignDetailScreen({
    required this.campaign,
    required this.pending,
    required this.completed,
    required this.state,
  });

  final ReferralCampaign campaign;
  final int pending;
  final int completed;
  final ReferralLoaded state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, '${campaign.label} Program'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _EarningsCard(
              earnings: campaign.reward,
              label: 'REWARD PER REFERRAL',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: 'COMPLETED',
                    count: completed,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _ReferralListScreen(
                          title: 'Completed',
                          list: state.completed,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    title: 'PENDING',
                    count: pending,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _ReferralListScreen(
                          title: 'Pending',
                          list: state.pending,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralListScreen extends StatelessWidget {
  const _ReferralListScreen({required this.title, required this.list});

  final String title;
  final List<ReferralPerson> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, title),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) => _ReferralPersonCard(person: list[i]),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: AppColors.white,
    title: Text(title, style: const TextStyle(color: AppColors.headingDark)),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.headingDark),
      onPressed: () => Navigator.of(context).pop(),
    ),
  );
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.earnings, required this.label});

  final int earnings;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.neutralAAA)),
          const SizedBox(height: 4),
          Text(
            'Rs $earnings',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CampaignRow extends StatelessWidget {
  const _CampaignRow({required this.campaign, required this.onTap});

  final ReferralCampaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: const Icon(Icons.campaign_outlined),
      title: Text(campaign.label),
      trailing: Text('Rs ${campaign.reward}'),
      onTap: onTap,
    );
  }
}

class _ReferralCodeBox extends StatelessWidget {
  const _ReferralCodeBox({
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  final String code;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.strokeLight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(code, style: const TextStyle(fontSize: 18, letterSpacing: 1)),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              onCopy();
            },
            icon: Icon(copied ? Icons.check : Icons.copy, size: 16),
            label: Text(copied ? 'Copied!' : 'Copy'),
          ),
        ],
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text('Invite Riders'),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.count,
    required this.onTap,
  });

  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.strokeLight),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(title, style: const TextStyle(color: AppColors.neutralAAA)),
          ],
        ),
      ),
    );
  }
}

class _ReferralPersonCard extends StatelessWidget {
  const _ReferralPersonCard({required this.person});

  final ReferralPerson person;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strokeLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.headingDark,
                child: Text(
                  person.initials,
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      person.sentAgo,
                      style: const TextStyle(
                        color: AppColors.neutral888,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs ${person.estimatedReward}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: person.status == ReferralStatus.completed
                      ? AppColors.emerald
                      : AppColors.headingDark,
                ),
              ),
            ],
          ),
          if (person.status == ReferralStatus.pending &&
              person.ridesCompleted != null) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: person.progressPercent.clamp(0, 1),
              minHeight: 6,
              backgroundColor: AppColors.surfaceF0,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ],
        ],
      ),
    );
  }
}
