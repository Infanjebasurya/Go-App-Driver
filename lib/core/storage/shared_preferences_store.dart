import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper so the rest of the app doesn't import `shared_preferences`.
///
/// This is intentionally minimal: add methods as needed.
class SharedPreferencesStore {
  SharedPreferencesStore._(this._prefs);

  final SharedPreferences _prefs;

  factory SharedPreferencesStore.fromInstance(SharedPreferences prefs) {
    return SharedPreferencesStore._(prefs);
  }

  static SharedPreferencesStore? _global;

  static SharedPreferencesStore get global {
    final store = _global;
    if (store == null) {
      throw StateError(
        'SharedPreferencesStore not initialized. Call SharedPreferencesStore.init() first.',
      );
    }
    return store;
  }

  static Future<void> init() async {
    if (_global != null) return;
    _global = SharedPreferencesStore._(await SharedPreferences.getInstance());
  }

  static void setGlobal(SharedPreferencesStore store) {
    _global = store;
  }

  String? getString(String key) => _prefs.getString(key);
  int? getInt(String key) => _prefs.getInt(key);
  double? getDouble(String key) => _prefs.getDouble(key);
  bool? getBool(String key) => _prefs.getBool(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
