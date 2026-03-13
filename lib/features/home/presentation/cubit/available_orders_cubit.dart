import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/home/presentation/cubit/available_orders_state.dart';

class AvailableOrdersCubit extends Cubit<AvailableOrdersState> {
  AvailableOrdersCubit() : super(const AvailableOrdersState());

  static const Duration _tickDuration = Duration(milliseconds: 100);
  static const Duration _perOrderDuration = Duration(seconds: 15);
  Timer? _timer;

  void start() {
    _timer?.cancel();

    // If all orders are gone (or the flow completed), restart the stream.
    if (!state.showFirstOrder &&
        !state.showSecondOrder &&
        !state.showThirdOrder &&
        !state.showFourthOrder) {
      emit(const AvailableOrdersState());
    }

    final double step =
        _tickDuration.inMilliseconds / _perOrderDuration.inMilliseconds;

    _timer = Timer.periodic(_tickDuration, (_) {
      final double nextProgress = (state.progress + step).clamp(0, 1);
      if (nextProgress < 1) {
        emit(state.copyWith(progress: nextProgress));
        return;
      }

      _expireActiveOrder();
    });
  }

  void _expireActiveOrder() {
    switch (state.activeOrderIndex) {
      case 0:
        emit(
          state.copyWith(
            showFirstOrder: false,
            showSecondOrder: true,
            activeOrderIndex: 1,
            progress: 0,
          ),
        );
        return;
      case 1:
        emit(
          state.copyWith(
            showSecondOrder: false,
            showThirdOrder: true,
            activeOrderIndex: 2,
            progress: 0,
          ),
        );
        return;
      case 2:
        emit(
          state.copyWith(
            showThirdOrder: false,
            showFourthOrder: true,
            activeOrderIndex: 3,
            progress: 0,
          ),
        );
        return;
      case 3:
        emit(
          state.copyWith(
            showFirstOrder: true,
            showSecondOrder: false,
            showThirdOrder: false,
            showFourthOrder: false,
            activeOrderIndex: 0,
            progress: 0,
          ),
        );
        return;
      default:
        _timer?.cancel();
        return;
    }
  }

  double progressForOrder(int index) {
    if (index < state.activeOrderIndex) return 1;
    if (index == state.activeOrderIndex) return state.progress;
    return 0;
  }

  void stop() {
    _timer?.cancel();
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await super.close();
  }
}
