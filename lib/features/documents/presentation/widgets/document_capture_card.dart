import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/documents/presentation/model/document_upload_model.dart';

class DocumentCaptureCard extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final bool captured;
  final String? filePath;
  final DocumentUploadType? uploadType;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const DocumentCaptureCard({
    super.key,
    required this.label,
    this.labelColor,
    required this.captured,
    this.filePath,
    this.uploadType,
    required this.onTap,
    this.onRemove,
  });

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
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: captured
                ? AppColors.emerald.withValues(alpha: 0.35)
                : const Color(0xFFE2E8F0),
            width: captured ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: captured
                        ? (isImage
                            ? _ImagePreview(path: filePath!)
                            : _fallbackIcon(
                                key: const ValueKey('document'),
                                isDocument: isDocument,
                              ))
                        : _fallbackIcon(
                            key: const ValueKey('empty'),
                            isDocument: false,
                          ),
                  ),
                ),
                if (!captured) ...[
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                    ).copyWith(color: labelColor ?? const Color(0xFF6B7C93)),
                  ),
                ],
                if (isDocument && fileName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.headingNavy,
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
                      color: Color(0xFFFFEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Color(0xFFE53935),
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
        color: isDocument ? AppColors.emerald : const Color(0xFFB0BEC5),
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

class _ImagePreview extends StatelessWidget {
  final String path;

  const _ImagePreview({required this.path});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.clamp(0, 200).toDouble();
        final maxHeight = constraints.maxHeight.clamp(0, 120).toDouble();
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(path),
            width: maxWidth,
            height: maxHeight,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _imageFallback(),
          ),
        );
      },
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
        color: Color(0xFFB0BEC5),
        size: 26,
      ),
    );
  }
}
