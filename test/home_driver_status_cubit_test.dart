import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/features/home/presentation/cubit/driver_status_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/driver_status_state.dart';
import 'support/shared_preferences_mock.dart';

class _FakeLocationPermissionGuard extends LocationPermissionGuard {
  _FakeLocationPermissionGuard(this._results);

  final List<LocationAccessResult> _results;
  int _index = 0;

  @override
  Future<LocationAccessResult> ensureReady({
    bool requestPermission = false,
  }) async {
    final current = _index < _results.length
        ? _results[_index]
        : _results.last;
    _index++;
    return current;
  }
}

void main() {
  group('DriverStatusCubit', () {
    late DriverStatusCubit cubit;

    setUp(() async {
      await initMockSharedPreferencesStore(<String, Object>{'driver_wallet_balance_v1': 120.5});
      cubit = DriverStatusCubit(
        locationGuard: _FakeLocationPermissionGuard(
          const [LocationAccessResult.ready()],
        ),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is offline', () {
      expect(cubit.state.status, DriverStatus.offline);
      expect(cubit.state.isOnline, isFalse);
    });

    test('goOnline emits online state when location is ready', () async {
      await cubit.goOnline();
      expect(cubit.state.isOnline, isTrue);
    });

    test('toggleStatus switches from offline to online and back', () async {
      final List<DriverStatus> statuses = <DriverStatus>[];
      final subscription = cubit.stream.listen((state) {
        statuses.add(state.status);
      });

      await cubit.toggleStatus();
      await cubit.toggleStatus();
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(
        statuses,
        containsAllInOrder(<DriverStatus>[
          DriverStatus.online,
          DriverStatus.offline,
        ]),
      );
      expect(cubit.state.isOnline, isFalse);
    });

    test('addMoneyFromInput parses valid input and ignores invalid values', () {
      final startingBalance = cubit.state.walletBalance;

      final added = cubit.addMoneyFromInput('250.75');
      expect(added, isTrue);
      expect(cubit.state.walletBalance, startingBalance + 250.75);

      final rejected = cubit.addMoneyFromInput('abc');
      expect(rejected, isFalse);
      expect(cubit.state.walletBalance, startingBalance + 250.75);
    });

    test('goOnline emits navigate token after 10 seconds', () async {
      expect(cubit.state.navigateToOrdersToken, 0);

      await cubit.goOnline();
      await Future<void>.delayed(const Duration(seconds: 9));
      expect(cubit.state.navigateToOrdersToken, 0);

      await Future<void>.delayed(const Duration(seconds: 1));
      expect(cubit.state.navigateToOrdersToken, 1);
    });

    test('goOffline before delay prevents navigation token emit', () async {
      await cubit.goOnline();
      await Future<void>.delayed(const Duration(seconds: 2));
      cubit.goOffline();
      await Future<void>.delayed(const Duration(seconds: 5));

      expect(cubit.state.navigateToOrdersToken, 0);
      expect(cubit.state.isOffline, isTrue);
    });

    test('goOnline stays offline and sets block issue when gps is off', () async {
      await cubit.close();
      cubit = DriverStatusCubit(
        locationGuard: _FakeLocationPermissionGuard(
          const [
            LocationAccessResult.blocked(LocationIssue.serviceDisabled),
          ],
        ),
      );

      await cubit.goOnline();

      expect(cubit.state.isOffline, isTrue);
      expect(cubit.state.offlineBlockIssue, LocationIssue.serviceDisabled);
      expect(cubit.state.navigateToOrdersToken, 0);
    });

    test('auto-goes offline if location becomes unavailable while online', () async {
      await cubit.close();
      cubit = DriverStatusCubit(
        locationGuard: _FakeLocationPermissionGuard(
          const [
            LocationAccessResult.ready(),
            LocationAccessResult.ready(),
            LocationAccessResult.blocked(LocationIssue.serviceDisabled),
          ],
        ),
      );

      await cubit.goOnline();
      expect(cubit.state.isOnline, isTrue);

      await Future<void>.delayed(const Duration(seconds: 7));

      expect(cubit.state.isOffline, isTrue);
      expect(cubit.state.offlineBlockIssue, LocationIssue.serviceDisabled);
      expect(cubit.state.navigateToOrdersToken, 0);
    });
  });
}
