import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/storage/location_permission_prompt_store.dart';
import 'support/shared_preferences_mock.dart';

void main() {
  group('LocationPermissionPromptStore', () {
    setUp(() async {
      await initMockSharedPreferencesStore();
    });

    test('marks pending prompt after two denials and consumes once', () async {
      await LocationPermissionPromptStore.noteDeniedAttempt();
      expect(
        await LocationPermissionPromptStore.consumePendingSettingsPrompt(),
        isFalse,
      );

      await LocationPermissionPromptStore.noteDeniedAttempt();
      expect(
        await LocationPermissionPromptStore.consumePendingSettingsPrompt(),
        isTrue,
      );
      expect(
        await LocationPermissionPromptStore.consumePendingSettingsPrompt(),
        isFalse,
      );
    });

    test('clearDeniedHistory resets pending prompt', () async {
      await LocationPermissionPromptStore.noteDeniedAttempt();
      await LocationPermissionPromptStore.noteDeniedAttempt();
      await LocationPermissionPromptStore.clearDeniedHistory();

      expect(
        await LocationPermissionPromptStore.consumePendingSettingsPrompt(),
        isFalse,
      );
    });
  });
}
