import 'package:equatable/equatable.dart';
import 'package:goapp/features/profile_photo_capture/domain/entities/processed_profile_photo.dart';

enum ProfilePhotoCaptureStatus {
  initial,
  permissionDenied,
  capturing,
  processing,
  preview,
  failure,
}

class ProfilePhotoState extends Equatable {
  const ProfilePhotoState({
    required this.status,
    this.photo,
    this.errorMessage,
  });

  factory ProfilePhotoState.initial() {
    return const ProfilePhotoState(status: ProfilePhotoCaptureStatus.initial);
  }

  final ProfilePhotoCaptureStatus status;
  final ProcessedProfilePhoto? photo;
  final String? errorMessage;

  static const Object _unset = Object();

  ProfilePhotoState copyWith({
    ProfilePhotoCaptureStatus? status,
    Object? photo = _unset,
    Object? errorMessage = _unset,
  }) {
    return ProfilePhotoState(
      status: status ?? this.status,
      photo: photo == _unset ? this.photo : photo as ProcessedProfilePhoto?,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        photo,
        errorMessage,
      ];
}
