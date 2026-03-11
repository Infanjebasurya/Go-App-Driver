import 'package:goapp/core/error/failures.dart';
import 'package:goapp/core/storage/user_cache_model.dart';
import 'package:goapp/core/storage/user_cache_store.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:goapp/features/profile/presentation/widgets/either.dart';

class LocalProfileRepository implements ProfileRepository {
  Profile? _cached;

  @override
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String gender,
    required String email,
    required String dob,
    required String refer,
    required String emergencyContact,
  }) async {
    final existing = UserCacheStore.read();
    final trimmedDob = dob.trim();
    final dobValue = trimmedDob.isEmpty ? existing?.dob : trimmedDob;
    final profile = Profile(
      id: existing?.id.isNotEmpty == true ? existing!.id : 'local-profile',
      name: name,
      gender: gender,
      refer: refer,
      emergencyContact: emergencyContact,
      email: email.isEmpty ? null : email,
      phone: existing?.phone,
      dob: dobValue,
      rating: existing?.rating ?? 0.0,
      totalTrips: existing?.totalTrips ?? 0,
      totalYears: existing?.totalYears ?? 0.0,
    );
    _cached = profile;
    await UserCacheStore.save(_toCacheModel(profile));
    return Right(profile);
  }

  @override
  Future<Either<Failure, Profile?>> getCachedProfile() async {
    if (_cached != null) {
      return Right(_cached);
    }
    final stored = await UserCacheStore.load();
    if (stored == null) {
      return const Right(null);
    }
    _cached = _fromCacheModel(stored);
    return Right(_cached);
  }

  static Profile _fromCacheModel(LocalUserCacheModel user) {
    return Profile(
      id: user.id,
      name: user.fullName,
      gender: user.gender,
      refer: user.referCode,
      emergencyContact: user.emergencyContact,
      email: user.email,
      phone: user.phone,
      dob: user.dob,
      rating: user.rating,
      totalTrips: user.totalTrips,
      totalYears: user.totalYears,
    );
  }

  static LocalUserCacheModel _toCacheModel(Profile profile) {
    return LocalUserCacheModel(
      id: profile.id,
      fullName: profile.name,
      gender: profile.gender,
      referCode: profile.refer,
      emergencyContact: profile.emergencyContact,
      email: profile.email,
      phone: profile.phone,
      dob: profile.dob,
      rating: profile.rating,
      totalTrips: profile.totalTrips,
      totalYears: profile.totalYears,
    );
  }
}

