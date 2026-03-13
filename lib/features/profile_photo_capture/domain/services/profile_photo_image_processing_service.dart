import 'package:goapp/features/profile_photo_capture/domain/models/processed_jpeg_image.dart';

abstract interface class ProfilePhotoImageProcessingService {
  Future<ProcessedJpegImage> processCapturedImage(String capturedImagePath);
}
