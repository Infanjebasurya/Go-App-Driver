import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:goapp/features/profile_photo_capture/domain/entities/detected_face.dart';

abstract class LiveFaceDetectionService {
  Future<List<DetectedFace>> detect(InputImage image);
  Future<void> close();
}

