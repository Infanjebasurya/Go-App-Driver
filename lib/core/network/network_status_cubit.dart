import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'network_info.dart';

class NetworkStatusState {
  const NetworkStatusState({required this.isOffline});

  final bool isOffline;

  NetworkStatusState copyWith({bool? isOffline}) {
    return NetworkStatusState(isOffline: isOffline ?? this.isOffline);
  }
}

class NetworkStatusCubit extends Cubit<NetworkStatusState> {
  NetworkStatusCubit(this._networkInfo)
    : super(const NetworkStatusState(isOffline: false)) {
    _init();
  }

  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _subscription;

  Future<void> _init() async {
    final connected = await _networkInfo.isConnected;
    if (isClosed) return;
    emit(state.copyWith(isOffline: !connected));

    _subscription = _networkInfo.onConnectivityChanged.distinct().listen((
      connectedNow,
    ) {
      if (isClosed) return;
      emit(state.copyWith(isOffline: !connectedNow));
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
