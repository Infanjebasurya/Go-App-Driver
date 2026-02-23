import 'package:equatable/equatable.dart';

class SosContact extends Equatable {
  const SosContact({required this.name, required this.status});

  final String name;
  final String status;

  SosContact copyWith({String? status}) {
    return SosContact(name: name, status: status ?? this.status);
  }

  @override
  List<Object> get props => <Object>[name, status];
}

class SosState extends Equatable {
  const SosState({
    this.contacts = const <SosContact>[
      SosContact(name: 'Elizabeth (Wife)', status: 'Not sent'),
      SosContact(name: 'Michael (Assistant)', status: 'Not sent'),
    ],
    this.isSafe = false,
  });

  final List<SosContact> contacts;
  final bool isSafe;

  SosState copyWith({List<SosContact>? contacts, bool? isSafe}) {
    return SosState(
      contacts: contacts ?? this.contacts,
      isSafe: isSafe ?? this.isSafe,
    );
  }

  @override
  List<Object> get props => <Object>[contacts, isSafe];
}
