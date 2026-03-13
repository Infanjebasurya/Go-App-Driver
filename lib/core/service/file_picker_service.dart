import 'package:flutter/services.dart';

class PickedFile {
  const PickedFile({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.extension,
  });

  final String path;
  final String name;
  final int sizeBytes;
  final String extension;
}

/// Wrapper so feature code doesn't import `file_picker`.
class FilePickerService {
  const FilePickerService();

  static const MethodChannel _channel = MethodChannel(
    'app/file_picker_service',
  );

  Future<PickedFile?> pickImage() async {
    final Map<Object?, Object?>? raw = await _channel
        .invokeMethod<Map<Object?, Object?>>('pickImage');
    return _mapSingle(raw);
  }

  Future<PickedFile?> pickCustom({
    required List<String> allowedExtensions,
  }) async {
    final Map<Object?, Object?>? raw = await _channel
        .invokeMethod<Map<Object?, Object?>>('pickCustom', <String, Object>{
          'allowedExtensions': allowedExtensions,
        });
    return _mapSingle(raw);
  }

  PickedFile? _mapSingle(Map<Object?, Object?>? raw) {
    if (raw == null) return null;
    final String? path = raw['path'] as String?;
    if (path == null || path.isEmpty) return null;
    return PickedFile(
      path: path,
      name: (raw['name'] as String?) ?? '',
      sizeBytes: (raw['sizeBytes'] as num?)?.toInt() ?? 0,
      extension: ((raw['extension'] as String?) ?? '').toLowerCase(),
    );
  }
}
