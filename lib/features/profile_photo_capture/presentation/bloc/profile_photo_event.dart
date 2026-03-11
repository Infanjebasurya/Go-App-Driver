import 'package:equatable/equatable.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/profile_camera_frame.dart';

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

final class ProfilePhotoFrameArrived extends ProfilePhotoEvent {
  const ProfilePhotoFrameArrived(this.frame);

  final ProfileCameraFrame frame;

  @override
  List<Object?> get props => <Object?>[frame];
}

