import 'shared_preferences_store.dart';

class LocationPermissionPromptStore {
  LocationPermissionPromptStore._();

  static const String _denyCountKey = 'location_permission_deny_count_v1';
  static const String _pendingSettingsPromptKey =
      'location_permission_pending_settings_prompt_v1';

  static Future<void> noteDeniedAttempt() async {
    final prefs = SharedPreferencesStore.global;
    final int nextCount = (prefs.getInt(_denyCountKey) ?? 0) + 1;
    await prefs.setInt(_denyCountKey, nextCount);
    if (nextCount >= 2) {
      await prefs.setBool(_pendingSettingsPromptKey, true);
    }
  }

  static Future<void> clearDeniedHistory() async {
    final prefs = SharedPreferencesStore.global;
    await prefs.remove(_denyCountKey);
    await prefs.setBool(_pendingSettingsPromptKey, false);
  }

  static Future<bool> consumePendingSettingsPrompt() async {
    final prefs = SharedPreferencesStore.global;
    final bool pending = prefs.getBool(_pendingSettingsPromptKey) ?? false;
    if (!pending) return false;
    await prefs.setBool(_pendingSettingsPromptKey, false);
    return true;
  }
}
