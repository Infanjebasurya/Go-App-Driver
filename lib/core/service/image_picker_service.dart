import 'dart:io';

import 'package:flutter/services.dart';

enum AppImageSource { camera, gallery }

class PickedImage {
  const PickedImage({required this.path, required this.name});

  final String path;
  final String name;

  Future<int> sizeBytes() async {
    try {
      return await File(path).length();
    } catch (_) {
      return 0;
    }
  }
}

/// Wrapper so feature code doesn't import `image_picker`.
class ImagePickerService {
  ImagePickerService();

  static const MethodChannel _channel = MethodChannel(
    'app/image_picker_service',
  );

  Future<PickedImage?> pickImage({
    required AppImageSource source,
    int imageQuality = 100,
    double? maxWidth,
    double? maxHeight,
  }) async {
    final Map<Object?, Object?>? picked = await _channel
        .invokeMethod<Map<Object?, Object?>>('pickImage', <String, Object?>{
          'source': source.name,
          'imageQuality': imageQuality,
          'maxWidth': maxWidth,
          'maxHeight': maxHeight,
        });
    if (picked == null) return null;
    final String? path = picked['path'] as String?;
    final String? name = picked['name'] as String?;
    if (path == null || path.isEmpty) return null;
    return PickedImage(
      path: path,
      name: name ?? File(path).uri.pathSegments.last,
    );
  }
}
