import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/home/presentation/cubit/enter_ride_code_state.dart';

class EnterRideCodeCubit extends Cubit<EnterRideCodeState> {
  EnterRideCodeCubit() : super(const EnterRideCodeState());

  void addDigit(String value) {
    if (state.digits.length >= 4) return;
    emit(state.copyWith(digits: <String>[...state.digits, value]));
  }

  void backspace() {
    if (state.digits.isEmpty) return;
    emit(state.copyWith(digits: state.digits.sublist(0, state.digits.length - 1)));
  }
}
