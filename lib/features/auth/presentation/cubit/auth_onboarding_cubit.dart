import 'package:flutter_bloc/flutter_bloc.dart';

class AuthOnboardingCubit extends Cubit<bool> {
  AuthOnboardingCubit() : super(false);

  Future<void> markSeen() async {
    emit(true);
  }
}
