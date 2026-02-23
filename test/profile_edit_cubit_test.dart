import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_edit_cubit.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_edit_state.dart';

void main() {
  group('ProfileEditCubit', () {
    late ProfileEditCubit cubit;

    setUp(() {
      cubit = ProfileEditCubit(
        loadDelay: const Duration(milliseconds: 1),
        saveDelay: const Duration(milliseconds: 1),
        statusResetDelay: const Duration(milliseconds: 1),
        actionDelay: const Duration(milliseconds: 1),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('loads mock profile data', () async {
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.status, ProfileEditStatus.loaded);
      expect(cubit.state.data, isNotNull);
      expect(cubit.state.data!.fullName, 'Sam Yogesh');
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
