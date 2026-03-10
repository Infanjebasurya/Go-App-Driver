import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentUploadFileService {
  const DocumentUploadFileService();

  static const int maxBytes = 5 * 1024 * 1024;

  bool validateFileSize(int sizeBytes) {
    return sizeBytes > 0 && sizeBytes <= maxBytes;
  }

  bool isValidImageFormat(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.heic') ||
        lower.endsWith('.heif') ||
        lower.endsWith('.webp');
  }

  Future<int> resolveImageSizeBytes(XFile picked) async {
    final fileSize = await File(picked.path).length();
    final pickedSize = await picked.length();
    final bytes = await picked.readAsBytes();
    return [fileSize, pickedSize, bytes.length].reduce((a, b) => a > b ? a : b);
  }

  Future<bool> ensurePermission(ImageSource source) async {
    if (source == ImageSource.gallery && Platform.isAndroid) {
      return true;
    }

    final Permission permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final status = await permission.status;
    if (status.isGranted) return true;

    final result = await permission.request();
    return result.isGranted;
  }

  Future<String> persistImageToAppStorage(
    String sourcePath, {
    required String prefix,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return sourcePath;

      final directory = await getApplicationDocumentsDirectory();
      final uploadsDir = Directory(
        '${directory.path}${Platform.pathSeparator}document_uploads',
      );
      if (!await uploadsDir.exists()) {
        await uploadsDir.create(recursive: true);
      }

      final extension = _extractExtension(sourcePath);
      final targetPath =
          '${uploadsDir.path}${Platform.pathSeparator}${prefix}_${DateTime.now().millisecondsSinceEpoch}$extension';
      final copied = await sourceFile.copy(targetPath);
      return copied.path;
    } catch (_) {
      return sourcePath;
    }
  }

  Future<void> deleteManagedFileIfExists(String? path) async {
    if (path == null || path.trim().isEmpty) return;
    try {
      if (!await _isManagedUploadPath(path)) return;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> clearManagedUploadsDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final uploadsDir = Directory(
        '${directory.path}${Platform.pathSeparator}document_uploads',
      );
      if (await uploadsDir.exists()) {
        await uploadsDir.delete(recursive: true);
      }
    } catch (_) {}
  }

  Future<bool> _isManagedUploadPath(String path) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final uploadsDir = Directory(
        '${directory.path}${Platform.pathSeparator}document_uploads',
      ).path;
      final normalizedPath = path.replaceAll('\\', '/');
      final normalizedUploadsDir =
          '$uploadsDir${Platform.pathSeparator}'.replaceAll('\\', '/');
      return normalizedPath.startsWith(normalizedUploadsDir);
    } catch (_) {
      return false;
    }
  }

  String _extractExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == path.length - 1) return '.jpg';
    return path.substring(dotIndex);
  }
}
