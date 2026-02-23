import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/app.dart';
import 'package:goapp/injection.dart';

void main() {
  testWidgets('renders home page shell', (
    WidgetTester tester,
  ) async {
    await sl.reset();
    await initializeDependencies();

    await tester.pumpWidget(const GoApp());
    await tester.pumpAndSettle();

    expect(find.text("You're Offline"), findsOneWidget);
    expect(find.text('Wallet Balance'), findsOneWidget);
  });
}
