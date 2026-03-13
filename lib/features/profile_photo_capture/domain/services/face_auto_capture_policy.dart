import 'dart:ui';

import 'package:goapp/features/profile_photo_capture/domain/entities/detected_face.dart';

enum FaceFrameStatus {
  noFace,
  multipleFaces,
  tooSmall,
  offCenter,
  tilted,
  eyesClosed,
  ok,
}

class FaceFrameEvaluation {
  const FaceFrameEvaluation({
    required this.status,
    required this.primaryFace,
    required this.normalizedFaceBox,
    required this.message,
  });

  final FaceFrameStatus status;
  final DetectedFace? primaryFace;
  final Rect? normalizedFaceBox;
  final String message;

  bool get isOk => status == FaceFrameStatus.ok;
}

class FaceAutoCapturePolicy {
  const FaceAutoCapturePolicy({
    this.centerTolerance = 0.15,
    this.minFaceHeightFraction = 0.12,
    this.maxFaceHeightFraction = 0.65,
    this.maxAbsYawDeg = 18,
    this.maxAbsRollDeg = 18,
    this.maxAbsPitchDeg = 18,
    this.minEyeOpenProbability = 0.25,
    this.requireEyesOpen = false,
  });

  final double centerTolerance;
  final double minFaceHeightFraction;
  final double maxFaceHeightFraction;
  final double maxAbsYawDeg;
  final double maxAbsRollDeg;
  final double maxAbsPitchDeg;
  final double minEyeOpenProbability;
  final bool requireEyesOpen;

  FaceFrameEvaluation evaluate({
    required List<DetectedFace> faces,
    required Size imageSize,
  }) {
    if (faces.isEmpty) {
      return const FaceFrameEvaluation(
        status: FaceFrameStatus.noFace,
        primaryFace: null,
        normalizedFaceBox: null,
        message: 'No face detected',
      );
    }
    if (faces.length > 1) {
      return const FaceFrameEvaluation(
        status: FaceFrameStatus.multipleFaces,
        primaryFace: null,
        normalizedFaceBox: null,
        message: 'Multiple faces detected',
      );
    }

    final DetectedFace face = faces.first;
    final Rect box = face.boundingBox;
    if (imageSize.width <= 0 || imageSize.height <= 0) {
      return FaceFrameEvaluation(
        status: FaceFrameStatus.noFace,
        primaryFace: face,
        normalizedFaceBox: null,
        message: 'Initializing camera...',
      );
    }

    final Rect normalized = Rect.fromLTRB(
      (box.left / imageSize.width).clamp(0.0, 1.0),
      (box.top / imageSize.height).clamp(0.0, 1.0),
      (box.right / imageSize.width).clamp(0.0, 1.0),
      (box.bottom / imageSize.height).clamp(0.0, 1.0),
    );

    final double faceHeight = normalized.height;
    if (faceHeight < minFaceHeightFraction) {
      return FaceFrameEvaluation(
        status: FaceFrameStatus.tooSmall,
        primaryFace: face,
        normalizedFaceBox: normalized,
        message: 'Move closer',
      );
    }
    if (faceHeight > maxFaceHeightFraction) {
      return FaceFrameEvaluation(
        status: FaceFrameStatus.tooSmall,
        primaryFace: face,
        normalizedFaceBox: normalized,
        message: 'Move a bit away',
      );
    }

    final Offset c = normalized.center;
    final bool centered =
        (c.dx - 0.5).abs() <= centerTolerance &&
        (c.dy - 0.5).abs() <= centerTolerance;
    if (!centered) {
      return FaceFrameEvaluation(
        status: FaceFrameStatus.offCenter,
        primaryFace: face,
        normalizedFaceBox: normalized,
        message: 'Center your face',
      );
    }

    final double yaw = (face.headEulerAngleY ?? 0).abs();
    final double roll = (face.headEulerAngleZ ?? 0).abs();
    final double pitch = (face.headEulerAngleX ?? 0).abs();
    if (yaw > maxAbsYawDeg || roll > maxAbsRollDeg || pitch > maxAbsPitchDeg) {
      return FaceFrameEvaluation(
        status: FaceFrameStatus.tilted,
        primaryFace: face,
        normalizedFaceBox: normalized,
        message: 'Keep your head straight',
      );
    }

    if (requireEyesOpen) {
      final double left = face.leftEyeOpenProbability ?? 1.0;
      final double right = face.rightEyeOpenProbability ?? 1.0;
      if (left < minEyeOpenProbability || right < minEyeOpenProbability) {
        return FaceFrameEvaluation(
          status: FaceFrameStatus.eyesClosed,
          primaryFace: face,
          normalizedFaceBox: normalized,
          message: 'Keep your eyes open',
        );
      }
    }

    return FaceFrameEvaluation(
      status: FaceFrameStatus.ok,
      primaryFace: face,
      normalizedFaceBox: normalized,
      message: 'Hold still',
    );
  }
}
