import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/home/presentation/cubit/available_orders_state.dart';

class AvailableOrdersCubit extends Cubit<AvailableOrdersState> {
  AvailableOrdersCubit() : super(const AvailableOrdersState());

  static const Duration _tickDuration = Duration(milliseconds: 100);
  static const Duration _perOrderDuration = Duration(seconds: 6);
  Timer? _timer;

  void start() {
    _timer?.cancel();
    final double step =
        _tickDuration.inMilliseconds / _perOrderDuration.inMilliseconds;

    _timer = Timer.periodic(_tickDuration, (_) {
      final double nextProgress = (state.progress + step).clamp(0, 1);
      if (nextProgress < 1) {
        emit(state.copyWith(progress: nextProgress));
        return;
      }

      if (state.activeOrderIndex == 0) {
        emit(
          state.copyWith(
            activeOrderIndex: 1,
            showSecondOrder: true,
            progress: 0,
          ),
        );
        return;
      }
      if (state.activeOrderIndex == 1) {
        emit(
          state.copyWith(
            activeOrderIndex: 2,
            showThirdOrder: true,
            progress: 0,
          ),
        );
        return;
      }
      if (state.activeOrderIndex == 2) {
        emit(
          state.copyWith(
            activeOrderIndex: 3,
            showFourthOrder: true,
            progress: 0,
          ),
        );
        return;
      }

      emit(state.copyWith(progress: 1));
      _timer?.cancel();
    });
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
