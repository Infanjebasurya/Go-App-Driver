import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:goapp/features/profile_photo_capture/domain/entities/processed_profile_photo.dart';

enum ProfilePhotoCaptureStatus {
  initial,
  permissionDenied,
  initializingCamera,
  detecting,
  capturing,
  processing,
  preview,
  failure,
}

enum FaceValidationStatus {
  noFace,
  multipleFaces,
  faceTooSmall,
  faceOutOfFrame,
  badAngle,
  holdStill,
  aligned,
}

class ProfilePhotoState extends Equatable {
  const ProfilePhotoState({
    required this.status,
    this.cameraController,
    this.faceStatus,
    this.guidanceText,
    this.isAutoCapturing = false,
    this.photo,
    this.errorMessage,
  });

  factory ProfilePhotoState.initial() {
    return const ProfilePhotoState(status: ProfilePhotoCaptureStatus.initial);
  }

  final ProfilePhotoCaptureStatus status;
  final CameraController? cameraController;
  final FaceValidationStatus? faceStatus;
  final String? guidanceText;
  final bool isAutoCapturing;
  final ProcessedProfilePhoto? photo;
  final String? errorMessage;

  static const Object _unset = Object();

  ProfilePhotoState copyWith({
    ProfilePhotoCaptureStatus? status,
    CameraController? cameraController,
    FaceValidationStatus? faceStatus,
    String? guidanceText,
    bool? isAutoCapturing,
    Object? photo = _unset,
    Object? errorMessage = _unset,
  }) {
    return ProfilePhotoState(
      status: status ?? this.status,
      cameraController: cameraController ?? this.cameraController,
      faceStatus: faceStatus ?? this.faceStatus,
      guidanceText: guidanceText ?? this.guidanceText,
      isAutoCapturing: isAutoCapturing ?? this.isAutoCapturing,
      photo: photo == _unset ? this.photo : photo as ProcessedProfilePhoto?,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        cameraController,
        faceStatus,
        guidanceText,
        isAutoCapturing,
        photo,
        errorMessage,
      ];
}
