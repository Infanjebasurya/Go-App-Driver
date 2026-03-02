import 'package:goapp/core/storage/driver_wallet_store.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/features/earnings/domain/entities/earnings_snapshot.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';
import 'package:goapp/features/earnings/domain/repositories/earnings_repository.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  const EarningsRepositoryImpl();

  @override
  Future<EarningsSnapshot> getSnapshot() async {
    final List<RideHistoryTrip> history = await RideHistoryStore.loadTrips();
    final Iterable<RideHistoryTrip> completed = history.where((trip) {
      return trip.completedAtEpochMs != null && trip.canceledAtEpochMs == null;
    });

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

    for (final RideHistoryTrip trip in completed) {
      totalRides += 1;
      final double fare = _parseCurrency(trip.fareLabel);
      totalEarned += fare;
      final int? completedAt = trip.completedAtEpochMs;
      if (completedAt != null &&
          completedAt >= dayStartMs &&
          completedAt < dayEndMs) {
        todaysEarnings += fare;
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

  @override
  Future<List<TransactionItem>> getTransactions() async {
    final List<RideHistoryTrip> history = await RideHistoryStore.loadTrips();
    final Iterable<RideHistoryTrip> completed = history.where((trip) {
      return trip.completedAtEpochMs != null && trip.canceledAtEpochMs == null;
    });

    return completed
        .take(20)
        .map((trip) {
          final double fare = _parseCurrency(trip.fareLabel);
          final int ts = trip.completedAtEpochMs ?? trip.acceptedAtEpochMs;
          return TransactionItem(
            title: 'Trip Earning',
            subtitle: _formatTime(ts),
            amount: '+\u20B9${fare.toStringAsFixed(2)}',
            isCredit: true,
          );
        })
        .toList(growable: false);
  }

  double _parseCurrency(String? raw) {
    if (raw == null || raw.isEmpty) return 0;
    final String cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned) ?? 0;
  }

  String _formatTime(int epochMs) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final DateTime now = DateTime.now();
    final bool isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final int hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final String minute = dt.minute.toString().padLeft(2, '0');
    final String ampm = dt.hour >= 12 ? 'PM' : 'AM';
    if (isToday) {
      return 'Today, $hour12:$minute $ampm';
    }
    final String day = dt.day.toString().padLeft(2, '0');
    final String month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}, $hour12:$minute $ampm';
  }
}
