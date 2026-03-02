import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/driver_wallet_store.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/storage/ride_history_store.dart';

import 'driver_status_state.dart';

class DriverCubit extends Cubit<DriverState> {
  DriverCubit({LocationPermissionGuard? locationGuard})
    : _locationGuard = locationGuard ?? const LocationPermissionGuard(),
      super(const DriverState());

  final LocationPermissionGuard _locationGuard;
  Timer? _onlineTimer;
  Timer? _ordersNavigationTimer;
  Timer? _locationWatchTimer;
  int _onlineMinutes = 0;
  bool _isCheckingLocation = false;

  Future<void> refreshDashboardMetrics() async {
    final List<RideHistoryTrip> history = await RideHistoryStore.loadTrips();
    final Iterable<RideHistoryTrip> completed = history.where((trip) {
      return trip.completedAtEpochMs != null && trip.canceledAtEpochMs == null;
    });

    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    final int dayStartMs = startOfDay.millisecondsSinceEpoch;
    final int dayEndMs = endOfDay.millisecondsSinceEpoch;

    final List<RideHistoryTrip> completedToday = completed
        .where((trip) {
          final int? completedAt = trip.completedAtEpochMs;
          return completedAt != null &&
              completedAt >= dayStartMs &&
              completedAt < dayEndMs;
        })
        .toList(growable: false);

    double totalFare = 0;
    for (final RideHistoryTrip trip in completedToday) {
      totalFare += _parseCurrency(trip.fareLabel);
    }

    final double walletBalance = await DriverWalletStore.loadBalance();
    final int ridesToday = completedToday.length;
    final int rewardProgress = ridesToday > state.targetRides
        ? state.targetRides
        : ridesToday;

    if (isClosed) return;
    emit(
      state.copyWith(
        tripsCompleted: ridesToday,
        totalEarnings: totalFare,
        walletBalance: walletBalance,
        completedRides: rewardProgress,
      ),
    );
  }

  double _parseCurrency(String? raw) {
    if (raw == null || raw.isEmpty) return 0;
    final String cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> toggleStatus() async {
    if (state.isOnline) {
      goOffline();
    } else {
      await goOnline();
    }
  }

  Future<void> goOnline() async {
    if (state.isOnline) return;

    final access = await _locationGuard.ensureReady(requestPermission: true);
    if (!access.isReady) {
      emit(
        state.copyWith(
          status: DriverStatus.offline,
          offlineBlockIssue: access.issue,
          offlineBlockEventId: state.offlineBlockEventId + 1,
        ),
      );
      return;
    }

    _onlineMinutes = 0;
    _startTimer();
    _startOrdersNavigationDelay();
    emit(
      state.copyWith(
        status: DriverStatus.online,
        onlineHours: '0h 0m',
        clearOfflineBlockIssue: true,
      ),
    );
    _startLocationWatch();
  }

  void goOffline({LocationIssue? reason}) {
    if (state.isOffline && reason == null && state.offlineBlockIssue == null) {
      return;
    }
    _stopTimer();
    _stopOrdersNavigationDelay();
    _stopLocationWatch();
    emit(
      state.copyWith(
        status: DriverStatus.offline,
        offlineBlockIssue: reason,
        offlineBlockEventId: reason == null
            ? state.offlineBlockEventId
            : state.offlineBlockEventId + 1,
      ),
    );
  }

  void _startTimer() {
    _onlineTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _onlineMinutes++;
      final hours = _onlineMinutes ~/ 60;
      final minutes = _onlineMinutes % 60;
      emit(state.copyWith(onlineHours: '${hours}h ${minutes}m'));
    });
  }

  void _stopTimer() {
    _onlineTimer?.cancel();
    _onlineTimer = null;
  }

  void _startOrdersNavigationDelay() {
    _ordersNavigationTimer?.cancel();
    _ordersNavigationTimer = Timer(const Duration(seconds: 10), () {
      if (!state.isOnline) return;
      emit(
        state.copyWith(navigateToOrdersToken: state.navigateToOrdersToken + 1),
      );
    });
  }

  void _stopOrdersNavigationDelay() {
    _ordersNavigationTimer?.cancel();
    _ordersNavigationTimer = null;
  }

  void _startLocationWatch() {
    _locationWatchTimer?.cancel();
    _locationWatchTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      unawaited(_validateLocationAvailability());
    });
    unawaited(_validateLocationAvailability());
  }

  void _stopLocationWatch() {
    _locationWatchTimer?.cancel();
    _locationWatchTimer = null;
  }

  Future<void> _validateLocationAvailability() async {
    if (_isCheckingLocation || state.isOffline) return;
    _isCheckingLocation = true;
    try {
      final result = await _locationGuard.ensureReady(requestPermission: false);
      if (!result.isReady && state.isOnline) {
        goOffline(reason: result.issue);
      }
    } finally {
      _isCheckingLocation = false;
    }
  }

  Future<void> addMoney(double amount) async {
    final double next = await DriverWalletStore.addAmount(amount);
    if (isClosed) return;
    emit(state.copyWith(walletBalance: next));
  }

  bool addMoneyFromInput(String input) {
    final String normalized = input.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final double? amount = double.tryParse(normalized);
    if (amount == null || amount <= 0) return false;
    final double next = state.walletBalance + amount;
    emit(state.copyWith(walletBalance: next));
    unawaited(DriverWalletStore.saveBalance(next));
    return true;
  }

  void toggleEarningsExpanded() {
    emit(state.copyWith(isEarningsExpanded: !state.isEarningsExpanded));
  }

  void completeRide(double fare) {
    emit(
      state.copyWith(
        totalEarnings: state.totalEarnings + fare,
        tripsCompleted: state.tripsCompleted + 1,
        completedRides: (state.completedRides < state.targetRides)
            ? state.completedRides + 1
            : state.completedRides,
      ),
    );
  }

  void clearOfflineLocationBlock() {
    if (state.offlineBlockIssue == null) return;
    emit(state.copyWith(clearOfflineBlockIssue: true));
  }

  @override
  Future<void> close() {
    _stopTimer();
    _stopOrdersNavigationDelay();
    _stopLocationWatch();
    return super.close();
  }
}

// Backwards-compatible alias for older imports.
class DriverStatusCubit extends DriverCubit {
  DriverStatusCubit({super.locationGuard});
}
