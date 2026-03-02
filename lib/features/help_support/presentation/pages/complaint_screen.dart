import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/home/presentation/cubit/driver_status_cubit.dart';
import 'package:goapp/features/home/presentation/pages/home_page.dart';
import 'package:goapp/features/help_support/presentation/cubit/complaint_cubit.dart';
import 'package:goapp/features/help_support/domain/entities/help_entities.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintCubit, ComplaintState>(
      listener: (context, state) {
        if (state is ComplaintFormState && state.showCategoryPicker) {
          _showCategoryPicker(context);
        }
      },
      builder: (context, state) {
        if (state is ComplaintSubmitted) {
          return _SuccessScreen(ticketId: state.ticketId);
        }
        return _FormScreen(
          state: state is ComplaintFormState
              ? state
              : const ComplaintFormState(),
        );
      },
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ComplaintCubit>(),
        child: const _CategoryPickerSheet(),
      ),
    );
  }
}

class _FormScreen extends StatefulWidget {
  final ComplaintFormState state;

  const _FormScreen({required this.state});

  @override
  State<_FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<_FormScreen> {
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
  static const Set<String> _documentExtensions = <String>{
    'pdf',
    'doc',
    'docx',
  };

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
        context.read<ComplaintCubit>().updateDescription(
              _descController.text,
            );
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
                          const SizedBox(height: 8),
                          const Text(
                            'Attach Evidence (Photos/Video/Document)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                                          color: AppColors.textSecondary,
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
                  : const Text('Submit Complaint',
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: <String>[
          ..._imageExtensions,
          ..._videoExtensions,
          ..._documentExtensions,
        ],
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (file.size > _maxMediaSizeBytes) {
        cubit.setMediaValidationError(
          'File size must be up to 20MB.',
        );
        return;
      }
      final path = file.path;
      if (path == null || path.isEmpty) {
        cubit.setMediaValidationError(
          'Could not access selected file. Try again.',
        );
        return;
      }
      final extension = (file.extension ?? '').toLowerCase();
      final mediaType = _resolveMediaType(extension);
      if (mediaType == null) {
        cubit.setMediaValidationError(
          'Unsupported file format.',
        );
        return;
      }
      cubit.attachMedia(
        path: path,
        name: file.name,
        mediaType: mediaType,
      );
    } catch (_) {
      cubit.setMediaValidationError(
        'Unable to pick file right now. Please try again.',
      );
    }
  }

  ComplaintMediaType? _resolveMediaType(String extension) {
    if (_imageExtensions.contains(extension)) return ComplaintMediaType.image;
    if (_videoExtensions.contains(extension)) return ComplaintMediaType.video;
    if (_documentExtensions.contains(extension)) {
      return ComplaintMediaType.document;
    }
    return null;
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComplaintCubit, ComplaintState>(
      builder: (context, state) {
        final cubit = context.read<ComplaintCubit>();
        final selected = state is ComplaintFormState
            ? state.selectedCategoryId
            : null;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'PLEASE SPECIFY THE NATURE OF YOUR CONCERN',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 16),
              ...kComplaintCategories.map(
                (cat) => _CategoryTile(
                  category: cat,
                  isSelected: selected == cat.id,
                  onTap: () {
                    cubit.selectCategory(cat.id);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
              ShadowButton(
                onPressed: selected != null
                    ? () => Navigator.pop(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirm Selection',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ComplaintCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textBody,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.emerald : AppColors.borderSoft,
                  width: 2,
                ),
                color: isSelected ? AppColors.emerald : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final String ticketId;

  const _SuccessScreen({required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.white,
                  size: 56,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Report Submitted\nSuccessfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBody,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Your ticket '),
                    TextSpan(
                      text: ticketId,
                      style: const TextStyle(
                        color: AppColors.emerald,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' has been registered.\nOur concierge team will review the details\nand respond within 24 hours.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: ShadowButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider<DriverCubit>(
                create: (_) => DriverCubit(),
                child: const HomeScreen(),
              ),
            ),
            (route) => false,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
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
          child: const Text(
            'Return to Dashboard',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}


