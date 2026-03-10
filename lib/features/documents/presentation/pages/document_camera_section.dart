import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/service/image_picker_service.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

import '../cubit/document_upload_cubit.dart';

void showProfileImageSourceSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Upload Profile Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.headingNavy,
              ),
            ),
            const SizedBox(height: 6),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<DocumentUploadCubit>().captureProfilePhoto(
                  source: AppImageSource.camera,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<DocumentUploadCubit>().captureProfilePhoto(
                  source: AppImageSource.gallery,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

void showDocumentImageSourceSheet(
  BuildContext context, {
  required Future<void> Function(AppImageSource source) onPick,
  required Future<void> Function() onPickDocument,
}) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Upload Document',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.headingNavy,
              ),
            ),
            const SizedBox(height: 6),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                onPick(AppImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                onPick(AppImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: const Text('Document'),
              onTap: () {
                Navigator.of(ctx).pop();
                onPickDocument();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

void showBankDocumentSourceSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Upload Document',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.headingNavy,
              ),
            ),
            const SizedBox(height: 6),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<DocumentUploadCubit>().captureBankDocument(
                  source: AppImageSource.camera,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<DocumentUploadCubit>().captureBankDocument(
                  source: AppImageSource.gallery,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: const Text('Document'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<DocumentUploadCubit>().captureBankDocumentFile();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
