import 'package:goapp/core/usecase/usecase.dart';
import 'package:goapp/features/profile_photo_capture/domain/entities/processed_profile_photo.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/processed_jpeg_image.dart';
import 'package:goapp/features/profile_photo_capture/domain/repositories/profile_photo_repository.dart';

class SaveProfilePhotoUseCase
    implements UseCase<ProcessedProfilePhoto, ProcessedJpegImage> {
  const SaveProfilePhotoUseCase(this._repository);

  final ProfilePhotoRepository _repository;

  @override
  Future<ProcessedProfilePhoto> call(ProcessedJpegImage params) {
    return _repository.saveProcessedPhoto(params);
  }
}
