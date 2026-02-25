import 'package:equatable/equatable.dart';

class EarningsSnapshot extends Equatable {
  const EarningsSnapshot({
    required this.todaysEarnings,
    required this.totalEarned,
    required this.totalRides,
    required this.walletBalance,
  });

  final double todaysEarnings;
  final double totalEarned;
  final int totalRides;
  final double walletBalance;

  @override
  List<Object> get props => <Object>[
    todaysEarnings,
    totalEarned,
    totalRides,
    walletBalance,
  ];
}
