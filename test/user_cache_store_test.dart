import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/storage/user_cache_model.dart';
import 'package:goapp/core/storage/user_cache_store.dart';
import 'support/shared_preferences_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initMockSharedPreferencesStore();
  });

  test('LocalUserCacheModel JSON round-trip works', () {
    const model = LocalUserCacheModel(
      id: 'u_1',
      fullName: 'Test User',
      gender: 'Male',
      referCode: 'REF123',
      emergencyContact: '9999999999',
      email: 'test@example.com',
      phone: '+919999999999',
      dob: '12 July 1995',
      rating: 4.5,
      totalTrips: 100,
      totalYears: 2.0,
    );

    final json = model.toJson();
    final restored = LocalUserCacheModel.fromJson(json);

    expect(restored.id, model.id);
    expect(restored.fullName, model.fullName);
    expect(restored.gender, model.gender);
    expect(restored.email, model.email);
    expect(restored.phone, model.phone);
    expect(restored.dob, model.dob);
    expect(restored.rating, model.rating);
    expect(restored.totalTrips, model.totalTrips);
  });

  test('UserCacheStore saves and loads completed user only', () async {
    await UserCacheStore.init();
    expect(await UserCacheStore.load(), isNull);

    const model = LocalUserCacheModel(
      id: 'u_2',
      fullName: 'Cached Driver',
      gender: 'Female',
      referCode: '',
      emergencyContact: '8888888888',
      email: 'driver@example.com',
    );
    await UserCacheStore.save(model);

    final loaded = await UserCacheStore.load();
    expect(loaded, isNotNull);
    expect(loaded!.id, 'u_2');
    expect(loaded.fullName, 'Cached Driver');

    await UserCacheStore.clear();
    expect(await UserCacheStore.load(), isNull);
  });
}
