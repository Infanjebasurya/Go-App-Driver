

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'driver_status_state.dart';


class DriverCubit extends Cubit<DriverState> {
  Timer? _onlineTimer;
  Timer? _ordersNavigationTimer;
  int _onlineMinutes = 0;

  DriverCubit() : super(const DriverState());

  void toggleStatus() {
    if (state.isOnline) {
      goOffline();
    } else {
      goOnline();
    }
  }

  void goOnline() {
    _startTimer();
    _startOrdersNavigationDelay();
    emit(state.copyWith(status: DriverStatus.online));
  }

  void goOffline() {
    _stopTimer();
    _stopOrdersNavigationDelay();
    emit(state.copyWith(status: DriverStatus.offline));
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
        state.copyWith(
          navigateToOrdersToken: state.navigateToOrdersToken + 1,
        ),
      );
    });
  }

  void _stopOrdersNavigationDelay() {
    _ordersNavigationTimer?.cancel();
    _ordersNavigationTimer = null;
  }

  void addMoney(double amount) {
    emit(state.copyWith(walletBalance: state.walletBalance + amount));
  }

  bool addMoneyFromInput(String input) {
    final String normalized = input.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final double? amount = double.tryParse(normalized);
    if (amount == null || amount <= 0) return false;
    addMoney(amount);
    return true;
  }

  void toggleEarningsExpanded() {
    emit(state.copyWith(isEarningsExpanded: !state.isEarningsExpanded));
  }

  void completeRide(double fare) {
    emit(state.copyWith(
      totalEarnings: state.totalEarnings + fare,
      tripsCompleted: state.tripsCompleted + 1,
      completedRides: (state.completedRides < state.targetRides)
          ? state.completedRides + 1
          : state.completedRides,
    ));
  }

  @override
  Future<void> close() {
    _stopTimer();
    _stopOrdersNavigationDelay();
    return super.close();
  }
}

// Backwards-compatible alias for older imports.
class DriverStatusCubit extends DriverCubit {}
