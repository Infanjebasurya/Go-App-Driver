import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';

import '../cubit/incentives_cubit.dart';
import '../cubit/incentives_state.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';

class IncentivesPage extends StatelessWidget {
  const IncentivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IncentivesCubit(),
      child: const _IncentivesView(),
    );
  }
}

class _IncentivesView extends StatelessWidget {
  const _IncentivesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncentivesCubit, IncentivesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black,size: 14,),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Incentives',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.black),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
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
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _buildDateItem(context, state, 'Tue', '10', 0),
                    _buildDateItem(context, state, 'Wed', '11', 1),
                    _buildDateItem(context, state, 'Thu', '12', 2),
                    _buildDateItem(context, state, 'Fri', '13', 3),
                    _buildDateItem(context, state, 'Sat', '14', 4),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MORNING SESSION • 08:00 AM - 12:00 PM',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActiveQuestCard(),
                      const SizedBox(height: 30),
                      _buildMilestoneItem(
                        isLast: false,
                        isUnlocked: true,
                        icon: Icons.emoji_events_outlined,
                        title: 'Silver Milestone',
                        subtitle: 'Complete 3 rides today',
                        reward: '₹50',
                        isActive: true,
                      ),
                      _buildMilestoneItem(
                        isLast: false,
                        isUnlocked: false,
                        icon: Icons.emoji_events,
                        title: 'Gold Milestone',
                        subtitle: 'Complete 5 rides today',
                        reward: '₹100',
                        isActive: false,
                      ),
                      _buildMilestoneItem(
                        isLast: true,
                        isUnlocked: false,
                        icon: Icons.diamond_outlined,
                        title: 'Platinum Milestone',
                        subtitle: 'Complete 7 rides today',
                        reward: '₹150',
                        isActive: false,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'MORNING SESSION • 12:00 PM - 4:00 PM',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildMilestoneItem(
                        isLast: false,
                        isUnlocked: false,
                        icon: Icons.emoji_events_outlined,
                        title: 'Silver Milestone',
                        subtitle: 'Complete 3 rides today',
                        reward: '₹50',
                        isActive: false,
                      ),
                      _buildMilestoneItem(
                        isLast: false,
                        isUnlocked: false,
                        icon: Icons.emoji_events,
                        title: 'Gold Milestone',
                        subtitle: 'Complete 5 rides today',
                        reward: '₹100',
                        isActive: false,
                      ),
                      _buildMilestoneItem(
                        isLast: true,
                        isUnlocked: false,
                        icon: Icons.diamond_outlined,
                        title: 'Platinum Milestone',
                        subtitle: 'Complete 7 rides today',
                        reward: '₹150',
                        isActive: false,
                      ),
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

  Widget _buildDateItem(
    BuildContext context,
    IncentivesState state,
    String day,
    String date,
    int index,
  ) {
    final isSelected = state.selectedDayIndex == index;
    return GestureDetector(
      onTap: () => context.read<IncentivesCubit>().selectDay(index),
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.earningsAccentSoft : Colors.white,
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
                color: isSelected ? AppColors.emerald : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? AppColors.emerald : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveQuestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00A844), Color(0xFF007F33)],
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
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Text(
                'Potential Reward: ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '₹150',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 4,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                height: 4,
                width: 150,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressMarker('3', true),
                  _buildProgressMarker('5', false),
                  _buildProgressMarker('7', false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '2 of 3 rides completed',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'TIER 1',
                style: TextStyle(
                  color: Colors.white,
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
            color: reached ? Colors.white : const Color(0xFF006025),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00A844), width: 2),
          ),
          child: Center(
            child: reached
                ? const SizedBox()
                : Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white30,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
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
                    color: isActive ? AppColors.emerald : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: Colors.grey[200])),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
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
                      color: isUnlocked
                          ? const Color(0xFFFFF8E1)
                          : Colors.grey[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isUnlocked ? AppColors.gold : Colors.grey[300],
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
                            color: isUnlocked ? Colors.black : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[500],
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
                          color: isUnlocked
                              ? AppColors.emerald
                              : Colors.grey[300],
                        ),
                      ),
                      Text(
                        isUnlocked ? 'UNLOCKED' : 'LOCKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppColors.gold : Colors.grey[300],
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
    final isSelected = state.selectedTab == text;
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
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

