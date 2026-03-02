import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'user_cache_model.dart';

class UserCacheStore {
  UserCacheStore._();

  static const String _key = 'local_user_cache_v1';
  static SharedPreferences? _prefs;
  static LocalUserCacheModel? _cached;
  static bool _loaded = false;

  static Future<void> init() async {
    if (_loaded) return;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw);
        if (map is Map<String, dynamic>) {
          final parsed = LocalUserCacheModel.fromJson(map);
          _cached = _isValid(parsed) ? parsed : null;
        }
      } catch (_) {}
    }
    _loaded = true;
  }

  static LocalUserCacheModel? read() => _cached;

  static bool get hasUser => _cached != null && _isValid(_cached!);

  static Future<LocalUserCacheModel?> load() async {
    if (!_loaded) {
      await init();
    }
    return _cached;
  }

  static Future<void> save(LocalUserCacheModel user) async {
    if (!_loaded) {
      await init();
    }
    _cached = user;
    await _prefs!.setString(_key, jsonEncode(user.toJson()));
  }

  static Future<void> clear() async {
    if (!_loaded) {
      await init();
    }
    _cached = null;
    await _prefs!.remove(_key);
  }

  static bool _isValid(LocalUserCacheModel user) {
    return user.id.trim().isNotEmpty && user.fullName.trim().isNotEmpty;
  }
}
