import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/service/permission_service.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/profile_photo_capture/presentation/bloc/profile_photo_bloc.dart';
import 'package:goapp/features/profile_photo_capture/presentation/bloc/profile_photo_event.dart';
import 'package:goapp/features/profile_photo_capture/presentation/bloc/profile_photo_state.dart';
import 'package:goapp/features/profile_photo_capture/presentation/widgets/face_overlay.dart';

class ProfilePhotoCapturePage extends StatelessWidget {
  const ProfilePhotoCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfilePhotoBloc>(
      create: (_) => sl<ProfilePhotoBloc>()..add(const ProfilePhotoStarted()),
      child: const _ProfilePhotoCaptureView(),
    );
  }
}

class _ProfilePhotoCaptureView extends StatelessWidget {
  const _ProfilePhotoCaptureView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        title: const Text('Capture Profile Photo'),
      ),
      body: BlocConsumer<ProfilePhotoBloc, ProfilePhotoState>(
        listenWhen: (ProfilePhotoState prev, ProfilePhotoState next) =>
            prev.errorMessage != next.errorMessage && next.errorMessage != null,
        listener: (BuildContext context, ProfilePhotoState state) {
          final String? msg = state.errorMessage;
          if (msg == null) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        },
        builder: (BuildContext context, ProfilePhotoState state) {
          return switch (state.status) {
            ProfilePhotoCaptureStatus.permissionDenied => _PermissionDeniedView(
              onOpenSettings: () => sl<PermissionService>().openAppSettings(),
              onRetry: () => context.read<ProfilePhotoBloc>().add(
                const ProfilePhotoStarted(),
              ),
            ),
            ProfilePhotoCaptureStatus.preview => _PreviewView(
              path: state.photo?.path,
              onRetake: () => context.read<ProfilePhotoBloc>().add(
                const ProfilePhotoRetakeRequested(),
              ),
              onConfirm: () {
                final String? path = state.photo?.path;
                if (path != null) Navigator.of(context).pop<String>(path);
              },
            ),
            _ => _CameraView(
              guidanceText: state.guidanceText ?? 'Align your face',
              isAutoCapturing: state.isAutoCapturing,
              controller: state.cameraController,
            ),
          };
        },
      ),
    );
  }
}

class _CameraView extends StatelessWidget {
  const _CameraView({
    required this.guidanceText,
    required this.isAutoCapturing,
    required this.controller,
  });

  final String guidanceText;
  final bool isAutoCapturing;
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    final CameraController? camera = controller;
    final bool ready = camera?.value.isInitialized ?? false;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: ready && camera != null
              ? LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Size? previewSize = camera.value.previewSize;
                    if (previewSize == null) {
                      return Center(
                        child: AspectRatio(
                          aspectRatio: camera.value.aspectRatio,
                          child: CameraPreview(camera),
                        ),
                      );
                    }

                    return ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.center,
                        minWidth: constraints.maxWidth,
                        minHeight: constraints.maxHeight,
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: previewSize.height,
                            height: previewSize.width,
                            child: CameraPreview(camera),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                ),
        ),
        Positioned.fill(
          child: FaceOverlay(
            guidanceText: guidanceText,
            isAutoCapturing: isAutoCapturing,
          ),
        ),
      ],
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({
    required this.path,
    required this.onRetake,
    required this.onConfirm,
  });

  final String? path;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final String? localPath = path;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Text(
            'Preview',
            style: textTheme.titleLarge?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3.5 / 4.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.white30),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: localPath == null
                      ? const SizedBox.shrink()
                      : Image.file(File(localPath), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetake,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.white30),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Confirm & Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({
    required this.onOpenSettings,
    required this.onRetry,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Camera permission required',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable camera permission in Settings to capture your profile photo.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpenSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Open Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
