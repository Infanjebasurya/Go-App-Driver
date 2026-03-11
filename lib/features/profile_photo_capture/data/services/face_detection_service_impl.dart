import 'dart:async';

import 'package:goapp/features/profile_photo_capture/domain/models/detected_face.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/face_detection_snapshot.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/profile_camera_frame.dart';
import 'package:goapp/features/profile_photo_capture/domain/services/face_detection_service.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionServiceImpl implements FaceDetectionService {
  FaceDetectionServiceImpl({FaceDetector? detector})
    : _detector =
          detector ??
          FaceDetector(
            options: FaceDetectorOptions(
              performanceMode: FaceDetectorMode.fast,
              enableLandmarks: false,
              enableContours: false,
              enableClassification: false,
              enableTracking: true,
              minFaceSize: 0.05,
            ),
          );

  final FaceDetector _detector;
  bool _closed = false;

  @override
  Future<FaceDetectionSnapshot> detect(ProfileCameraFrame frame) async {
    if (_closed) throw StateError('FaceDetectionService has been disposed.');

    final InputImageRotation rotation = _mapRotation(frame.rotation);
    final InputImageFormat format = _mapFormat(frame.format);

    final InputImage input = InputImage.fromBytes(
      bytes: frame.bytes,
      metadata: InputImageMetadata(
        size: frame.size,
        rotation: rotation,
        format: format,
        bytesPerRow: frame.bytesPerRow,
      ),
    );

    final List<Face> faces = await _detector.processImage(input);
    return FaceDetectionSnapshot(
      imageSize: frame.size,
      faces: faces
          .map(
            (Face f) => DetectedFace(
              boundingBox: f.boundingBox,
              headEulerAngleX: f.headEulerAngleX,
              headEulerAngleY: f.headEulerAngleY,
              headEulerAngleZ: f.headEulerAngleZ,
            ),
          )
          .toList(growable: false),
      timestampMs: frame.timestampMs,
    );
  }

  @override
  Future<void> dispose() async {
    _closed = true;
    await _detector.close();
  }

  InputImageRotation _mapRotation(ProfileImageRotation rotation) {
    return switch (rotation) {
      ProfileImageRotation.rotation90 => InputImageRotation.rotation90deg,
      ProfileImageRotation.rotation180 => InputImageRotation.rotation180deg,
      ProfileImageRotation.rotation270 => InputImageRotation.rotation270deg,
      ProfileImageRotation.rotation0 => InputImageRotation.rotation0deg,
    };
  }

  InputImageFormat _mapFormat(ProfileImageFormat format) {
    return switch (format) {
      ProfileImageFormat.nv21 => InputImageFormat.nv21,
      ProfileImageFormat.yuv420888 => InputImageFormat.yuv_420_888,
      ProfileImageFormat.bgra8888 => InputImageFormat.bgra8888,
      ProfileImageFormat.yuv420 => InputImageFormat.yuv420,
    };
  }
}
