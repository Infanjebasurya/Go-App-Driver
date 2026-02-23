import 'package:equatable/equatable.dart';
import 'package:goapp/features/refer_earn/domain/entities/referral.dart';

abstract class ReferralState extends Equatable {
  const ReferralState();

  @override
  List<Object?> get props => [];
}

class ReferralInitial extends ReferralState {
  const ReferralInitial();
}

class ReferralLoading extends ReferralState {
  const ReferralLoading();
}

class ReferralLoaded extends ReferralState {
  final String referralCode;
  final int totalEarnings;
  final List<ReferralCampaign> campaigns;
  final List<ReferralPerson> allReferrals;
  final bool codeCopied;

  const ReferralLoaded({
    required this.referralCode,
    required this.totalEarnings,
    required this.campaigns,
    required this.allReferrals,
    this.codeCopied = false,
  });

  List<ReferralPerson> get pending =>
      allReferrals.where((r) => r.status == ReferralStatus.pending).toList();

  List<ReferralPerson> get completed =>
      allReferrals.where((r) => r.status == ReferralStatus.completed).toList();

  ReferralLoaded copyWith({
    String? referralCode,
    int? totalEarnings,
    List<ReferralCampaign>? campaigns,
    List<ReferralPerson>? allReferrals,
    bool? codeCopied,
  }) {
    return ReferralLoaded(
      referralCode: referralCode ?? this.referralCode,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      campaigns: campaigns ?? this.campaigns,
      allReferrals: allReferrals ?? this.allReferrals,
      codeCopied: codeCopied ?? this.codeCopied,
    );
  }

  @override
  List<Object?> get props => [
    referralCode,
    totalEarnings,
    campaigns,
    allReferrals,
    codeCopied,
  ];
}
