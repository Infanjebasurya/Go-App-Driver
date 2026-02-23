import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/usecase/usecase.dart';
import 'package:goapp/features/home/domain/entities/captain_profile.dart';
import 'package:goapp/features/home/domain/repositories/captain_repository.dart';
import 'package:goapp/features/home/domain/usecases/get_captain_profile.dart';
import 'package:mocktail/mocktail.dart';

class MockCaptainRepository extends Mock implements CaptainRepository {}

void main() {
  group('GetCaptainProfile', () {
    late CaptainRepository repository;
    late GetCaptainProfile useCase;

    setUp(() {
      repository = MockCaptainRepository();
      useCase = GetCaptainProfile(repository);
    });

    test('returns repository profile result', () async {
      const profile = CaptainProfile(
        id: 'captain-001',
        name: 'Test Captain',
        vehicleType: 'Bike',
        isOnline: true,
      );

      when(
        () => repository.getCaptainProfile(),
      ).thenAnswer((_) async => const Right(profile));

      final result = await useCase(const NoParams());

      expect(result, const Right(profile));
      verify(() => repository.getCaptainProfile()).called(1);
    });
  });
}
