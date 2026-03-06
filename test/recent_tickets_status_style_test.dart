import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/help_support/domain/entities/help_entities.dart';
import 'package:goapp/features/help_support/presentation/pages/tickets_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('resolved and closed chips use configured colors', (
    WidgetTester tester,
  ) async {
    final tickets = <SupportTicket>[
      SupportTicket(
        id: 'GP-11111',
        title: 'Fare & Payment Issues',
        description: 'Resolved complaint',
        status: TicketStatus.resolved,
        createdAt: DateTime(2026, 3, 6),
      ),
      SupportTicket(
        id: 'GP-22222',
        title: 'Safety Concerns',
        description: 'Closed complaint',
        status: TicketStatus.closed,
        createdAt: DateTime(2026, 3, 6),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: TicketsScreen(tickets: tickets)),
    );
    await tester.pumpAndSettle();

    final resolvedText = tester.widget<Text>(find.text('Resolved'));
    final closedText = tester.widget<Text>(find.text('Closed'));
    expect(resolvedText.style?.color, const Color(0xFF00A86B));
    expect(closedText.style?.color, const Color(0xFF78716C));

    final resolvedContainer = _findStatusChipContainer(tester, 'Resolved');
    final closedContainer = _findStatusChipContainer(tester, 'Closed');

    final resolvedDecoration = resolvedContainer.decoration! as BoxDecoration;
    final closedDecoration = closedContainer.decoration! as BoxDecoration;

    expect(resolvedDecoration.color, const Color(0x1A00A86B));
    expect((resolvedDecoration.border! as Border).top.color, const Color(0x3300A86B));
    expect(closedDecoration.color, const Color(0xFFF5F5F4));
    expect((closedDecoration.border! as Border).top.color, const Color(0xFFE7E5E4));
  });
}

Container _findStatusChipContainer(WidgetTester tester, String label) {
  final containers = tester.widgetList<Container>(
    find.ancestor(
      of: find.text(label),
      matching: find.byType(Container),
    ),
  );
  return containers.firstWhere((container) {
    final decoration = container.decoration;
    return decoration is BoxDecoration && decoration.border != null;
  });
}

