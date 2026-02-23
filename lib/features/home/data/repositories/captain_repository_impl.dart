import 'package:dartz/dartz.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/home/data/datasources/captain_remote_data_source.dart';
import 'package:goapp/features/home/domain/entities/captain_profile.dart';
import 'package:goapp/features/home/domain/repositories/captain_repository.dart';

class CaptainRepositoryImpl implements CaptainRepository {
  const CaptainRepositoryImpl(this._remoteDataSource);

  final CaptainRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, CaptainProfile>> getCaptainProfile() async {
    try {
      final CaptainProfile profile = await _remoteDataSource
          .fetchCaptainProfile();
      return Right<Failure, CaptainProfile>(profile);
    } on Exception catch (error) {
      return Left<Failure, CaptainProfile>(ServerFailure(error.toString()));
    }
  }
}
