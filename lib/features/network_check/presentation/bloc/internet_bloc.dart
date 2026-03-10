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

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
