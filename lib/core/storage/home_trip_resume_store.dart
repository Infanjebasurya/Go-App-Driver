import 'shared_preferences_store.dart';

enum HomeTripResumeStage {
  none,
  availableOrders,
  rideArrived,
  enterRideCode,
  passengerOnboard,
  tripNavigation,
  rideCompleted,
  rateExperience,
}

class HomeTripResumeStore {
  HomeTripResumeStore._();

  static const String _key = 'home_trip_resume_stage_v1';
  static const String _tripStartMsKey = 'home_trip_navigation_start_ms_v1';
  static const String _forceHomeOnLaunchKey =
      'home_force_home_on_next_launch_v1';

  static Future<HomeTripResumeStage> loadStage() async {
    final prefs = SharedPreferencesStore.global;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return HomeTripResumeStage.none;
    return HomeTripResumeStage.values.firstWhere(
      (stage) => stage.name == raw,
      orElse: () => HomeTripResumeStage.none,
    );
  }

  static Future<void> setStage(HomeTripResumeStage stage) async {
    final prefs = SharedPreferencesStore.global;
    await prefs.setString(_key, stage.name);
  }

  static Future<int?> loadTripNavigationStartEpochMs() async {
    final prefs = SharedPreferencesStore.global;
    final value = prefs.getInt(_tripStartMsKey);
    if (value == null || value <= 0) return null;
    return value;
  }

  static Future<void> setTripNavigationStartEpochMs(int epochMs) async {
    final prefs = SharedPreferencesStore.global;
    await prefs.setInt(_tripStartMsKey, epochMs);
  }

  static Future<void> clearTripNavigationStartEpochMs() async {
    final prefs = SharedPreferencesStore.global;
    await prefs.remove(_tripStartMsKey);
  }

  static Future<void> clear() async {
    await setStage(HomeTripResumeStage.none);
    await clearTripNavigationStartEpochMs();
    await clearForceHomeOnNextLaunch();
  }

  static Future<void> markForceHomeOnNextLaunch() async {
    final prefs = SharedPreferencesStore.global;
    await prefs.setBool(_forceHomeOnLaunchKey, true);
  }

  static Future<bool> consumeForceHomeOnNextLaunch() async {
    final prefs = SharedPreferencesStore.global;
    final bool shouldForce = prefs.getBool(_forceHomeOnLaunchKey) ?? false;
    if (!shouldForce) return false;
    await prefs.setBool(_forceHomeOnLaunchKey, false);
    return true;
  }

  static Future<void> clearForceHomeOnNextLaunch() async {
    final prefs = SharedPreferencesStore.global;
    await prefs.setBool(_forceHomeOnLaunchKey, false);
  }
}
