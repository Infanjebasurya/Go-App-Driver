import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/features/help_support/presentation/cubit/complaint_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/help_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/complaint_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/help_support_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/tickets_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    if (sl.isRegistered<HelpCubit>()) {
      sl.unregister<HelpCubit>();
    }
    if (sl.isRegistered<ComplaintCubit>()) {
      sl.unregister<ComplaintCubit>();
    }
    sl.registerFactory<HelpCubit>(() => HelpCubit());
    sl.registerFactory<ComplaintCubit>(() => ComplaintCubit());
  });

  tearDown(() {
    if (sl.isRegistered<HelpCubit>()) {
      sl.unregister<HelpCubit>();
    }
    if (sl.isRegistered<ComplaintCubit>()) {
      sl.unregister<ComplaintCubit>();
    }
  });

  Widget buildApp() => const MaterialApp(home: HelpSupportScreen());

  testWidgets('expands Make Complaint options and navigates to tickets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Make Complaint'));
    await tester.pumpAndSettle();

    expect(find.text('Create New Complaint'), findsOneWidget);
    expect(find.text('Recent Support Tickets'), findsOneWidget);

    await tester.tap(find.text('Recent Support Tickets'));
    await tester.pumpAndSettle();

    expect(find.byType(TicketsScreen), findsOneWidget);
    expect(find.text('Recent Support Tickets'), findsAtLeastNWidgets(1));
  });

  testWidgets('Create New Complaint opens complaint page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Make Complaint'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create New Complaint'));
    await tester.pumpAndSettle();

    expect(find.byType(ComplaintScreen), findsOneWidget);
    expect(find.text('Submit Complaint'), findsOneWidget);
  });
}
