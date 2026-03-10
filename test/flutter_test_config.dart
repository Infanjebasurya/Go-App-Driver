import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'support/shared_preferences_mock.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initMockSharedPreferencesStore();
  await testMain();
}
