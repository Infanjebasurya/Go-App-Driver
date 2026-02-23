import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:goapp/features/profile/presentation/widgets/either.dart';

class GetCachedProfileUseCase {
  const GetCachedProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, Profile?>> call() {
    return _repository.getCachedProfile();
  }
}
