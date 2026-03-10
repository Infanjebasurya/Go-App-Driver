import 'dart:convert';

import 'shared_preferences_store.dart';

class TextFieldStore {
  TextFieldStore._();

  static const String _prefsKey = 'text_field_store_v1';
  static final Map<String, String> _cache = <String, String>{};
  static SharedPreferencesStore? _prefs;
  static bool _loaded = false;

  static Future<void> init() async {
    if (_loaded) return;
    _prefs = SharedPreferencesStore.global;
    final raw = _prefs!.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _cache
            ..clear()
            ..addAll(
              decoded.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              ),
            );
        }
      } catch (_) {}
    }
    _loaded = true;
  }

  static String? read(String key) => _cache[key];

  static Future<void> write(String key, String value) async {
    if (!_loaded) {
      await init();
    }
    if (value.isEmpty) {
      _cache.remove(key);
    } else {
      _cache[key] = value;
    }
    await _prefs!.setString(_prefsKey, jsonEncode(_cache));
  }

  static Future<void> remove(String key) async {
    if (!_loaded) {
      await init();
    }
    _cache.remove(key);
    await _prefs!.setString(_prefsKey, jsonEncode(_cache));
  }

  static Future<void> clearAll() async {
    if (!_loaded) {
      await init();
    }
    _cache.clear();
    await _prefs!.setString(_prefsKey, jsonEncode(_cache));
  }
}
