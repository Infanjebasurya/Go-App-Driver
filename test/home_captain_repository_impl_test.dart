import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/home/data/datasources/captain_remote_data_source.dart';
import 'package:goapp/features/home/data/models/captain_profile_model.dart';
import 'package:goapp/features/home/data/repositories/captain_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockCaptainRemoteDataSource extends Mock
    implements CaptainRemoteDataSource {}

void main() {
  group('CaptainRepositoryImpl', () {
    late CaptainRemoteDataSource remoteDataSource;
    late CaptainRepositoryImpl repository;

    setUp(() {
      remoteDataSource = MockCaptainRemoteDataSource();
      repository = CaptainRepositoryImpl(remoteDataSource);
    });

    test('returns Right(profile) when remote data source succeeds', () async {
      const model = CaptainProfileModel(
        id: 'captain-001',
        name: 'Test Captain',
        vehicleType: 'Bike',
        isOnline: true,
      );
      when(
        () => remoteDataSource.fetchCaptainProfile(),
      ).thenAnswer((_) async => model);

      final result = await repository.getCaptainProfile();

      expect(result, const Right(model));
      verify(() => remoteDataSource.fetchCaptainProfile()).called(1);
    });

    test('returns Left(ServerFailure) when remote data source throws', () async {
      when(
        () => remoteDataSource.fetchCaptainProfile(),
      ).thenThrow(Exception('network error'));

      final result = await repository.getCaptainProfile();

      expect(result.isLeft(), isTrue);
      final failure = result.fold((l) => l, (_) => throw Exception('unexpected'));
      expect(failure, isA<ServerFailure>());
      expect(failure.message, contains('network error'));
    });
  });
}
