import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/documents/presentation/model/document_upload_model.dart';

class DocumentCaptureCard extends StatelessWidget {
  const DocumentCaptureCard({
    super.key,
    required this.label,
    this.labelColor,
    required this.captured,
    this.filePath,
    this.uploadType,
    this.showCardGuide = false,
    required this.onTap,
    this.onRemove,
  });

  final String label;
  final Color? labelColor;
  final bool captured;
  final String? filePath;
  final DocumentUploadType? uploadType;
  final bool showCardGuide;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isImage = uploadType == DocumentUploadType.image && filePath != null;
    final isDocument =
        uploadType == DocumentUploadType.document && filePath != null;
    final fileName = isDocument ? _basename(filePath) : null;

    return GestureDetector(
      onTap: captured ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: captured && isImage ? 0 : (showCardGuide ? 210 : 165),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: captured
                ? AppColors.emerald.withValues(alpha: 0.35)
                : AppColors.hexFFE2E8F0,
            width: captured ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            if (captured && isImage)
              Padding(
                padding: const EdgeInsets.all(10),
                child: _ImagePreview(
                  path: filePath!,
                  adaptiveCardSize: true,
                  showGuideFrame: showCardGuide,
                ),
              ),
            if (captured && isDocument)
              Positioned.fill(
                child: _UploadedDocumentPreview(fileName: fileName),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!(captured && isImage) && !(captured && isDocument))
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: showCardGuide
                            ? const _CardGuideHint(key: ValueKey('card_guide'))
                            : _fallbackIcon(
                                key: const ValueKey('empty'),
                                isDocument: false,
                              ),
                      ),
                    if (!captured) ...[
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.1,
                            ).copyWith(
                              color: labelColor ?? const Color(0xFF6B7C93),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (captured && onRemove != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.hexFFFFEEEE,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppColors.hexFFE53935,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon({Key? key, required bool isDocument}) {
    return Container(
      key: key,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDocument
            ? AppColors.emerald.withValues(alpha: 0.12)
            : AppColors.coolwhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isDocument ? Icons.description_rounded : Icons.smartphone_rounded,
        color: isDocument ? AppColors.emerald : AppColors.hexFFB0BEC5,
        size: 26,
      ),
    );
  }

  String? _basename(String? path) {
    if (path == null || path.isEmpty) return null;
    final normalized = path.replaceAll('\\', '/');
    final idx = normalized.lastIndexOf('/');
    return idx >= 0 ? normalized.substring(idx + 1) : normalized;
  }
}

class _UploadedDocumentPreview extends StatelessWidget {
  const _UploadedDocumentPreview({this.fileName});

  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: AppColors.emerald,
                  size: 26,
                ),
              ),
              if (fileName != null && fileName!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    fileName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.headingNavy,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.path,
    this.adaptiveCardSize = false,
    this.showGuideFrame = false,
  });

  final String path;
  final bool adaptiveCardSize;
  final bool showGuideFrame;

  @override
  Widget build(BuildContext context) {
    if (adaptiveCardSize) {
      return FutureBuilder<double>(
        future: _readAspectRatio(path),
        builder: (context, snapshot) {
          final aspectRatio = snapshot.data ?? 1.58;
          return AspectRatio(
            aspectRatio: aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFFF8FAFC)),
                  Positioned.fill(
                    child: Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) =>
                          _imageFallback(),
                    ),
                  ),
                  if (showGuideFrame)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.file(
              File(path),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) => _imageFallback(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.coolwhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.smartphone_rounded,
        color: AppColors.hexFFB0BEC5,
        size: 26,
      ),
    );
  }

  Future<double> _readAspectRatio(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;
      final ratio = image.height == 0 ? 1.58 : image.width / image.height;
      image.dispose();
      codec.dispose();
      return ratio;
    } catch (_) {
      return 1.58;
    }
  }
}

class _CardGuideHint extends StatelessWidget {
  const _CardGuideHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.58,
          child: Container(
            width: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.emerald.withValues(alpha: 0.06),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: AppColors.emerald,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}
