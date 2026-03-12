import 'package:equatable/equatable.dart';

sealed class ProfilePhotoEvent extends Equatable {
  const ProfilePhotoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class ProfilePhotoStarted extends ProfilePhotoEvent {
  const ProfilePhotoStarted();
}

final class ProfilePhotoRetakeRequested extends ProfilePhotoEvent {
  const ProfilePhotoRetakeRequested();
}

