import 'package:equatable/equatable.dart';

class LoginFormState extends Equatable {
  const LoginFormState({
    this.digits = '',
    this.phoneE164,
    this.error,
    this.submitRequested = false,
    this.submitError,
  });

  final String digits;
  final String? phoneE164;
  final String? error;
  final bool submitRequested;
  final String? submitError;

  LoginFormState copyWith({
    String? digits,
    String? phoneE164,
    String? error,
    bool? submitRequested,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return LoginFormState(
      digits: digits ?? this.digits,
      phoneE164: phoneE164 ?? this.phoneE164,
      error: error,
      submitRequested: submitRequested ?? this.submitRequested,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    digits,
    phoneE164,
    error,
    submitRequested,
    submitError,
  ];
}
