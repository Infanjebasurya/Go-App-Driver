import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/network_check/domain/repositories/internet_repository.dart';
import 'package:goapp/features/network_check/presentation/bloc/internet_bloc.dart';
import 'package:goapp/features/network_check/presentation/bloc/internet_event.dart';
import 'package:goapp/features/network_check/presentation/bloc/internet_state.dart';

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
  test('emits initial status and reacts to connectivity stream', () async {
    final repo = _FakeInternetRepository(initialConnected: false);
    final bloc = InternetBloc(repo);
    final states = <InternetState>[];
    final sub = bloc.stream.listen(states.add);

    await Future<void>.delayed(Duration.zero);
    expect(states.isNotEmpty, true);
    expect(states.last.status, InternetStatus.disconnected);

    repo.setConnected(true);
    await Future<void>.delayed(Duration.zero);
    expect(states.last.status, InternetStatus.connected);

    repo.setConnected(false);
    await Future<void>.delayed(Duration.zero);
    expect(states.last.status, InternetStatus.disconnected);

    await sub.cancel();
    await bloc.close();
    await repo.dispose();
  });

  test('check requested re-reads repository state', () async {
    final repo = _FakeInternetRepository(initialConnected: false);
    final bloc = InternetBloc(repo);
    final states = <InternetState>[];
    final sub = bloc.stream.listen(states.add);

    await Future<void>.delayed(Duration.zero);
    expect(states.last.status, InternetStatus.disconnected);

    repo.setConnected(true);
    bloc.add(const InternetCheckRequested());
    await Future<void>.delayed(Duration.zero);
    expect(states.last.status, InternetStatus.connected);

    await sub.cancel();
    await bloc.close();
    await repo.dispose();
  });
}
