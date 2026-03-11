import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/internet_repository.dart';
import 'internet_event.dart';
import 'internet_state.dart';

class InternetBloc extends Bloc<InternetEvent, InternetState> {
  InternetBloc(this._internetRepository) : super(InternetState.initial()) {
    on<InternetStarted>(_onStarted);
    on<InternetConnectionChanged>(_onConnectionChanged);
    on<InternetCheckRequested>(_onCheckRequested);
    add(const InternetStarted());
  }

  final InternetRepository _internetRepository;
  StreamSubscription<bool>? _subscription;
  Timer? _pollTimer;

  Future<void> _onStarted(
    InternetStarted event,
    Emitter<InternetState> emit,
  ) async {
    final connected = await _internetRepository.isConnected();
    emit(connected ? InternetState.connected() : InternetState.disconnected());

    await _subscription?.cancel();
    _subscription = _internetRepository.onConnectivityChanged().distinct().listen((
      connectedNow,
    ) {
      if (isClosed) return;
      add(InternetConnectionChanged(isConnected: connectedNow));
    });

    _startPolling();
  }

  void _onConnectionChanged(
    InternetConnectionChanged event,
    Emitter<InternetState> emit,
  ) {
    emit(event.isConnected ? InternetState.connected() : InternetState.disconnected());
  }

  Future<void> _onCheckRequested(
    InternetCheckRequested event,
    Emitter<InternetState> emit,
  ) async {
    final connected = await _internetRepository.isConnected();
    emit(connected ? InternetState.connected() : InternetState.disconnected());
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final connected = await _internetRepository.isConnected();
      if (isClosed) return;
      if (connected && state.status != InternetStatus.connected) {
        add(const InternetConnectionChanged(isConnected: true));
      } else if (!connected && state.status != InternetStatus.disconnected) {
        add(const InternetConnectionChanged(isConnected: false));
      }
    });
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
