import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:goapp/features/profile/domain/usecases/get_cached_profile_usecase.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_edit_cubit.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_edit_state.dart';
import 'package:goapp/features/profile/presentation/widgets/either.dart';


class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Either<Failure, Profile?>> getCachedProfile() async {
    return Right(
      const Profile(
        id: 'test-id',
        name: 'Sam Yogesh',
        email: 'michael.rodriguez@email.com',
        gender: 'Male',
        dob: 'March 15, 1990',
        phone: '+91 99446 63355',
        refer: '',
        emergencyContact: '',
        rating: 4.98,
        totalTrips: 1240,
        totalYears: 1.5,
      ),
    );
  }

  @override
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String gender,
    required String refer,
    required String emergencyContact,
    required String email,
  }) async {
    return Right(
      Profile(
        id: 'test-id',
        name: name,
        gender: gender,
        refer: refer,
        emergencyContact: emergencyContact,
        email: email,
      ),
    );
  }
}

void main() {
  group('ProfileEditCubit', () {
    late ProfileEditCubit cubit;

    setUp(() {
      cubit = ProfileEditCubit(
        getCachedProfileUseCase: GetCachedProfileUseCase(
          _FakeProfileRepository(),
        ),
        saveDelay: const Duration(milliseconds: 1),
        statusResetDelay: const Duration(milliseconds: 1),
        actionDelay: const Duration(milliseconds: 1),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('loads profile data', () async {
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.status, ProfileEditStatus.loaded);
      expect(cubit.state.data, isNotNull);
      expect(cubit.state.data!.fullName, 'Sam Yogesh'); // ✅ from fake repo
    });

    test('updates full name', () async {
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await cubit.updateFullName('Sam Yogi');

      expect(cubit.state.status, ProfileEditStatus.loaded);
      expect(cubit.state.data!.fullName, 'Sam Yogi');
    });

    test('updates email', () async {
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await cubit.updateEmail('sam.yogi@email.com');

      expect(cubit.state.status, ProfileEditStatus.loaded);
      expect(cubit.state.data!.email, 'sam.yogi@email.com');
    });

    test('sets loggedOut status', () async {
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await cubit.logout();

      expect(cubit.state.status, ProfileEditStatus.loggedOut);
    });

    test('sets deleted status', () async {
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await cubit.deleteAccount();

      expect(cubit.state.status, ProfileEditStatus.deleted);
    });
  });
}