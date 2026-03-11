import 'package:goapp/features/profile_photo_capture/domain/models/face_detection_snapshot.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/profile_camera_frame.dart';

abstract interface class FaceDetectionService {
  Future<FaceDetectionSnapshot> detect(ProfileCameraFrame frame);

  Future<void> dispose();
}

