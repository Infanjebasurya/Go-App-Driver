import 'package:goapp/features/profile/domain/entities/profile.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  const ProfileSuccess(this.profile);

  final Profile profile;
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;
}
