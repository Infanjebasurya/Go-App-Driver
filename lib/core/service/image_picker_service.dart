import 'dart:io';

import 'package:image_picker/image_picker.dart';

enum AppImageSource { camera, gallery }

class PickedImage {
  const PickedImage({
    required this.path,
    required this.name,
  });

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
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<PickedImage?> pickImage({
    required AppImageSource source,
    int imageQuality = 100,
    double? maxWidth,
    double? maxHeight,
  }) async {
    final ImageSource mapped = switch (source) {
      AppImageSource.camera => ImageSource.camera,
      AppImageSource.gallery => ImageSource.gallery,
    };
    final XFile? picked = await _picker.pickImage(
      source: mapped,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    if (picked == null) return null;
    return PickedImage(path: picked.path, name: picked.name);
  }
}

