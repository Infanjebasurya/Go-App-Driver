import 'package:dartz/dartz.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/usecase/usecase.dart';
import 'package:goapp/features/home/domain/entities/captain_profile.dart';
import 'package:goapp/features/home/domain/repositories/captain_repository.dart';

class GetCaptainProfile
    implements UseCase<Either<Failure, CaptainProfile>, NoParams> {
  const GetCaptainProfile(this._repository);

  final CaptainRepository _repository;

  @override
  Future<Either<Failure, CaptainProfile>> call(NoParams params) {
    return _repository.getCaptainProfile();
  }
}
