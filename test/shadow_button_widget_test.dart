import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

void main() {
  testWidgets('ShadowButton shows custom shadows when enabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShadowButton(
            onPressed: () {},
            label: const Text('Tap'),
          ),
        ),
      ),
    );

    final Container container = tester.widget<Container>(
      find.descendant(
        of: find.byType(ShadowButton),
        matching: find.byType(Container),
      ).first,
    );
    final BoxDecoration decoration = container.decoration! as BoxDecoration;

    expect(decoration.boxShadow, isNotNull);
    expect(decoration.boxShadow!.length, 2);
  });

  testWidgets('ShadowButton removes custom shadows when disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShadowButton(
            onPressed: null,
            label: Text('Tap'),
          ),
        ),
      ),
    );

    final Container container = tester.widget<Container>(
      find.descendant(
        of: find.byType(ShadowButton),
        matching: find.byType(Container),
      ).first,
    );
    final BoxDecoration decoration = container.decoration! as BoxDecoration;

    expect(decoration.boxShadow, isEmpty);
  });

  testWidgets('ShadowButton renders loading indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShadowButton(
            onPressed: () {},
            loading: true,
            label: const Text('Tap'),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Tap'), findsNothing);
  });
}
