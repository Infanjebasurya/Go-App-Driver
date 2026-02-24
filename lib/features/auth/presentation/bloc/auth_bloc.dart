import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:goapp/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:goapp/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._loginUseCase, this._requestOtpUseCase)
    : super(const AuthInitial()) {
    on<RequestOtpRequested>(_onRequestOtpRequested);
    on<LoginRequested>(_onLoginRequested);
  }

  final LoginUseCase _loginUseCase;
  final RequestOtpUseCase _requestOtpUseCase;

  Future<void> _onRequestOtpRequested(
    RequestOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _requestOtpUseCase.call(phone: event.phone);
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (otpId) => emit(OtpRequestSuccess(otpId: otpId)),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _loginUseCase.call(
      phone: event.phone,
      otp: event.otp,
      otpId: event.otpId,
    );
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }
}
