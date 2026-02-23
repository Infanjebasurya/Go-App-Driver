

import 'package:flutter/foundation.dart';

enum DriverStatus { offline, online }

@immutable
class DriverState {
  final DriverStatus status;
  final double totalEarnings;
  final int tripsCompleted;
  final String onlineHours;
  final double walletBalance;
  final int completedRides;
  final int targetRides;
  final double rewardAmount;
  final bool isEarningsExpanded;
  final int navigateToOrdersToken;

  const DriverState({
    this.status = DriverStatus.offline,
    this.totalEarnings = 0.0,
    this.tripsCompleted = 0,
    this.onlineHours = '0h 0m',
    this.walletBalance = 120.50,
    this.completedRides = 8,
    this.targetRides = 10,
    this.rewardAmount = 80.0,
    this.isEarningsExpanded = false,
    this.navigateToOrdersToken = 0,
  });

  bool get isOnline => status == DriverStatus.online;
  bool get isOffline => status == DriverStatus.offline;
  int get remainingRides => targetRides - completedRides;
  double get progressPercentage => completedRides / targetRides;

  DriverState copyWith({
    DriverStatus? status,
    double? totalEarnings,
    int? tripsCompleted,
    String? onlineHours,
    double? walletBalance,
    int? completedRides,
    int? targetRides,
    double? rewardAmount,
    bool? isEarningsExpanded,
    int? navigateToOrdersToken,
  }) {
    return DriverState(
      status: status ?? this.status,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      tripsCompleted: tripsCompleted ?? this.tripsCompleted,
      onlineHours: onlineHours ?? this.onlineHours,
      walletBalance: walletBalance ?? this.walletBalance,
      completedRides: completedRides ?? this.completedRides,
      targetRides: targetRides ?? this.targetRides,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      isEarningsExpanded: isEarningsExpanded ?? this.isEarningsExpanded,
      navigateToOrdersToken: navigateToOrdersToken ?? this.navigateToOrdersToken,
    );
  }
}
