import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:goapp/core/service/path_provider_service.dart';
import 'package:goapp/features/profile_photo_capture/domain/entities/processed_profile_photo.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/processed_jpeg_image.dart';
import 'package:goapp/features/profile_photo_capture/domain/repositories/profile_photo_repository.dart';

class ProfilePhotoRepositoryImpl implements ProfilePhotoRepository {
  const ProfilePhotoRepositoryImpl({required PathProviderService pathProvider})
      : _pathProvider = pathProvider;

  final PathProviderService _pathProvider;

  @override
  Future<ProcessedProfilePhoto> saveProcessedPhoto(ProcessedJpegImage image) async {
    final Directory root = await _pathProvider.getApplicationDocumentsDirectory();
    final Directory dir = Directory(p.join(root.path, 'profile_photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final String fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}_${image.widthPx}x${image.heightPx}.jpg';
    final File out = File(p.join(dir.path, fileName));
    await out.writeAsBytes(image.bytes, flush: true);

    return ProcessedProfilePhoto(path: out.path, widthPx: image.widthPx, heightPx: image.heightPx);
  }
}

