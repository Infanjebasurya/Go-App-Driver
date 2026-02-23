import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class RequestOtpRequested extends AuthEvent {
  const RequestOtpRequested({required this.phone});

  final String phone;

  @override
  List<Object?> get props => <Object?>[phone];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({
    required this.phone,
    required this.otp,
    required this.otpId,
  });

  final String phone;
  final String otp;
  final String otpId;

  @override
  List<Object?> get props => <Object?>[phone, otp, otpId];
}
