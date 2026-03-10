import 'package:shared_preferences/shared_preferences.dart';
import 'package:goapp/core/storage/shared_preferences_store.dart';

/// Central place for SharedPreferences test mocking so tests don't import the
/// plugin package directly.
void setMockSharedPreferences([Map<String, Object> values = const <String, Object>{}]) {
  SharedPreferences.setMockInitialValues(values);
}

Future<SharedPreferencesStore> initMockSharedPreferencesStore([
  Map<String, Object> values = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  final store = SharedPreferencesStore.fromInstance(prefs);
  SharedPreferencesStore.setGlobal(store);
  return store;
}
