import 'package:equatable/equatable.dart';
import 'package:goapp/features/auth/domain/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => <Object?>[];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class OtpRequestSuccess extends AuthState {
  const OtpRequestSuccess({required this.otpId});

  final String otpId;

  @override
  List<Object?> get props => <Object?>[otpId];
}

class AuthSuccess extends AuthState {
  const AuthSuccess({required this.user});

  final User user;

  @override
  List<Object?> get props => <Object?>[user];
}

class AuthFailure extends AuthState {
  const AuthFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
