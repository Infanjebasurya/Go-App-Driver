import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/domain/services/phone_number_service.dart';
import 'package:goapp/features/auth/presentation/cubit/login_form_state.dart';

class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit({required PhoneNumberService phoneNumberService})
      : _phoneNumberService = phoneNumberService,
        super(const LoginFormState());

  final PhoneNumberService _phoneNumberService;

  void reset() {
    emit(const LoginFormState());
  }

  void onInputChanged(String input) {
    final digits = _phoneNumberService.normalizeDigits(input);
    final error = _phoneNumberService.validateIndiaMobile(
      rawInput: input,
      digits: digits,
    );
    emit(
      state.copyWith(
        digits: digits,
        rawInput: input,
        phoneE164: _phoneNumberService.toE164India(digits),
        error: error,
        submitRequested: false,
        clearSubmitError: true,
      ),
    );
  }

  void submit() {
    final error = _phoneNumberService.validateIndiaMobile(
      rawInput: state.rawInput,
      digits: state.digits,
    );
    if (error != null) {
      emit(state.copyWith(submitError: error, submitRequested: false));
      return;
    }
    emit(state.copyWith(submitRequested: true, clearSubmitError: true));
  }

  void consumeSubmit() {
    emit(state.copyWith(submitRequested: false));
  }
}
