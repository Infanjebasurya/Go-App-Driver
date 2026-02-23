enum ReferralStatus { pending, completed, joined }

enum CampaignType { bike, auto, cab }

class ReferralCampaign {
  final String id;
  final String label;
  final int reward;
  final CampaignType type;

  const ReferralCampaign({
    required this.id,
    required this.label,
    required this.reward,
    required this.type,
  });
}

class ReferralPerson {
  final String id;
  final String name;
  final String initials;
  final int estimatedReward;
  final ReferralStatus status;
  final String sentAgo;
  final int? ridesCompleted;
  final int? totalRidesRequired;
  final String? completedDate;
  final bool? rewardCredited;

  const ReferralPerson({
    required this.id,
    required this.name,
    required this.initials,
    required this.estimatedReward,
    required this.status,
    required this.sentAgo,
    this.ridesCompleted,
    this.totalRidesRequired,
    this.completedDate,
    this.rewardCredited,
  });

  double get progressPercent {
    if (ridesCompleted == null || totalRidesRequired == null) return 0;
    return ridesCompleted! / totalRidesRequired!;
  }
}
