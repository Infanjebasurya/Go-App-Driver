import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/profile_camera_frame.dart';
import 'package:goapp/features/profile_photo_capture/domain/services/profile_camera_service.dart';

class CameraServiceImpl implements ProfileCameraService {
  CameraServiceImpl({CameraController? controller}) : _controller = controller;

  CameraController? _controller;

  @override
  CameraController? get controller => _controller;

  @override
  Future<void> initialize() async {
    if (_controller != null) return;

    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription selected = cameras.firstWhere(
      (CameraDescription c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final CameraController controller = CameraController(
      selected,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await controller.initialize();
    await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    _controller = controller;
  }

  @override
  Future<void> startImageStream(
    void Function(ProfileCameraFrame frame) onFrame,
  ) async {
    final CameraController? controller = _controller;
    if (controller == null) {
      throw StateError('Camera not initialized.');
    }
    if (controller.value.isStreamingImages) return;

    await controller.startImageStream((CameraImage image) {
      final _FrameBytes frameBytes = _bytesFor(image);

      onFrame(
        ProfileCameraFrame(
          bytes: frameBytes.bytes,
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: _rotationFor(controller),
          format: frameBytes.format,
          bytesPerRow: frameBytes.bytesPerRow,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  @override
  Future<XFile> takePicture() async {
    final CameraController? controller = _controller;
    if (controller == null) {
      throw StateError('Camera not initialized.');
    }
    if (controller.value.isTakingPicture) {
      throw StateError('Camera is already taking a picture.');
    }
    return controller.takePicture();
  }

  @override
  Future<void> stopImageStream() async {
    final CameraController? controller = _controller;
    if (controller == null) return;
    if (!controller.value.isStreamingImages) return;
    await controller.stopImageStream();
  }

  @override
  Future<void> dispose() async {
    final CameraController? controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  _FrameBytes _bytesFor(CameraImage image) {
    final ImageFormatGroup group = image.format.group;

    if (Platform.isAndroid && group == ImageFormatGroup.yuv420) {
      final Uint8List bytes = _yuv420888ToNv21(image);
      final int bytesPerRow = 0; // not used on Android by google_mlkit_commons
      return _FrameBytes(
        bytes: bytes,
        bytesPerRow: bytesPerRow,
        format: ProfileImageFormat.nv21,
      );
    }

    if (group == ImageFormatGroup.bgra8888 && image.planes.isNotEmpty) {
      final Plane plane = image.planes.first;
      return _FrameBytes(
        bytes: plane.bytes,
        bytesPerRow: plane.bytesPerRow,
        format: ProfileImageFormat.bgra8888,
      );
    }

    final Uint8List bytes = _concatenatePlanes(image.planes);
    final int bytesPerRow = image.planes.isNotEmpty
        ? image.planes.first.bytesPerRow
        : 0;
    return _FrameBytes(
      bytes: bytes,
      bytesPerRow: bytesPerRow,
      format: group == ImageFormatGroup.yuv420
          ? ProfileImageFormat.yuv420
          : ProfileImageFormat.yuv420888,
    );
  }

  Uint8List _yuv420888ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    if (image.planes.length < 3) {
      return _concatenatePlanes(image.planes);
    }

    final Plane yPlane = image.planes[0];
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final int yRowStride = yPlane.bytesPerRow;
    final int yPixelStride = yPlane.bytesPerPixel ?? 1;
    final int uRowStride = uPlane.bytesPerRow;
    final int uPixelStride = uPlane.bytesPerPixel ?? 1;
    final int vRowStride = vPlane.bytesPerRow;
    final int vPixelStride = vPlane.bytesPerPixel ?? 1;

    final Uint8List out = Uint8List(width * height + (width * height) ~/ 2);

    int outIndex = 0;
    for (int row = 0; row < height; row++) {
      final int rowStart = row * yRowStride;
      for (int col = 0; col < width; col++) {
        out[outIndex++] = yPlane.bytes[rowStart + col * yPixelStride];
      }
    }

    int uvIndex = width * height;
    final int chromaHeight = height ~/ 2;
    final int chromaWidth = width ~/ 2;

    for (int row = 0; row < chromaHeight; row++) {
      final int uRowStart = row * uRowStride;
      final int vRowStart = row * vRowStride;
      for (int col = 0; col < chromaWidth; col++) {
        final int uIndex = uRowStart + col * uPixelStride;
        final int vIndex = vRowStart + col * vPixelStride;
        out[uvIndex++] = vPlane.bytes[vIndex];
        out[uvIndex++] = uPlane.bytes[uIndex];
      }
    }

    return out;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    if (planes.isEmpty) return Uint8List(0);
    final WriteBuffer buffer = WriteBuffer();
    for (final Plane plane in planes) {
      buffer.putUint8List(plane.bytes);
    }
    return buffer.done().buffer.asUint8List();
  }

  ProfileImageRotation _rotationFor(CameraController controller) {
    final int sensorOrientation = controller.description.sensorOrientation;
    final int deviceDegrees = _deviceOrientationDegrees(
      controller.value.deviceOrientation,
    );

    final int rotationDegrees = switch (controller.description.lensDirection) {
      CameraLensDirection.front =>
        (sensorOrientation - deviceDegrees + 360) % 360,
      _ => (sensorOrientation + deviceDegrees) % 360,
    };

    return switch (rotationDegrees) {
      90 => ProfileImageRotation.rotation90,
      180 => ProfileImageRotation.rotation180,
      270 => ProfileImageRotation.rotation270,
      _ => ProfileImageRotation.rotation0,
    };
  }

  int _deviceOrientationDegrees(DeviceOrientation? orientation) {
    return switch (orientation) {
      DeviceOrientation.landscapeLeft => 90,
      DeviceOrientation.portraitDown => 180,
      DeviceOrientation.landscapeRight => 270,
      _ => 0,
    };
  }
}

class _FrameBytes {
  const _FrameBytes({
    required this.bytes,
    required this.bytesPerRow,
    required this.format,
  });

  final Uint8List bytes;
  final int bytesPerRow;
  final ProfileImageFormat format;
}
