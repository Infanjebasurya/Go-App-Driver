import 'dart:math';

import 'package:flutter/material.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/detected_face.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/face_detection_snapshot.dart';
import 'package:goapp/features/profile_photo_capture/presentation/bloc/profile_photo_state.dart';

class ProfilePhotoValidator {
  static const double passportAspect = 3.5 / 4.5;

  static const Duration autoCaptureHold = Duration(milliseconds: 1200);

  static const double maxYawDeg = 12;
  static const double maxPitchDeg = 10;
  static const double maxRollDeg = 10;

  static const double minFaceHeightRatio = 0.26;
  static const double maxCenterDeltaRatio = 0.05;

  // Keep these in sync with the oval overlay so the UI matches the validation.
  static const double guideWidthRatio = 0.70;
  static const double guideMaxHeightRatio = 0.74;

  Rect guideRectFor(Size imageSize) {
    final double w = imageSize.width;
    final double h = imageSize.height;

    double guideW = w * guideWidthRatio;
    double guideH = guideW / passportAspect;

    final double maxH = h * guideMaxHeightRatio;
    if (guideH > maxH) {
      guideH = maxH;
      guideW = guideH * passportAspect;
    }

    return Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width: guideW,
      height: guideH,
    );
  }

  FaceValidationStatus validate(
    FaceDetectionSnapshot snapshot, {
    required Rect guideRect,
    required DetectedFace? previousFace,
  }) {
    if (snapshot.faces.isEmpty) return FaceValidationStatus.noFace;
    if (snapshot.faces.length > 1) return FaceValidationStatus.multipleFaces;

    final DetectedFace face = snapshot.faces.single;
    final Rect box = face.boundingBox;

    final double minHeight = guideRect.height * minFaceHeightRatio;
    if (box.height < minHeight) return FaceValidationStatus.faceTooSmall;

    // Avoid strict "bounding box fully inside" checks; on many devices the
    // overlay and ML Kit coordinates won't match perfectly, preventing "aligned"
    // from ever being reached. Use a center-tolerance approach instead.
    final Rect centerGuide = guideRect.deflate(guideRect.width * 0.10);
    if (!centerGuide.contains(box.center)) {
      return FaceValidationStatus.faceOutOfFrame;
    }

    final double yaw = (face.headEulerAngleY ?? 0).abs();
    final double pitch = (face.headEulerAngleX ?? 0).abs();
    final double roll = (face.headEulerAngleZ ?? 0).abs();
    if (yaw > maxYawDeg || pitch > maxPitchDeg || roll > maxRollDeg) {
      return FaceValidationStatus.badAngle;
    }

    if (previousFace != null) {
      final Offset prev = previousFace.boundingBox.center;
      final Offset cur = face.boundingBox.center;
      final double dx =
          (cur.dx - prev.dx).abs() / max(1, snapshot.imageSize.width);
      final double dy =
          (cur.dy - prev.dy).abs() / max(1, snapshot.imageSize.height);
      if (dx > maxCenterDeltaRatio || dy > maxCenterDeltaRatio) {
        return FaceValidationStatus.holdStill;
      }
    }

    return FaceValidationStatus.aligned;
  }

  String guidanceFor(FaceValidationStatus status) {
    return switch (status) {
      FaceValidationStatus.noFace => 'No face detected',
      FaceValidationStatus.multipleFaces => 'Only one face allowed',
      FaceValidationStatus.faceTooSmall => 'Move closer',
      FaceValidationStatus.faceOutOfFrame => 'Align your face in the frame',
      FaceValidationStatus.badAngle => 'Look straight at the camera',
      FaceValidationStatus.holdStill => 'Hold still',
      FaceValidationStatus.aligned => 'Great, hold still…',
    };
  }
}
