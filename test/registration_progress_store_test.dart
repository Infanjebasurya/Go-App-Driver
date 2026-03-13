import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/storage/registration_progress_store.dart';
import 'support/shared_preferences_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initMockSharedPreferencesStore();
  });

  test(
    'resetForSignedOut keeps onboarding and clears signed-in progress',
    () async {
      await RegistrationProgressStore.save(
        const RegistrationProgress(
          otpVerified: true,
          onboardingSeen: true,
          step: RegistrationStep.home,
        ),
      );

      await RegistrationProgressStore.resetForSignedOut();

      final progress = await RegistrationProgressStore.load();
      expect(progress.onboardingSeen, isTrue);
      expect(progress.otpVerified, isFalse);
      expect(progress.step, RegistrationStep.none);
    },
  );

  test('resetForSignedOut can preserve current onboarding flag', () async {
    await RegistrationProgressStore.save(
      const RegistrationProgress(
        otpVerified: true,
        onboardingSeen: false,
        step: RegistrationStep.profileSetup,
      ),
    );

    await RegistrationProgressStore.resetForSignedOut(
      showLoginOnNextLaunch: false,
    );

    final progress = await RegistrationProgressStore.load();
    expect(progress.onboardingSeen, isFalse);
    expect(progress.otpVerified, isFalse);
    expect(progress.step, RegistrationStep.none);
  });
}
