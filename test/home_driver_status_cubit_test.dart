import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/home/presentation/cubit/driver_status_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/driver_status_state.dart';

void main() {
  group('DriverStatusCubit', () {
    late DriverStatusCubit cubit;

    setUp(() {
      cubit = DriverStatusCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is offline', () {
      expect(cubit.state.status, DriverStatus.offline);
      expect(cubit.state.isOnline, isFalse);
    });

    test('goOnline emits online state', () async {
      expectLater(
        cubit.stream,
        emitsThrough(
          predicate<DriverState>((state) => state.status == DriverStatus.online),
        ),
      );

      cubit.goOnline();
      expect(cubit.state.isOnline, isTrue);
    });

    test('toggleStatus switches from offline to online and back', () async {
      expectLater(
        cubit.stream,
        emitsInOrder(<dynamic>[
          predicate<DriverState>((state) => state.status == DriverStatus.online),
          predicate<DriverState>((state) => state.status == DriverStatus.offline),
        ]),
      );

      cubit.toggleStatus();
      cubit.toggleStatus();
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

      cubit.goOnline();
      await Future<void>.delayed(const Duration(seconds: 9));
      expect(cubit.state.navigateToOrdersToken, 0);

      await Future<void>.delayed(const Duration(seconds: 1));
      expect(cubit.state.navigateToOrdersToken, 1);
    });

    test('goOffline before delay prevents navigation token emit', () async {
      cubit.goOnline();
      await Future<void>.delayed(const Duration(seconds: 2));
      cubit.goOffline();
      await Future<void>.delayed(const Duration(seconds: 5));

      expect(cubit.state.navigateToOrdersToken, 0);
      expect(cubit.state.isOffline, isTrue);
    });
  });
}
