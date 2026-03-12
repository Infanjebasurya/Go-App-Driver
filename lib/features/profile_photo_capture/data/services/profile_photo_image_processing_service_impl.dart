import 'package:flutter/services.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/processed_jpeg_image.dart';
import 'package:goapp/features/profile_photo_capture/domain/services/profile_photo_image_processing_service.dart';

class ProfilePhotoImageProcessingServiceImpl
    implements ProfilePhotoImageProcessingService {
  ProfilePhotoImageProcessingServiceImpl();

  static const MethodChannel _channel =
      MethodChannel('app/profile_photo_processing_service');

  @override
  Future<ProcessedJpegImage> processCapturedImage(
    String capturedImagePath,
  ) async {
    final Map<Object?, Object?>? out =
        await _channel.invokeMethod<Map<Object?, Object?>>(
      'processCapturedImage',
      <String, Object>{'path': capturedImagePath},
    );

    final Uint8List? bytes = out?['bytes'] as Uint8List?;
    final int widthPx = (out?['widthPx'] as num?)?.toInt() ?? 0;
    final int heightPx = (out?['heightPx'] as num?)?.toInt() ?? 0;

    if (bytes == null || bytes.isEmpty || widthPx <= 0 || heightPx <= 0) {
      throw StateError('Failed to process captured image.');
    }

    return ProcessedJpegImage(bytes: bytes, widthPx: widthPx, heightPx: heightPx);
  }
}
