import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/usecase/usecase.dart';
import 'package:goapp/features/home/domain/entities/captain_profile.dart';
import 'package:goapp/features/home/domain/usecases/get_captain_profile.dart';
import 'package:goapp/features/home/presentation/cubit/home_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/home_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCaptainProfile extends Mock implements GetCaptainProfile {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  group('HomeCubit', () {
    late GetCaptainProfile getCaptainProfile;
    late HomeCubit cubit;

    setUpAll(() {
      registerFallbackValue(FakeNoParams());
    });

    setUp(() {
      getCaptainProfile = MockGetCaptainProfile();
      cubit = HomeCubit(getCaptainProfile);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('emits loading then success when use case returns profile', () async {
      const profile = CaptainProfile(
        id: 'captain-001',
        name: 'Test Captain',
        vehicleType: 'Bike',
        isOnline: true,
      );
      when(
        () => getCaptainProfile(any()),
      ).thenAnswer((_) async => const Right(profile));

      expectLater(
        cubit.stream,
        emitsInOrder(<HomeState>[
          const HomeState(status: HomeStatus.loading),
          const HomeState(status: HomeStatus.success, profile: profile),
        ]),
      );

      await cubit.loadCaptainProfile();
      verify(() => getCaptainProfile(any())).called(1);
    });

    test('emits loading then failure when use case returns failure', () async {
      when(
        () => getCaptainProfile(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('server down')));

      expectLater(
        cubit.stream,
        emitsInOrder(<HomeState>[
          const HomeState(status: HomeStatus.loading),
          const HomeState(
            status: HomeStatus.failure,
            errorMessage: 'server down',
          ),
        ]),
      );

      await cubit.loadCaptainProfile();
      verify(() => getCaptainProfile(any())).called(1);
    });
  });
}
