import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/sos/presentation/cubit/sos_state.dart';

class SosCubit extends Cubit<SosState> {
  SosCubit() : super(const SosState());

  void sendAlertToAllContacts() {
    final updated = state.contacts
        .map((contact) => contact.copyWith(status: 'Sent'))
        .toList(growable: false);
    emit(state.copyWith(contacts: updated));
  }

  void sendAlertToContact(int index) {
    final updated = List<SosContact>.from(state.contacts);
    if (index < 0 || index >= updated.length) return;
    updated[index] = updated[index].copyWith(status: 'Sended');
    emit(state.copyWith(contacts: updated));
  }

  void markSafe() {
    emit(state.copyWith(isSafe: true));
  }
}
