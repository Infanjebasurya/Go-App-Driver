import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/di/injection.dart';

import '../cubit/incentives_cubit.dart';
import '../cubit/incentives_state.dart';

class IncentivesPage extends StatelessWidget {
  const IncentivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<IncentivesCubit>(),
      child: const _IncentivesView(),
    );
  }
}

class _IncentivesView extends StatelessWidget {
  const _IncentivesView();

  static const List<String> _weekDays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncentivesCubit, IncentivesState>(
      builder: (context, state) {
        final List<IncentiveTier> tiers = state.tiers.isNotEmpty
            ? state.tiers
            : const <IncentiveTier>[
                IncentiveTier(title: 'Silver Milestone', targetRides: 3, rewardAmount: 50),
                IncentiveTier(title: 'Gold Milestone', targetRides: 5, rewardAmount: 100),
                IncentiveTier(title: 'Platinum Milestone', targetRides: 7, rewardAmount: 150),
              ];
        final int currentRides = state.achievedRides;
        final int activeTierIndex = _activeTierIndex(achievedRides: currentRides, tiers: tiers);
        final int totalTarget = tiers.isEmpty ? 1 : tiers.last.targetRides;
        final double progressFraction = (currentRides / totalTarget).clamp(0, 1);

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            title: const Text('Incentives'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.gray[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    _buildTab(context, state, 'Day'),
                    _buildTab(context, state, 'Week'),
                    _buildTab(context, state, 'Bonus'),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                child: state.selectedTab == 'Day'
                    ? ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: List<Widget>.generate(state.dayOptions.length, (index) {
                          final DateTime day = state.dayOptions[index];
                          return _buildDateItem(
                            context,
                            state,
                            _weekDays[day.weekday - 1],
                            day.day.toString().padLeft(2, '0'),
                            index,
                          );
                        }),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: List<Widget>.generate(state.rangeLabels.length, (index) {
                          return _buildRangeItem(
                            context,
                            state,
                            state.rangeLabels[index],
                            index,
                          );
                        }),
                      ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _sessionTitle(state.selectedTab),
                              style: const TextStyle(
                                color: AppColors.gray,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildActiveQuestCard(
                              tiers: tiers,
                              currentRides: currentRides,
                              activeTierIndex: activeTierIndex,
                              progressFraction: progressFraction,
                              selectedTab: state.selectedTab,
                            ),
                            const SizedBox(height: 30),
                            ...List<Widget>.generate(tiers.length, (index) {
                              final IncentiveTier tier = tiers[index];
                              final bool unlocked = currentRides >= tier.targetRides;
                              final bool isActive = index == activeTierIndex && !unlocked;
                              return _buildMilestoneItem(
                                isLast: index == tiers.length - 1,
                                isUnlocked: unlocked,
                                icon: index == 2
                                    ? Icons.diamond_outlined
                                    : (index == 1
                                        ? Icons.emoji_events
                                        : Icons.emoji_events_outlined),
                                title: tier.title,
                                subtitle: _milestoneSubtitle(
                                  selectedTab: state.selectedTab,
                                  targetRides: tier.targetRides,
                                ),
                                reward: '\u20B9${tier.rewardAmount}',
                                isActive: isActive,
                              );
                            }),
                            if (state.selectedTab == 'Day') ...<Widget>[
                              const SizedBox(height: 20),
                              const Text(
                                'MORNING SESSION \u2022 12:00 PM -4:00PM',
                                style: TextStyle(
                                  color: AppColors.gray,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...List<Widget>.generate(tiers.length, (index) {
                                final IncentiveTier tier = tiers[index];
                                return _buildMilestoneItem(
                                  isLast: index == tiers.length - 1,
                                  isUnlocked: false,
                                  icon: index == 2
                                      ? Icons.diamond_outlined
                                      : (index == 1
                                          ? Icons.emoji_events
                                          : Icons.emoji_events_outlined),
                                  title: tier.title,
                                  subtitle: _milestoneSubtitle(
                                    selectedTab: state.selectedTab,
                                    targetRides: tier.targetRides,
                                  ),
                                  reward: '\u20B9${tier.rewardAmount}',
                                  isActive: false,
                                );
                              }),
                            ],
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _activeTierIndex({
    required int achievedRides,
    required List<IncentiveTier> tiers,
  }) {
    for (int i = 0; i < tiers.length; i++) {
      if (achievedRides < tiers[i].targetRides) return i;
    }
    return tiers.length - 1;
  }

  String _sessionTitle(String selectedTab) {
    if (selectedTab == 'Week') return 'WEEKLY SESSION';
    if (selectedTab == 'Bonus') return 'MONTHLY SESSION';
    return 'DAILY SESSION';
  }

  int _potentialRewardFor(String selectedTab) {
    if (selectedTab == 'Week') return 1500;
    if (selectedTab == 'Bonus') return 4000;
    return 150;
  }

  Widget _buildDateItem(
    BuildContext context,
    IncentivesState state,
    String day,
    String date,
    int index,
  ) {
    final bool isSelected = state.selectedDayIndex == index;
    return GestureDetector(
      onTap: () => context.read<IncentivesCubit>().selectDay(index),
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.earningsAccentSoft : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.emerald.withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.emerald : AppColors.gray[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? AppColors.emerald : AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeItem(
    BuildContext context,
    IncentivesState state,
    String label,
    int index,
  ) {
    final bool isSelected = state.selectedDayIndex == index;
    return GestureDetector(
      onTap: () => context.read<IncentivesCubit>().selectDay(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.hexFFB7D7CC : AppColors.hexFFF3F3F3,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppColors.emerald) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.emerald : AppColors.gray[700],
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveQuestCard({
    required List<IncentiveTier> tiers,
    required int currentRides,
    required int activeTierIndex,
    required double progressFraction,
    required String selectedTab,
  }) {
    final int currentTarget = tiers[activeTierIndex].targetRides;
    final int achievedDisplay = currentRides.clamp(0, currentTarget);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.hexFF00A844, AppColors.hexFF007F33],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE QUEST',
            style: TextStyle(
              color: AppColors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Potential Reward: ',
                style: TextStyle(color: AppColors.white, fontSize: 16),
              ),
              Text(
                '\u20B9${_potentialRewardFor(selectedTab)}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth * progressFraction;
              return Stack(
                children: [
                  Container(
                    height: 4,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    height: 4,
                    width: width,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: tiers.map((tier) {
                      return _buildProgressMarker(
                        tier.targetRides.toString(),
                        currentRides >= tier.targetRides,
                      );
                    }).toList(growable: false),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$achievedDisplay of $currentTarget rides completed',
                  style: const TextStyle(color: AppColors.white70, fontSize: 12),
                ),
              Text(
                'TIER ${activeTierIndex + 1}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMarker(String label, bool reached) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: reached ? AppColors.white : AppColors.hexFF006025,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.hexFF00A844, width: 2),
          ),
          child: Center(
            child: reached
                ? const SizedBox()
                : Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.white30,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneItem({
    required bool isLast,
    required bool isUnlocked,
    required IconData icon,
    required String title,
    required String subtitle,
    required String reward,
    required bool isActive,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.emerald : AppColors.gray[300],
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.gray[200])),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppColors.hexFFFFF8E1 : AppColors.gray[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isUnlocked ? AppColors.gold : AppColors.gray[300],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isUnlocked ? AppColors.black : AppColors.gray[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.gray[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        reward,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isUnlocked ? AppColors.emerald : AppColors.gray[300],
                        ),
                      ),
                      Text(
                        isUnlocked ? 'UNLOCKED' : 'LOCKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppColors.gold : AppColors.gray[300],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, IncentivesState state, String text) {
    final bool isSelected = state.selectedTab == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<IncentivesCubit>().selectTab(text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isSelected
              ? BoxDecoration(
                  color: AppColors.emerald,
                  borderRadius: BorderRadius.circular(25),
                )
              : null,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.gray[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _milestoneSubtitle({
    required String selectedTab,
    required int targetRides,
  }) {
    if (selectedTab == 'Week') {
      return 'Complete $targetRides rides this week';
    }
    if (selectedTab == 'Bonus') {
      return 'Complete $targetRides rides this month';
    }
    return 'Complete $targetRides rides today';
  }
}




