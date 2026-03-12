import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/service/image_picker_service.dart';
import 'package:goapp/core/service/permission_service.dart';
import 'package:goapp/features/profile_photo_capture/domain/entities/processed_profile_photo.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/processed_jpeg_image.dart';
import 'package:goapp/features/profile_photo_capture/domain/services/profile_photo_image_processing_service.dart';
import 'package:goapp/features/profile_photo_capture/domain/usecases/save_profile_photo_usecase.dart';
import 'package:goapp/features/profile_photo_capture/presentation/bloc/profile_photo_event.dart';
import 'package:goapp/features/profile_photo_capture/presentation/bloc/profile_photo_state.dart';

class ProfilePhotoBloc extends Bloc<ProfilePhotoEvent, ProfilePhotoState> {
  ProfilePhotoBloc({
    required PermissionService permissionService,
    required ImagePickerService imagePickerService,
    required ProfilePhotoImageProcessingService imageProcessingService,
    required SaveProfilePhotoUseCase saveUseCase,
  })  : _permissionService = permissionService,
        _imagePickerService = imagePickerService,
        _imageProcessingService = imageProcessingService,
        _saveUseCase = saveUseCase,
        super(ProfilePhotoState.initial()) {
    on<ProfilePhotoStarted>(_onStarted);
    on<ProfilePhotoRetakeRequested>(_onRetake);
  }

  final PermissionService _permissionService;
  final ImagePickerService _imagePickerService;
  final ProfilePhotoImageProcessingService _imageProcessingService;
  final SaveProfilePhotoUseCase _saveUseCase;

  Future<void> _onStarted(ProfilePhotoStarted event, Emitter<ProfilePhotoState> emit) async {
    emit(state.copyWith(status: ProfilePhotoCaptureStatus.capturing, errorMessage: null));

    final AppPermissionStatus current = await _permissionService.status(AppPermission.camera);
    final AppPermissionStatus resolved = current == AppPermissionStatus.granted
        ? current
        : await _permissionService.request(AppPermission.camera);

    if (resolved != AppPermissionStatus.granted) {
      emit(state.copyWith(status: ProfilePhotoCaptureStatus.permissionDenied));
      return;
    }

    try {
      final picked = await _imagePickerService.pickImage(source: AppImageSource.camera);
      if (picked == null) {
        emit(
          state.copyWith(
            status: ProfilePhotoCaptureStatus.initial,
            errorMessage: 'Capture cancelled.',
          ),
        );
        return;
      }

      emit(state.copyWith(status: ProfilePhotoCaptureStatus.processing));

      final ProcessedJpegImage processed =
          await _imageProcessingService.processCapturedImage(picked.path);
      final ProcessedProfilePhoto saved = await _saveUseCase(processed);

      emit(
        state.copyWith(
          status: ProfilePhotoCaptureStatus.preview,
          photo: saved,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Capture failed. ${e.toString()}',
          status: ProfilePhotoCaptureStatus.failure,
        ),
      );
    }
  }

  Future<void> _onRetake(ProfilePhotoRetakeRequested event, Emitter<ProfilePhotoState> emit) async {
    if (state.status != ProfilePhotoCaptureStatus.preview) return;

    emit(
      state.copyWith(
        status: ProfilePhotoCaptureStatus.initial,
        photo: null,
        errorMessage: null,
      ),
    );
  }
}
