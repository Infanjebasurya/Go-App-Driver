import 'package:goapp/features/profile_photo_capture/domain/entities/processed_profile_photo.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/processed_jpeg_image.dart';

abstract interface class ProfilePhotoRepository {
  Future<ProcessedProfilePhoto> saveProcessedPhoto(ProcessedJpegImage image);
}

