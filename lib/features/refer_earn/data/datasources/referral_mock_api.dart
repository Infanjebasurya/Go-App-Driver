import 'package:goapp/features/refer_earn/domain/entities/referral.dart';

class ReferralMockApi {
  const ReferralMockApi();

  Future<ReferralPayload> fetchReferralData() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const ReferralPayload(
      referralCode: 'REO03ZJ',
      totalEarnings: 2000,
      campaigns: <ReferralCampaign>[
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
      ],
      referrals: <ReferralPerson>[
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
      ],
    );
  }
}

class ReferralPayload {
  const ReferralPayload({
    required this.referralCode,
    required this.totalEarnings,
    required this.campaigns,
    required this.referrals,
  });

  final String referralCode;
  final int totalEarnings;
  final List<ReferralCampaign> campaigns;
  final List<ReferralPerson> referrals;
}
