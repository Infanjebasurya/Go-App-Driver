import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:goapp/features/profile/presentation/widgets/either.dart';

class CreateProfileUseCase {
  const CreateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, Profile>> call({
    required String name,
    required String email,
    required String gender,
    required String refer,
    required String emergencyContact,
  }) {
    return _repository.createProfile(
      name: name,
      email : email,
      gender: gender,
      refer: refer,
      emergencyContact: emergencyContact,
    );
  }
}
