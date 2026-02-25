import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/presentation/widgets/either.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String gender,
    required String refer,
    required String emergencyContact, required String email,
  });

  Future<Either<Failure, Profile?>> getCachedProfile();
}
