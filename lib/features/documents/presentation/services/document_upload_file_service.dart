import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:goapp/core/service/image_picker_service.dart';
import 'package:goapp/core/service/permission_service.dart';
import 'package:goapp/core/service/path_provider_service.dart';

class DocumentUploadFileService {
  DocumentUploadFileService({
    required PathProviderService pathProvider,
    required PermissionService permissionService,
  })  : _pathProvider = pathProvider,
        _permissionService = permissionService;

  final PathProviderService _pathProvider;
  final PermissionService _permissionService;

  static const int maxBytes = 5 * 1024 * 1024;
  static const double cr80AspectRatio = 85.6 / 54.0;

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

    final AppPermission permission = source == AppImageSource.camera
        ? AppPermission.camera
        : AppPermission.photos;

    final AppPermissionStatus current = await _permissionService.status(permission);
    final AppPermissionStatus resolved = current == AppPermissionStatus.granted
        ? current
        : await _permissionService.request(permission);
    return resolved == AppPermissionStatus.granted;
  }

  bool validateAspectRatio({
    required int widthPx,
    required int heightPx,
    required double target,
    double toleranceFraction = 0.06,
  }) {
    if (widthPx <= 0 || heightPx <= 0) return false;
    final double w = widthPx.toDouble();
    final double h = heightPx.toDouble();
    final double ratio = math.max(w, h) / math.min(w, h);
    final double diff = (ratio - target).abs() / target;
    return diff <= toleranceFraction;
  }

  Future<ui.Size?> tryDecodeImageSize(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      if (bytes.isEmpty) return null;
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image img = frame.image;
      final ui.Size size = ui.Size(img.width.toDouble(), img.height.toDouble());
      img.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }

  Future<String?> validateCr80CardImage(String path) async {
    final ui.Size? size = await tryDecodeImageSize(path);
    if (size == null) {
      return 'Unable to read image size. Please upload a clear card photo.';
    }
    final bool ok = validateAspectRatio(
      widthPx: size.width.round(),
      heightPx: size.height.round(),
      target: cr80AspectRatio,
    );
    if (!ok) {
      return 'Card photo must match CR80 size (85.6mm × 54mm).';
    }
    return null;
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
