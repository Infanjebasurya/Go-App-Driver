import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'internet_bloc.dart';
import 'internet_state.dart';
import 'reconnect_overlay_state.dart';

class ReconnectOverlayCubit extends Cubit<ReconnectOverlayState> {
  ReconnectOverlayCubit(
    this._internetBloc, {
    this.loaderDuration = const Duration(seconds: 2),
  }) : super(const ReconnectOverlayState(visible: false)) {
    _subscription = _internetBloc.stream.listen(_handleInternetState);
    _handleInternetState(_internetBloc.state);
  }

  final InternetBloc _internetBloc;
  final Duration loaderDuration;
  StreamSubscription<InternetState>? _subscription;
  Timer? _timer;
  bool _wasDisconnected = false;

  void _handleInternetState(InternetState state) {
    if (state.status == InternetStatus.disconnected) {
      _wasDisconnected = true;
      _timer?.cancel();
      emit(const ReconnectOverlayState(visible: false));
      return;
    }

    if (state.status == InternetStatus.connected && _wasDisconnected) {
      _wasDisconnected = false;
      emit(const ReconnectOverlayState(visible: true));
      _timer?.cancel();
      _timer = Timer(loaderDuration, () {
        if (isClosed) return;
        emit(const ReconnectOverlayState(visible: false));
      });
    }
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
