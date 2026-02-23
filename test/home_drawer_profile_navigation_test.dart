import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/home/presentation/widgets/home_drawer.dart';
import 'package:goapp/features/profile/presentation/pages/profile_screen.dart';

void main() {
  testWidgets('drawer header tap navigates to profile screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeDrawer())),
    );

    // Ignore any network-image loading exception from drawer avatar in test env.
    tester.takeException();

    await tester.tap(find.text('Sam Yogi'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
