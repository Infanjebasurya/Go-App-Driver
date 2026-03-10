import 'dart:io';

import 'package:goapp/core/service/image_picker_service.dart';
import 'package:goapp/core/service/path_provider_service.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentUploadFileService {
  DocumentUploadFileService({required PathProviderService pathProvider})
      : _pathProvider = pathProvider;

  final PathProviderService _pathProvider;

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

  Future<int> resolveImageSizeBytes(PickedImage picked) async {
    final fileSize = await File(picked.path).length();
    final bytes = await File(picked.path).readAsBytes();
    return [fileSize, bytes.length].reduce((a, b) => a > b ? a : b);
  }

  Future<bool> ensurePermission(AppImageSource source) async {
    if (source == AppImageSource.gallery && Platform.isAndroid) {
      return true;
    }

    final Permission permission = source == AppImageSource.camera
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

      final directory = await _pathProvider.getApplicationDocumentsDirectory();
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
      final directory = await _pathProvider.getApplicationDocumentsDirectory();
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
      final directory = await _pathProvider.getApplicationDocumentsDirectory();
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
