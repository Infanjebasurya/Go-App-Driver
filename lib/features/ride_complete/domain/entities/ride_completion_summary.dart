import 'package:equatable/equatable.dart';

class RideCompletionSummary extends Equatable {
  const RideCompletionSummary({
    required this.totalEarnings,
    required this.distanceKm,
    required this.tripFare,
    required this.tips,
    required this.discountPercent,
    required this.discountAmount,
    required this.paymentLink,
    required this.driverName,
    required this.driverRating,
    required this.avatarAssetPath,
  });

  final double totalEarnings;
  final double distanceKm;
  final double tripFare;
  final double tips;
  final double discountPercent;
  final double discountAmount;
  final String paymentLink;
  final String driverName;
  final double driverRating;
  final String avatarAssetPath;

  @override
  List<Object> get props => <Object>[
    totalEarnings,
    distanceKm,
    tripFare,
    tips,
    discountPercent,
    discountAmount,
    paymentLink,
    driverName,
    driverRating,
    avatarAssetPath,
  ];
}
