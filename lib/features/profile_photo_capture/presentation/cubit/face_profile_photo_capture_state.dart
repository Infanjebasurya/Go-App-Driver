import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:goapp/features/profile_photo_capture/domain/entities/processed_profile_photo.dart';

enum FaceProfileCaptureStatus {
  initializing,
  permissionDenied,
  scanning,
  capturing,
  processing,
  preview,
  failure,
  timeout,
}

class FaceProfilePhotoCaptureState extends Equatable {
  const FaceProfilePhotoCaptureState({
    required this.status,
    required this.message,
    required this.stabilityProgress,
    required this.debugFaceBox,
    required this.photo,
    required this.cameraReadyNonce,
  });

  factory FaceProfilePhotoCaptureState.initial() {
    return const FaceProfilePhotoCaptureState(
      status: FaceProfileCaptureStatus.initializing,
      message: 'Initializing camera...',
      stabilityProgress: 0,
      debugFaceBox: null,
      photo: null,
      cameraReadyNonce: 0,
    );
  }

  final FaceProfileCaptureStatus status;
  final String message;
  final double stabilityProgress;
  final Rect? debugFaceBox; // normalized (0..1) in image coordinates
  final ProcessedProfilePhoto? photo;
  final int cameraReadyNonce;

  FaceProfilePhotoCaptureState copyWith({
    FaceProfileCaptureStatus? status,
    String? message,
    double? stabilityProgress,
    Rect? debugFaceBox,
    bool clearDebugFaceBox = false,
    ProcessedProfilePhoto? photo,
    bool clearPhoto = false,
    int? cameraReadyNonce,
  }) {
    return FaceProfilePhotoCaptureState(
      status: status ?? this.status,
      message: message ?? this.message,
      stabilityProgress: stabilityProgress ?? this.stabilityProgress,
      debugFaceBox: clearDebugFaceBox
          ? null
          : (debugFaceBox ?? this.debugFaceBox),
      photo: clearPhoto ? null : (photo ?? this.photo),
      cameraReadyNonce: cameraReadyNonce ?? this.cameraReadyNonce,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    message,
    stabilityProgress,
    debugFaceBox,
    photo,
    cameraReadyNonce,
  ];
}
