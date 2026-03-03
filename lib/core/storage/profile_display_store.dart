import 'dart:io';

import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/core/storage/user_cache_store.dart';

class ProfileDisplayStore {
  ProfileDisplayStore._();

  static const String _photoKey = 'profile.photo.path';
  static const String _fallbackName = 'Sam Yogi';

  static String displayName() {
    final raw = (UserCacheStore.read()?.fullName ?? '').trim();
    return raw.isEmpty ? _fallbackName : raw;
  }

  static String? photoPath() {
    final raw = (TextFieldStore.read(_photoKey) ?? '').trim();
    if (raw.isEmpty) return null;
    if (!File(raw).existsSync()) return null;
    return raw;
  }
}

