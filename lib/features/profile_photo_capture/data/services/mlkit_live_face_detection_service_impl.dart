import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:goapp/features/profile_photo_capture/domain/entities/detected_face.dart';
import 'package:goapp/features/profile_photo_capture/domain/services/live_face_detection_service.dart';

class MlkitLiveFaceDetectionServiceImpl implements LiveFaceDetectionService {
  MlkitLiveFaceDetectionServiceImpl()
    : _detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          enableClassification: true,
          enableTracking: true,
          enableLandmarks: false,
          enableContours: false,
        ),
      );

  final FaceDetector _detector;

  @override
  Future<List<DetectedFace>> detect(InputImage image) async {
    final faces = await _detector.processImage(image);
    return faces
        .map(
          (f) => DetectedFace(
            boundingBox: f.boundingBox,
            trackingId: f.trackingId,
            headEulerAngleX: f.headEulerAngleX,
            headEulerAngleY: f.headEulerAngleY,
            headEulerAngleZ: f.headEulerAngleZ,
            leftEyeOpenProbability: f.leftEyeOpenProbability,
            rightEyeOpenProbability: f.rightEyeOpenProbability,
            smilingProbability: f.smilingProbability,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> close() {
    return _detector.close();
  }
}
