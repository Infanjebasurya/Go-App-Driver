import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/home/presentation/cubit/enter_ride_code_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/enter_ride_code_state.dart';

void main() {
  group('EnterRideCodeCubit', () {
    late EnterRideCodeCubit cubit;

    setUp(() {
      cubit = EnterRideCodeCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is empty and cannot start', () {
      expect(cubit.state, const EnterRideCodeState());
      expect(cubit.state.canStart, isFalse);
    });

    test('adds up to 4 digits only', () {
      cubit
        ..addDigit('1')
        ..addDigit('2')
        ..addDigit('3')
        ..addDigit('4')
        ..addDigit('5');

      expect(cubit.state.digits, <String>['1', '2', '3', '4']);
      expect(cubit.state.canStart, isTrue);
    });

    test('backspace removes last digit', () {
      cubit
        ..addDigit('1')
        ..addDigit('2')
        ..backspace();

      expect(cubit.state.digits, <String>['1']);
    });
  });
}
