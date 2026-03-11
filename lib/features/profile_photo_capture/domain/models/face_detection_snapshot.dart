import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/detected_face.dart';

class FaceDetectionSnapshot extends Equatable {
  const FaceDetectionSnapshot({
    required this.imageSize,
    required this.faces,
    required this.timestampMs,
  });

  final Size imageSize;
  final List<DetectedFace> faces;
  final int timestampMs;

  @override
  List<Object?> get props => <Object?>[imageSize, faces, timestampMs];
}

