import 'dart:io';

import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/core/storage/user_cache_store.dart';

class ProfileDisplayStore {
  ProfileDisplayStore._();

  static const String _photoKey = 'profile.photo.path';
  static const String _fallbackName = 'Sam Yogi';
  static const String _profileSetupNameKey = 'profile_setup.name';
  static const String _profileEditNameKey = 'profile_edit.full_name';

  static String displayName() {
    final cached = (UserCacheStore.read()?.fullName ?? '').trim();
    if (cached.isNotEmpty) return cached;

    final edited = (TextFieldStore.read(_profileEditNameKey) ?? '').trim();
    if (edited.isNotEmpty) return edited;

    final setup = (TextFieldStore.read(_profileSetupNameKey) ?? '').trim();
    if (setup.isNotEmpty) return setup;

    return _fallbackName;
  }

  static String? photoPath() {
    final raw = (TextFieldStore.read(_photoKey) ?? '').trim();
    if (raw.isEmpty) return null;
    if (!File(raw).existsSync()) return null;
    return raw;
  }
}
