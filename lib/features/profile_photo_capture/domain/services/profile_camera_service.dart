import 'package:camera/camera.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/profile_camera_frame.dart';

abstract interface class ProfileCameraService {
  CameraController? get controller;

  Future<void> initialize();

  Future<void> startImageStream(void Function(ProfileCameraFrame frame) onFrame);

  Future<XFile> takePicture();

  Future<void> stopImageStream();

  Future<void> dispose();
}

