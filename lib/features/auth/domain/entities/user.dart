import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, required this.phone});

  final String id;
  final String phone;

  @override
  List<Object?> get props => <Object?>[id, phone];
}
