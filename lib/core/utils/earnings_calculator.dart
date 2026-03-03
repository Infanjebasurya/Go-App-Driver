import 'package:goapp/core/storage/ride_history_store.dart';

class EarningsCalculator {
  const EarningsCalculator._();

  static double parseCurrency(String? raw) {
    if (raw == null || raw.isEmpty) return 0;
    final String cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned) ?? 0;
  }

  static bool isCompletedTrip(RideHistoryTrip trip) {
    return trip.completedAtEpochMs != null && trip.canceledAtEpochMs == null;
  }

  static bool isCanceledTrip(RideHistoryTrip trip) {
    return trip.canceledAtEpochMs != null;
  }

  static bool isSettledTrip(RideHistoryTrip trip) {
    return isCompletedTrip(trip) || isCanceledTrip(trip);
  }

  static double tripAmount(RideHistoryTrip trip) {
    final double fromField = trip.tripAmount ?? 0;
    if (fromField > 0) return fromField;
    return parseCurrency(trip.fareLabel);
  }

  static double incentiveAmount(RideHistoryTrip trip) {
    final double incentive = trip.incentiveAmount ?? 0;
    return incentive > 0 ? incentive : 0;
  }

  static double cancellationFeeAmount(RideHistoryTrip trip) {
    final double fee = trip.cancellationFeeAmount ?? 0;
    return fee > 0 ? fee : 0;
  }

  static double totalEarning(RideHistoryTrip trip) {
    final double explicit = trip.netEarningAmount ?? 0;
    if (explicit > 0) return explicit;
    return tripAmount(trip) + incentiveAmount(trip) + cancellationFeeAmount(trip);
  }
}
