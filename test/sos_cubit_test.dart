import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/sos/presentation/cubit/sos_cubit.dart';

void main() {
  group('SosCubit', () {
    late SosCubit cubit;

    setUp(() {
      cubit = SosCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('has expected initial state', () {
      expect(cubit.state.isSafe, isFalse);
      expect(cubit.state.contacts.length, 2);
      expect(
        cubit.state.contacts.every((contact) => contact.status == 'Not sent'),
        isTrue,
      );
    });

    test('sendAlertToAllContacts marks all contacts as sent', () {
      cubit.sendAlertToAllContacts();

      expect(
        cubit.state.contacts.every((contact) => contact.status == 'Sent'),
        isTrue,
      );
    });

    test('markSafe marks alert as safe', () {
      cubit.markSafe();

      expect(cubit.state.isSafe, isTrue);
    });
  });
}
