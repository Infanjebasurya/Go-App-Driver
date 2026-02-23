import 'package:equatable/equatable.dart';

class EnterRideCodeState extends Equatable {
  const EnterRideCodeState({this.digits = const <String>[]});

  final List<String> digits;

  bool get canStart => digits.length == 4;

  EnterRideCodeState copyWith({List<String>? digits}) {
    return EnterRideCodeState(digits: digits ?? this.digits);
  }

  @override
  List<Object> get props => <Object>[digits];
}
