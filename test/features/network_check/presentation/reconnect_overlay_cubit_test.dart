import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/network_check/domain/repositories/internet_repository.dart';
import 'package:goapp/features/network_check/presentation/bloc/internet_bloc.dart';
import 'package:goapp/features/network_check/presentation/bloc/reconnect_overlay_cubit.dart';

class _FakeInternetRepository implements InternetRepository {
  _FakeInternetRepository({required bool initialConnected})
    : _connected = initialConnected;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _connected;

  void setConnected(bool connected) {
    _connected = connected;
    _controller.add(connected);
  }

  @override
  Future<bool> isConnected() async => _connected;

  @override
  Stream<bool> onConnectivityChanged() => _controller.stream;

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  test('shows loader for 2 seconds after reconnect', () async {
    final repo = _FakeInternetRepository(initialConnected: false);
    final internetBloc = InternetBloc(repo);
    final reconnectCubit = ReconnectOverlayCubit(internetBloc);

    expect(reconnectCubit.state.visible, false);

    // Wait for initial disconnected propagation.
    await Future<void>.delayed(const Duration(milliseconds: 10));

    repo.setConnected(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(reconnectCubit.state.visible, true);

    await Future<void>.delayed(const Duration(seconds: 2));
    expect(reconnectCubit.state.visible, false);

    await reconnectCubit.close();
    await internetBloc.close();
    await repo.dispose();
  });

  test('does not show loader without prior disconnect', () async {
    final repo = _FakeInternetRepository(initialConnected: true);
    final internetBloc = InternetBloc(repo);
    final reconnectCubit = ReconnectOverlayCubit(internetBloc);

    expect(reconnectCubit.state.visible, false);
    repo.setConnected(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(reconnectCubit.state.visible, false);

    await reconnectCubit.close();
    await internetBloc.close();
    await repo.dispose();
  });

  test('hides loader when disconnected', () async {
    final repo = _FakeInternetRepository(initialConnected: false);
    final internetBloc = InternetBloc(repo);
    final reconnectCubit = ReconnectOverlayCubit(internetBloc);

    await Future<void>.delayed(const Duration(milliseconds: 10));

    repo.setConnected(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(reconnectCubit.state.visible, true);

    repo.setConnected(false);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(reconnectCubit.state.visible, false);

    await reconnectCubit.close();
    await internetBloc.close();
    await repo.dispose();
  });
}
