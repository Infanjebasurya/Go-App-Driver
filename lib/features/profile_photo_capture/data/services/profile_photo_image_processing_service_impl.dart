import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/processed_jpeg_image.dart';
import 'package:goapp/features/profile_photo_capture/domain/services/profile_photo_image_processing_service.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class ProfilePhotoImageProcessingServiceImpl
    implements ProfilePhotoImageProcessingService {
  ProfilePhotoImageProcessingServiceImpl({FaceDetector? detector})
    : _detector =
          detector ??
          FaceDetector(
            options: FaceDetectorOptions(
              performanceMode: FaceDetectorMode.accurate,
              enableTracking: false,
              enableContours: false,
              enableLandmarks: false,
              enableClassification: false,
              minFaceSize: 0.05,
            ),
          );

  static const int _outWidth = 413;
  static const int _outHeight = 531;
  static const double _aspect = 3.5 / 4.5;

  final FaceDetector _detector;

  @override
  Future<ProcessedJpegImage> processCapturedImage(
    String capturedImagePath,
  ) async {
    final InputImage input = InputImage.fromFilePath(capturedImagePath);
    final List<Face> faces = await _detector.processImage(input);

    if (faces.isEmpty) {
      throw StateError('No face detected in captured image.');
    }
    if (faces.length > 1) {
      throw StateError('Multiple faces detected in captured image.');
    }

    final Uint8List fileBytes = await File(capturedImagePath).readAsBytes();
    final img.Image? decoded = img.decodeImage(fileBytes);
    if (decoded == null) {
      throw StateError('Failed to decode captured image.');
    }

    final img.Image baked = img.bakeOrientation(decoded);
    final Rect faceBox = faces.single.boundingBox;

    final img.Image cropped = _cropHeadAndShoulders(baked, faceBox: faceBox);

    final img.Image resized = img.copyResize(
      cropped,
      width: _outWidth,
      height: _outHeight,
      interpolation: img.Interpolation.average,
    );

    final Uint8List jpeg = Uint8List.fromList(
      img.encodeJpg(resized, quality: 95),
    );
    final Uint8List compressed = await _compressJpeg(jpeg);

    return ProcessedJpegImage(
      bytes: compressed,
      widthPx: _outWidth,
      heightPx: _outHeight,
    );
  }

  img.Image _cropHeadAndShoulders(img.Image image, {required Rect faceBox}) {
    final double faceHeight = faceBox.height;
    final double targetFaceCoverage = 0.75; // 70–80% target range

    final double cropHeight = faceHeight / targetFaceCoverage;
    final double cropWidth = cropHeight * _aspect;

    final double centerX = faceBox.center.dx;
    final double centerY =
        faceBox.center.dy + faceHeight * 0.15; // bias down to include shoulders

    Rect crop = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: cropWidth,
      height: cropHeight,
    );

    crop = _clampRectToImage(
      crop,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final int left = crop.left.round();
    final int top = crop.top.round();
    final int width = crop.width.round();
    final int height = crop.height.round();

    return img.copyCrop(
      image,
      x: left,
      y: top,
      width: max(1, width),
      height: max(1, height),
    );
  }

  Rect _clampRectToImage(Rect rect, double w, double h) {
    double left = rect.left;
    double top = rect.top;
    double right = rect.right;
    double bottom = rect.bottom;

    if (left < 0) {
      right -= left;
      left = 0;
    }
    if (top < 0) {
      bottom -= top;
      top = 0;
    }
    if (right > w) {
      left -= right - w;
      right = w;
    }
    if (bottom > h) {
      top -= bottom - h;
      bottom = h;
    }

    left = left.clamp(0, w).toDouble();
    top = top.clamp(0, h).toDouble();
    right = right.clamp(0, w).toDouble();
    bottom = bottom.clamp(0, h).toDouble();

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Future<Uint8List> _compressJpeg(Uint8List jpegBytes) async {
    final Uint8List out = await FlutterImageCompress.compressWithList(
      jpegBytes,
      quality: 85,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    return out;
  }
}
