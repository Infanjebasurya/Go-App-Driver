import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/presentation/widgets/either.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String email,
    required String gender,
    required String dob,
    required String refer,
    required String emergencyContact,
  });

  Future<Either<Failure, Profile?>> getCachedProfile();
}
