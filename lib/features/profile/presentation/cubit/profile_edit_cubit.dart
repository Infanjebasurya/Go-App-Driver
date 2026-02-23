import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit({
    Duration loadDelay = const Duration(milliseconds: 500),
    Duration saveDelay = const Duration(milliseconds: 700),
    Duration statusResetDelay = const Duration(milliseconds: 400),
    Duration actionDelay = const Duration(milliseconds: 800),
  }) : _loadDelay = loadDelay,
       _saveDelay = saveDelay,
       _statusResetDelay = statusResetDelay,
       _actionDelay = actionDelay,
       super(const ProfileEditState()) {
    loadProfile();
  }

  final Duration _loadDelay;
  final Duration _saveDelay;
  final Duration _statusResetDelay;
  final Duration _actionDelay;

  static const ProfileEditData _mockProfile = ProfileEditData(
    fullName: 'Sam Yogesh',
    email: 'michael.rodriguez@email.com',
    phone: '+91 99446 63355',
    gender: 'Male',
    dateOfBirth: 'March 15, 1990',
    rating: 4.98,
    totalTrips: 1240,
    totalYears: 1.5,
  );

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileEditStatus.loading));
    await Future<void>.delayed(_loadDelay);
    emit(
      const ProfileEditState(
        status: ProfileEditStatus.loaded,
        data: _mockProfile,
      ),
    );
  }

  Future<void> updateFullName(String name) async {
    if (state.data == null || name.trim().isEmpty) return;
    emit(state.copyWith(status: ProfileEditStatus.saving));
    await Future<void>.delayed(_saveDelay);
    emit(
      state.copyWith(
        status: ProfileEditStatus.saved,
        data: state.data!.copyWith(fullName: name.trim()),
      ),
    );
    await Future<void>.delayed(_statusResetDelay);
    emit(state.copyWith(status: ProfileEditStatus.loaded));
  }

  Future<void> updateEmail(String email) async {
    if (state.data == null || email.trim().isEmpty) return;
    emit(state.copyWith(status: ProfileEditStatus.saving));
    await Future<void>.delayed(_saveDelay);
    emit(
      state.copyWith(
        status: ProfileEditStatus.saved,
        data: state.data!.copyWith(email: email.trim()),
      ),
    );
    await Future<void>.delayed(_statusResetDelay);
    emit(state.copyWith(status: ProfileEditStatus.loaded));
  }

  Future<void> logout() async {
    emit(state.copyWith(status: ProfileEditStatus.saving));
    await Future<void>.delayed(_actionDelay);
    emit(state.copyWith(status: ProfileEditStatus.loggedOut));
  }

  Future<void> deleteAccount() async {
    emit(state.copyWith(status: ProfileEditStatus.saving));
    await Future<void>.delayed(_actionDelay);
    emit(state.copyWith(status: ProfileEditStatus.deleted));
  }
}
