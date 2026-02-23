import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/home/presentation/cubit/available_orders_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/available_orders_state.dart';

void main() {
  group('AvailableOrdersCubit', () {
    late AvailableOrdersCubit cubit;

    setUp(() {
      cubit = AvailableOrdersCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('starts with first order active and hidden second order', () {
      expect(cubit.state, const AvailableOrdersState());
      expect(cubit.progressForOrder(0), 0);
      expect(cubit.progressForOrder(1), 0);
    });

    test('progressForOrder returns completed for previous order', () {
      const state = AvailableOrdersState(
        activeOrderIndex: 1,
        progress: 0.4,
        showSecondOrder: true,
      );
      expect(state.activeOrderIndex, 1);
      expect(state.showSecondOrder, isTrue);
    });
  });
}
