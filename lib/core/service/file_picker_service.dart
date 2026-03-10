import 'package:file_picker/file_picker.dart';

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

  Future<PickedFile?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
      allowMultiple: false,
    );
    return _mapSingle(result);
  }

  Future<PickedFile?> pickCustom({
    required List<String> allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: false,
      allowMultiple: false,
    );
    return _mapSingle(result);
  }

  PickedFile? _mapSingle(FilePickerResult? result) {
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    final path = file.path;
    if (path == null || path.isEmpty) return null;
    return PickedFile(
      path: path,
      name: file.name,
      sizeBytes: file.size,
      extension: (file.extension ?? '').toLowerCase(),
    );
  }
}

