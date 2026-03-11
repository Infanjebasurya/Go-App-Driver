import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/storage/profile_display_store.dart';
import 'package:goapp/features/home/presentation/widgets/home_drawer.dart';
import 'package:goapp/features/profile/presentation/pages/profile_screen.dart';

import 'support/shared_preferences_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setMockSharedPreferences();
    await sl.reset();
    await initializeDependencies();
  });

  testWidgets('drawer header tap navigates to profile screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeDrawer(onReopenDrawer: () {}),
        ),
      ),
    );

    // Ignore any network-image loading exception from drawer avatar in test env.
    tester.takeException();

    await tester.tap(find.text(ProfileDisplayStore.displayName()));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
