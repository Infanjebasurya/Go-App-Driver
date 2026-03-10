import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goapp/core/service/image_picker_service.dart';
import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/core/di/injection.dart';

import '../../../cubit/profile_edit_state.dart';


class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.data});

  final ProfileEditData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: <Widget>[
          const ProfileAvatar(),
          const SizedBox(height: 14),
          Text(
            data.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Premium Member',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  static const String _photoKey = 'profile.photo.path';
  late final ImagePickerService _picker;
  ImageProvider? _avatarProvider;

  @override
  void initState() {
    super.initState();
    _picker = sl<ImagePickerService>();
    _loadAvatarFromStore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAvatar();
  }

  void _loadAvatarFromStore() {
    final raw = TextFieldStore.read(_photoKey);
    _avatarProvider = _buildAvatarProvider(raw);
  }

  ImageProvider? _buildAvatarProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    return ResizeImage(FileImage(file), width: 192, height: 192);
  }

  void _precacheAvatar() {
    final provider = _avatarProvider;
    if (provider == null) return;
    precacheImage(provider, context);
  }

  Future<void> _pickPhoto(AppImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null) return;
    _avatarProvider = _buildAvatarProvider(picked.path);
    await TextFieldStore.write(_photoKey, picked.path);
    _precacheAvatar();
    if (mounted) {
      setState(() {});
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              const Text(
                'Upload Profile Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickPhoto(AppImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickPhoto(AppImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AuthUiColors.brandGreen, width: 2.5),
          ),
          child: ClipOval(
            child: Container(
              color: const Color(0xFF3A3A3A),
              child: _avatarProvider != null
                  ? Image(
                      image: _avatarProvider!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                      gaplessPlayback: true,
                    )
                  : const Icon(Icons.person, size: 52, color: Colors.white54),
            ),
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap: _showPhotoSourceSheet,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AuthUiColors.brandGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
