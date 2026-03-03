import 'package:goapp/core/storage/driver_wallet_store.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/utils/earnings_calculator.dart';
import 'package:goapp/features/earnings/domain/entities/earnings_snapshot.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';

class EarningsWalletMockApi {
  const EarningsWalletMockApi();

  Future<EarningsSnapshot> fetchSnapshot() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final List<RideHistoryTrip> history = await RideHistoryStore.loadTrips();

    final DateTime now = DateTime.now();
    final int dayStartMs = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;
    final int dayEndMs = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).millisecondsSinceEpoch;

    double totalEarned = 0;
    double todaysEarnings = 0;
    int totalRides = 0;

    for (final RideHistoryTrip trip in history) {
      if (!EarningsCalculator.isSettledTrip(trip)) continue;
      final double tripEarning = EarningsCalculator.totalEarning(trip);
      if (tripEarning <= 0) continue;
      totalEarned += tripEarning;

      if (EarningsCalculator.isCompletedTrip(trip)) {
        totalRides += 1;
      }

      final int eventEpoch =
          trip.completedAtEpochMs ??
          trip.canceledAtEpochMs ??
          trip.acceptedAtEpochMs;
      if (eventEpoch >= dayStartMs && eventEpoch < dayEndMs) {
        todaysEarnings += tripEarning;
      }
    }

    final double walletBalance = await DriverWalletStore.loadBalance();
    return EarningsSnapshot(
      todaysEarnings: todaysEarnings,
      totalEarned: totalEarned,
      totalRides: totalRides,
      walletBalance: walletBalance,
    );
  }

  Future<List<TransactionItem>> fetchTransactions() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const <TransactionItem>[];
  }

  Future<double> rechargeWallet(double amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return DriverWalletStore.addAmount(amount);
  }

  Future<double?> withdrawWallet(double amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return DriverWalletStore.subtractAmount(amount);
  }
}
