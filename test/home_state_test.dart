import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/home/domain/entities/captain_profile.dart';
import 'package:goapp/features/home/presentation/cubit/home_state.dart';

void main() {
  group('HomeState', () {
    test('default constructor has initial values', () {
      const state = HomeState();

      expect(state.status, HomeStatus.initial);
      expect(state.profile, isNull);
      expect(state.errorMessage, '');
    });

    test('copyWith updates only provided fields', () {
      const profile = CaptainProfile(
        id: 'captain-100',
        name: 'Captain',
        vehicleType: 'Bike',
        isOnline: true,
      );
      const base = HomeState(
        status: HomeStatus.success,
        profile: profile,
        errorMessage: '',
      );

      final updated = base.copyWith(
        status: HomeStatus.failure,
        errorMessage: 'server down',
      );

      expect(updated.status, HomeStatus.failure);
      expect(updated.profile, profile);
      expect(updated.errorMessage, 'server down');
    });

    test('supports value equality', () {
      const a = HomeState(status: HomeStatus.loading);
      const b = HomeState(status: HomeStatus.loading);

      expect(a, b);
    });
  });
}
