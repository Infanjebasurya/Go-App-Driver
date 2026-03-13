import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/service/file_picker_service.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/widgets/shadow_button.dart';
import 'package:goapp/features/help_support/presentation/cubit/complaint_cubit.dart';
import 'package:goapp/core/di/injection.dart';

class ComplaintFormScreen extends StatefulWidget {
  const ComplaintFormScreen({super.key, required this.state});

  final ComplaintFormState state;

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  static const int _maxMediaSizeBytes = 20 * 1024 * 1024;
  static const Set<String> _imageExtensions = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
  };
  static const Set<String> _videoExtensions = <String>{
    'mp4',
    'mov',
    'avi',
    'mkv',
    '3gp',
    'm4v',
    'webm',
  };
  static const Set<String> _documentExtensions = <String>{'pdf', 'doc', 'docx'};

  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController();
    if (_descController.text.isEmpty && widget.state.description.isNotEmpty) {
      _descController.text = widget.state.description;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_descController.text.isNotEmpty) {
        context.read<ComplaintCubit>().updateDescription(_descController.text);
      }
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComplaintCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Make Complaint', style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: cubit.openCategoryPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSoft),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<ComplaintCubit, ComplaintState>(
                        builder: (context, state) {
                          final s = state is ComplaintFormState
                              ? state
                              : widget.state;
                          return Text(
                            s.categoryName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: s.selectedCategoryId == null
                                  ? AppColors.textSecondary
                                  : AppColors.textBody,
                            ),
                          );
                        },
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'DESCRIPTION',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 5,
              onChanged: cubit.updateDescription,
              decoration: InputDecoration(
                hintText: 'Describe the issue in detail...',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderSoft),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderSoft),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.emerald,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SUPPORTING MEDIA (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: widget.state.mediaName == null
                  ? () => _pickSupportingMedia(context)
                  : null,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.borderSoft,
                    style: BorderStyle.solid,
                  ),
                ),
                child: widget.state.mediaName == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.emerald,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Attach Evidence (Photos/Video/Document)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'IMAGE/VIDEO/DOCUMENT - UP TO 20MB',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.state.mediaType ==
                                          ComplaintMediaType.image &&
                                      widget.state.mediaPath != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(widget.state.mediaPath!),
                                        width: 96,
                                        height: 68,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.image_outlined,
                                                  color:
                                                      AppColors.textSecondary,
                                                  size: 32,
                                                ),
                                      ),
                                    )
                                  else if (widget.state.mediaType ==
                                      ComplaintMediaType.document)
                                    const Icon(
                                      Icons.description_rounded,
                                      color: AppColors.textSecondary,
                                      size: 32,
                                    )
                                  else
                                    const Icon(
                                      Icons.videocam_outlined,
                                      color: AppColors.textSecondary,
                                      size: 32,
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.state.mediaName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textBody,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: cubit.removeMedia,
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
              ),
            ),
            if (widget.state.mediaValidationMessage != null &&
                widget.state.mediaValidationMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.state.mediaValidationMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEF5350),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<ComplaintCubit, ComplaintState>(
        builder: (context, state) {
          final s = state is ComplaintFormState ? state : widget.state;
          return Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: ShadowButton(
              onPressed: s.isValid && !s.isSubmitting
                  ? () => context.read<ComplaintCubit>().submitComplaint()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                disabledBackgroundColor: AppColors.borderSoft,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: s.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit Complaint',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickSupportingMedia(BuildContext context) async {
    final cubit = context.read<ComplaintCubit>();
    try {
      final file = await sl<FilePickerService>().pickCustom(
        allowedExtensions: <String>[
          ..._imageExtensions,
          ..._videoExtensions,
          ..._documentExtensions,
        ],
      );
      if (file == null) return;
      if (file.sizeBytes > _maxMediaSizeBytes) {
        cubit.setMediaValidationError('File size must be up to 20MB.');
        return;
      }
      final mediaType = _resolveMediaType(file.extension);
      if (mediaType == null) {
        cubit.setMediaValidationError('Unsupported file format.');
        return;
      }
      cubit.attachMedia(path: file.path, name: file.name, mediaType: mediaType);
    } catch (_) {
      cubit.setMediaValidationError(
        'Unable to pick file right now. Please try again.',
      );
    }
  }

  ComplaintMediaType? _resolveMediaType(String extension) {
    if (_imageExtensions.contains(extension)) {
      return ComplaintMediaType.image;
    }
    if (_videoExtensions.contains(extension)) {
      return ComplaintMediaType.video;
    }
    if (_documentExtensions.contains(extension)) {
      return ComplaintMediaType.document;
    }
    return null;
  }
}
