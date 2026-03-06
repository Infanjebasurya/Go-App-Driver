import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/help_support/domain/entities/help_entities.dart';
import 'package:goapp/features/help_support/presentation/cubit/complaint_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('submitComplaint creates open ticket with category and description', () async {
    final cubit = ComplaintCubit();
    addTearDown(cubit.close);

    cubit.selectCategory('fare_payment');
    cubit.updateDescription('Amount was deducted twice.');
    await cubit.submitComplaint();

    final state = cubit.state;
    expect(state, isA<ComplaintSubmitted>());
    final submitted = state as ComplaintSubmitted;
    expect(submitted.ticket.status, TicketStatus.open);
    expect(submitted.ticket.title, 'Fare & Payment Issues');
    expect(submitted.ticket.description, 'Amount was deducted twice.');
    expect(submitted.recentTickets.first.id, submitted.ticket.id);
  });

  test('recent tickets list prepends newest ticket', () async {
    final cubit = ComplaintCubit();
    addTearDown(cubit.close);

    cubit.selectCategory('safety');
    cubit.updateDescription('First complaint');
    await cubit.submitComplaint();
    final firstId = (cubit.state as ComplaintSubmitted).ticket.id;

    cubit.reset();
    cubit.selectCategory('app_technical');
    cubit.updateDescription('Second complaint');
    await cubit.submitComplaint();

    final submitted = cubit.state as ComplaintSubmitted;
    expect(submitted.recentTickets.length, greaterThanOrEqualTo(2));
    expect(submitted.recentTickets.first.description, 'Second complaint');
    expect(submitted.recentTickets[1].id, firstId);
  });
}

