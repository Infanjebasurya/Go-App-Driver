import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/storage/shared_preferences_store.dart';

/// Central place for SharedPreferencesStore test mocking so tests don't depend
/// on the `shared_preferences` plugin.
const MethodChannel _prefsChannel = MethodChannel(
  'app/shared_preferences_service',
);

Map<String, Object?> _store = <String, Object?>{};

void setMockSharedPreferences([
  Map<String, Object?> values = const <String, Object?>{},
]) {
  _store = Map<String, Object?>.from(values);

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_prefsChannel, (MethodCall call) async {
        switch (call.method) {
          case 'getAll':
            return _store;
          case 'set':
            final key = (call.arguments as Map?)?['key'] as String?;
            final value = (call.arguments as Map?)?['value'];
            if (key == null || key.isEmpty) return false;
            _store[key] = value;
            return true;
          case 'remove':
            final key = (call.arguments as Map?)?['key'] as String?;
            if (key == null || key.isEmpty) return false;
            _store.remove(key);
            return true;
          case 'clear':
            _store.clear();
            return true;
          default:
            return null;
        }
      });
}

Future<SharedPreferencesStore> initMockSharedPreferencesStore([
  Map<String, Object?> values = const <String, Object?>{},
]) async {
  setMockSharedPreferences(values);
  SharedPreferencesStore.resetForTest();
  await SharedPreferencesStore.init();
  return SharedPreferencesStore.global;
}
