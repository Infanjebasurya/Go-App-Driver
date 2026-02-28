import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/home/presentation/widgets/home_drawer.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:goapp/features/profile/presentation/pages/profile_screen.dart';
import 'package:goapp/features/profile/presentation/widgets/either.dart';

void main() {
  testWidgets('drawer header tap navigates to profile screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      RepositoryProvider<ProfileRepository>(
        create: (_) => _FakeProfileRepository(),
        child: const MaterialApp(home: Scaffold(body: HomeDrawer())),
      ),
    );

    // Ignore any network-image loading exception from drawer avatar in test env.
    tester.takeException();

    await tester.tap(find.text('Sam Yogi'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String gender,
    required String refer,
    required String emergencyContact,
    required String email,
  }) async {
    return Right<Failure, Profile>(
      Profile(
        id: 'p_1',
        name: name,
        gender: gender,
        refer: refer,
        emergencyContact: emergencyContact,
        email: email,
      ),
    );
  }

  @override
  Future<Either<Failure, Profile?>> getCachedProfile() async {
    return const Right<Failure, Profile?>(
      Profile(
        id: 'p_1',
        name: 'Sam Yogi',
        gender: 'Male',
        refer: 'none',
        emergencyContact: '+910000000000',
        email: 'sam@example.com',
      ),
    );
  }
}
