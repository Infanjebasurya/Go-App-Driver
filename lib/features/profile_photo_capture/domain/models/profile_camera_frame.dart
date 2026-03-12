import 'dart:typed_data';

import 'package:flutter/material.dart';

enum ProfileImageRotation { rotation0, rotation90, rotation180, rotation270 }

enum ProfileImageFormat { nv21, yuv420888, yuv420, bgra8888 }

class ProfileCameraFrame {
  const ProfileCameraFrame({
    required this.bytes,
    required this.size,
    required this.rotation,
    required this.format,
    required this.bytesPerRow,
    required this.timestampMs,
  });

  final Uint8List bytes;
  final Size size;
  final ProfileImageRotation rotation;
  final ProfileImageFormat format;
  final int bytesPerRow;
  final int timestampMs;
}
