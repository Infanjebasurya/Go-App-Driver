import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:goapp/features/profile/domain/usecases/get_cached_profile_usecase.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_event.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(
    this._createProfileUseCase,
    this._getCachedProfileUseCase, {
    this.autoLoad = true,
  }) : super(const ProfileInitial()) {
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileSubmitted>(_onProfileSubmitted);
    if (autoLoad) add(const ProfileRequested());
  }

  final CreateProfileUseCase _createProfileUseCase;
  final GetCachedProfileUseCase _getCachedProfileUseCase;
  final bool autoLoad;

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getCachedProfileUseCase.call();
    result.fold((failure) => emit(ProfileFailure(failure.message)), (profile) {
      if (profile == null) {
        emit(const ProfileInitial());
      } else {
        emit(ProfileSuccess(profile));
      }
    });
  }

  Future<void> _onProfileSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _createProfileUseCase.call(
      name: event.name,
      email: event.email,
      gender: event.gender,
      dob: event.dob,
      refer: event.refer,
      emergencyContact: event.emergencyContact,
    );
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (profile) => emit(ProfileSuccess(profile)),
    );
  }
}
