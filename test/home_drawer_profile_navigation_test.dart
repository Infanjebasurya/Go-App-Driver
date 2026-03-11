import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/storage/profile_display_store.dart';
import 'package:goapp/core/service/image_picker_service.dart';
import 'package:goapp/features/home/presentation/widgets/home_drawer.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:goapp/features/profile/domain/usecases/get_cached_profile_usecase.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_edit_cubit.dart';
import 'package:goapp/features/profile/presentation/pages/profile_screen.dart';

import 'support/shared_preferences_mock.dart';
import 'package:goapp/features/profile/presentation/widgets/either.dart';
import 'package:goapp/core/error/failures.dart';

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String email,
    required String gender,
    required String dob,
    required String refer,
    required String emergencyContact,
  }) {
    return Future<Either<Failure, Profile>>.value(
      Right(
        Profile(
          id: 'test',
          name: name,
          gender: gender,
          refer: refer,
          emergencyContact: emergencyContact,
          email: email,
          dob: dob,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, Profile?>> getCachedProfile() {
    return Future<Either<Failure, Profile?>>.value(
      Right(
        const Profile(
          id: 'test',
          name: 'Sam Yogi',
          gender: 'male',
          refer: '',
          emergencyContact: '',
          email: 'sam@example.com',
          phone: '0000000000',
          dob: '2000-01-01',
          rating: 4.8,
          totalTrips: 120,
          totalYears: 2.0,
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setMockSharedPreferences();
    await sl.reset();
    await initializeDependencies();
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    if (sl.isRegistered<ImagePickerService>()) {
      sl.unregister<ImagePickerService>();
    }
    if (sl.isRegistered<ProfileRepository>()) {
      sl.unregister<ProfileRepository>();
    }
    if (sl.isRegistered<GetCachedProfileUseCase>()) {
      sl.unregister<GetCachedProfileUseCase>();
    }
    if (sl.isRegistered<ProfileEditCubit>()) {
      sl.unregister<ProfileEditCubit>();
    }

    sl.registerLazySingleton<ImagePickerService>(() => ImagePickerService());
    sl.registerLazySingleton<ProfileRepository>(() => _FakeProfileRepository());
    sl.registerLazySingleton<GetCachedProfileUseCase>(
      () => GetCachedProfileUseCase(sl<ProfileRepository>()),
    );
    sl.registerFactory<ProfileEditCubit>(
      () => ProfileEditCubit(getCachedProfileUseCase: sl()),
    );
  });

  tearDown(() {
    if (sl.isRegistered<ProfileEditCubit>()) {
      sl.unregister<ProfileEditCubit>();
    }
    if (sl.isRegistered<GetCachedProfileUseCase>()) {
      sl.unregister<GetCachedProfileUseCase>();
    }
    if (sl.isRegistered<ProfileRepository>()) {
      sl.unregister<ProfileRepository>();
    }
    if (sl.isRegistered<ImagePickerService>()) {
      sl.unregister<ImagePickerService>();
    }
  });

  testWidgets('drawer header tap navigates to profile screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeDrawer(onReopenDrawer: () {}),
        ),
      ),
    );

    // Ignore any network-image loading exception from drawer avatar in test env.
    tester.takeException();

    await tester.tap(find.text(ProfileDisplayStore.displayName()));
    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
