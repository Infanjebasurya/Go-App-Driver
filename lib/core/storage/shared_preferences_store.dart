import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper so the rest of the app doesn't depend on `shared_preferences`.
///
/// Backed by Android `SharedPreferences` via a MethodChannel.
class SharedPreferencesStore {
  SharedPreferencesStore._(this._cache);

  static const MethodChannel _channel =
      MethodChannel('app/shared_preferences_service');

  final Map<String, Object?> _cache;

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
    final Map<Object?, Object?>? raw =
        await _channel.invokeMapMethod<Object?, Object?>('getAll');
    _global = SharedPreferencesStore._(_coerceStringKeyedMap(raw));
  }

  static void setGlobal(SharedPreferencesStore store) {
    _global = store;
  }

  @visibleForTesting
  static void resetForTest() {
    _global = null;
  }

  String? getString(String key) => _cache[key] as String?;
  int? getInt(String key) => _cache[key] as int?;
  double? getDouble(String key) => (_cache[key] as num?)?.toDouble();
  bool? getBool(String key) => _cache[key] as bool?;
  List<String>? getStringList(String key) {
    final value = _cache[key];
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return null;
  }

  Future<bool> setString(String key, String value) =>
      _setTyped(key: key, type: 'string', value: value);
  Future<bool> setInt(String key, int value) =>
      _setTyped(key: key, type: 'int', value: value);
  Future<bool> setDouble(String key, double value) =>
      _setTyped(key: key, type: 'double', value: value);
  Future<bool> setBool(String key, bool value) =>
      _setTyped(key: key, type: 'bool', value: value);
  Future<bool> setStringList(String key, List<String> value) =>
      _setTyped(key: key, type: 'stringList', value: value);

  Future<bool> _setTyped({
    required String key,
    required String type,
    required Object value,
  }) async {
    final bool ok =
        await _channel.invokeMethod<bool>('set', <String, Object>{
              'key': key,
              'type': type,
              'value': value,
            }) ??
            false;
    if (ok) {
      _cache[key] = value;
    }
    return ok;
  }

  Future<bool> remove(String key) async {
    final bool ok =
        await _channel.invokeMethod<bool>('remove', <String, Object>{
              'key': key,
            }) ??
            false;
    if (ok) {
      _cache.remove(key);
    }
    return ok;
  }

  Future<bool> clear() async {
    final bool ok = await _channel.invokeMethod<bool>('clear') ?? false;
    if (ok) {
      _cache.clear();
    }
    return ok;
  }

  static Map<String, Object?> _coerceStringKeyedMap(
    Map<Object?, Object?>? raw,
  ) {
    final Map<String, Object?> out = <String, Object?>{};
    if (raw == null) return out;
    for (final entry in raw.entries) {
      final key = entry.key;
      if (key is! String) continue;
      out[key] = entry.value;
    }
    return out;
  }
}
