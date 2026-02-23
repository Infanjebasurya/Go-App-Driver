import 'package:flutter_bloc/flutter_bloc.dart';

class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.number,
    required this.isPrimary,
  });

  final String name;
  final String number;
  final bool isPrimary;

  EmergencyContact copyWith({String? name, String? number, bool? isPrimary}) {
    return EmergencyContact(
      name: name ?? this.name,
      number: number ?? this.number,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class EmergencyContactsState {
  const EmergencyContactsState({required this.contacts});

  final List<EmergencyContact> contacts;

  EmergencyContactsState copyWith({List<EmergencyContact>? contacts}) {
    return EmergencyContactsState(contacts: contacts ?? this.contacts);
  }
}

class EmergencyContactsCubit extends Cubit<EmergencyContactsState> {
  EmergencyContactsCubit()
      : super(
          EmergencyContactsState(
            contacts: _sorted(const [
              EmergencyContact(
                name: 'Alex Johnson',
                number: '+91 9552489931',
                isPrimary: true,
              ),
              EmergencyContact(
                name: 'Priya Singh',
                number: '+91 9809337200',
                isPrimary: false,
              ),
            ]),
          ),
        );

  static bool isValidContactInput({
    required String name,
    required String number,
  }) {
    return name.trim().isNotEmpty && number.trim().isNotEmpty;
  }

  void addContact(EmergencyContact contact) {
    final updated = List<EmergencyContact>.from(state.contacts)..add(contact);
    emit(state.copyWith(contacts: _sorted(updated)));
  }

  void makePrimary(int index) {
    final updated = List<EmergencyContact>.from(state.contacts);
    if (index < 0 || index >= updated.length) return;
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(isPrimary: i == index);
    }
    emit(state.copyWith(contacts: _sorted(updated)));
  }

  void deleteContact(int index) {
    final updated = List<EmergencyContact>.from(state.contacts);
    if (index < 0 || index >= updated.length) return;
    updated.removeAt(index);
    emit(state.copyWith(contacts: _sorted(updated)));
  }

  static List<EmergencyContact> _sorted(List<EmergencyContact> contacts) {
    final sorted = List<EmergencyContact>.from(contacts);
    sorted.sort((a, b) {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return a.name.compareTo(b.name);
    });
    return sorted;
  }
}
