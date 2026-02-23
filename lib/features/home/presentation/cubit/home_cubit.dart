import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/usecase/usecase.dart';
import 'package:goapp/features/home/domain/usecases/get_captain_profile.dart';
import 'package:goapp/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getCaptainProfile) : super(const HomeState());

  final GetCaptainProfile _getCaptainProfile;

  Future<void> loadCaptainProfile() async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: ''));
    final result = await _getCaptainProfile(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(
          status: HomeStatus.success,
          profile: profile,
          errorMessage: '',
        ),
      ),
    );
  }
}
