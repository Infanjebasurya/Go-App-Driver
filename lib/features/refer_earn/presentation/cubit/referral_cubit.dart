import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/refer_earn/presentation/cubit/referral_state.dart';
import 'package:goapp/features/refer_earn/domain/entities/referral.dart';

class ReferralCubit extends Cubit<ReferralState> {
  ReferralCubit() : super(const ReferralInitial()) {
    loadData();
  }

  static const _campaigns = [
    ReferralCampaign(
      id: 'bike',
      label: '1 Bike Referral',
      reward: 2000,
      type: CampaignType.bike,
    ),
    ReferralCampaign(
      id: 'auto',
      label: '1 Auto Referral',
      reward: 2000,
      type: CampaignType.auto,
    ),
    ReferralCampaign(
      id: 'cab',
      label: '1 Cab Referral',
      reward: 1000,
      type: CampaignType.cab,
    ),
  ];

  static const _referrals = [
    ReferralPerson(
      id: '1',
      name: 'Arun S',
      initials: 'AS',
      estimatedReward: 3000,
      status: ReferralStatus.pending,
      sentAgo: 'Invite sent 2 days ago',
      ridesCompleted: 8,
      totalRidesRequired: 10,
    ),
    ReferralPerson(
      id: '2',
      name: 'Syed A.',
      initials: 'SA',
      estimatedReward: 3000,
      status: ReferralStatus.pending,
      sentAgo: 'Invite sent 5 days ago',
      ridesCompleted: 0,
      totalRidesRequired: 10,
    ),
    ReferralPerson(
      id: '3',
      name: 'Yogi Sam',
      initials: 'YS',
      estimatedReward: 3000,
      status: ReferralStatus.completed,
      sentAgo: 'Completed on May 10',
      completedDate: 'MAY 10',
      rewardCredited: true,
    ),
  ];

  Future<void> loadData() async {
    emit(const ReferralLoading());
    await Future<void>.delayed(const Duration(milliseconds: 500));
    emit(
      const ReferralLoaded(
        referralCode: 'REO03ZJ',
        totalEarnings: 2000,
        campaigns: _campaigns,
        allReferrals: _referrals,
      ),
    );
  }

  Future<void> copyCode() async {
    if (state is! ReferralLoaded) return;
    final s = state as ReferralLoaded;
    emit(s.copyWith(codeCopied: true));
    await Future<void>.delayed(const Duration(seconds: 2));
    if (state is ReferralLoaded) {
      emit((state as ReferralLoaded).copyWith(codeCopied: false));
    }
  }
}
