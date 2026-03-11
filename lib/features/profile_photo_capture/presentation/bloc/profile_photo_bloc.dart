import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/service/permission_service.dart';
import 'package:goapp/features/profile_photo_capture/domain/entities/processed_profile_photo.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/detected_face.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/face_detection_snapshot.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/processed_jpeg_image.dart';
import 'package:goapp/features/profile_photo_capture/domain/models/profile_camera_frame.dart';
import 'package:goapp/features/profile_photo_capture/domain/services/face_detection_service.dart';
import 'package:goapp/features/profile_photo_capture/domain/services/profile_camera_service.dart';
import 'package:goapp/features/profile_photo_capture/domain/services/profile_photo_image_processing_service.dart';
import 'package:goapp/features/profile_photo_capture/domain/usecases/save_profile_photo_usecase.dart';
import 'package:goapp/features/profile_photo_capture/presentation/bloc/profile_photo_event.dart';
import 'package:goapp/features/profile_photo_capture/presentation/bloc/profile_photo_state.dart';
import 'package:goapp/features/profile_photo_capture/presentation/bloc/profile_photo_validator.dart';

class ProfilePhotoBloc extends Bloc<ProfilePhotoEvent, ProfilePhotoState> {
  ProfilePhotoBloc({
    required PermissionService permissionService,
    required ProfileCameraService cameraService,
    required FaceDetectionService faceDetectionService,
    required ProfilePhotoImageProcessingService imageProcessingService,
    required SaveProfilePhotoUseCase saveUseCase,
  })  : _permissionService = permissionService,
        _cameraService = cameraService,
        _faceDetectionService = faceDetectionService,
        _imageProcessingService = imageProcessingService,
        _saveUseCase = saveUseCase,
        super(ProfilePhotoState.initial()) {
    on<ProfilePhotoStarted>(_onStarted);
    on<ProfilePhotoFrameArrived>(_onFrameArrived);
    on<ProfilePhotoRetakeRequested>(_onRetake);
  }

  final PermissionService _permissionService;
  final ProfileCameraService _cameraService;
  final FaceDetectionService _faceDetectionService;
  final ProfilePhotoImageProcessingService _imageProcessingService;
  final SaveProfilePhotoUseCase _saveUseCase;

  final ProfilePhotoValidator _validator = ProfilePhotoValidator();

  bool _detecting = false;
  int _lastProcessedMs = 0;
  int? _alignedSinceMs;
  DetectedFace? _previousFace;

  Future<void> _onStarted(ProfilePhotoStarted event, Emitter<ProfilePhotoState> emit) async {
    emit(state.copyWith(status: ProfilePhotoCaptureStatus.initializingCamera));

    final AppPermissionStatus current = await _permissionService.status(AppPermission.camera);
    final AppPermissionStatus resolved = current == AppPermissionStatus.granted
        ? current
        : await _permissionService.request(AppPermission.camera);

    if (resolved != AppPermissionStatus.granted) {
      emit(state.copyWith(status: ProfilePhotoCaptureStatus.permissionDenied));
      return;
    }

    try {
      await _cameraService.initialize();
      emit(
        state.copyWith(
          status: ProfilePhotoCaptureStatus.detecting,
          cameraController: _cameraService.controller,
          faceStatus: FaceValidationStatus.noFace,
          guidanceText: _validator.guidanceFor(FaceValidationStatus.noFace),
        ),
      );

      await _cameraService.startImageStream((ProfileCameraFrame frame) {
        add(ProfilePhotoFrameArrived(frame));
      });
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfilePhotoCaptureStatus.failure,
          errorMessage: 'Failed to start camera. ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onFrameArrived(ProfilePhotoFrameArrived event, Emitter<ProfilePhotoState> emit) async {
    if (state.status != ProfilePhotoCaptureStatus.detecting) return;
    if (_detecting) return;

    final int now = event.frame.timestampMs;
    if (now - _lastProcessedMs < 90) return; // throttle to reduce frame drops
    _lastProcessedMs = now;
    _detecting = true;

    try {
      final FaceDetectionSnapshot snapshot = await _faceDetectionService.detect(event.frame);
      final Rect guideRect = _validator.guideRectFor(snapshot.imageSize);
      final FaceValidationStatus faceStatus = _validator.validate(
        snapshot,
        guideRect: guideRect,
        previousFace: _previousFace,
      );

      final DetectedFace? currentFace = snapshot.faces.length == 1 ? snapshot.faces.single : null;
      _previousFace = currentFace;

      final String guidance = _validator.guidanceFor(faceStatus);

      if (faceStatus == FaceValidationStatus.aligned) {
        _alignedSinceMs ??= snapshot.timestampMs;
      } else {
        _alignedSinceMs = null;
      }

      final bool shouldAutoCapture = _alignedSinceMs != null &&
          snapshot.timestampMs - _alignedSinceMs! >= ProfilePhotoValidator.autoCaptureHold.inMilliseconds;

      emit(
        state.copyWith(
          faceStatus: faceStatus,
          guidanceText: guidance,
          isAutoCapturing: shouldAutoCapture,
        ),
      );

      if (shouldAutoCapture) {
        await _captureAndProcess(emit);
      }
    } catch (_) {
      emit(
        state.copyWith(
          faceStatus: FaceValidationStatus.noFace,
          guidanceText: _validator.guidanceFor(FaceValidationStatus.noFace),
          isAutoCapturing: false,
        ),
      );
      _alignedSinceMs = null;
    } finally {
      _detecting = false;
    }
  }

  Future<void> _captureAndProcess(Emitter<ProfilePhotoState> emit) async {
    if (state.status != ProfilePhotoCaptureStatus.detecting) return;

    emit(state.copyWith(status: ProfilePhotoCaptureStatus.capturing));
    _alignedSinceMs = null;

    try {
      await _cameraService.stopImageStream();
      final captured = await _cameraService.takePicture();

      emit(state.copyWith(status: ProfilePhotoCaptureStatus.processing));

      final ProcessedJpegImage processed =
          await _imageProcessingService.processCapturedImage(captured.path);
      final ProcessedProfilePhoto saved = await _saveUseCase(processed);

      emit(
        state.copyWith(
          status: ProfilePhotoCaptureStatus.preview,
          photo: saved,
          isAutoCapturing: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfilePhotoCaptureStatus.detecting,
          errorMessage: 'Capture failed. ${e.toString()}',
          isAutoCapturing: false,
        ),
      );
      await _cameraService.startImageStream((ProfileCameraFrame frame) {
        add(ProfilePhotoFrameArrived(frame));
      });
    }
  }

  Future<void> _onRetake(ProfilePhotoRetakeRequested event, Emitter<ProfilePhotoState> emit) async {
    if (state.status != ProfilePhotoCaptureStatus.preview) return;

    emit(
      state.copyWith(
        status: ProfilePhotoCaptureStatus.detecting,
        photo: null,
        errorMessage: null,
        isAutoCapturing: false,
        faceStatus: FaceValidationStatus.noFace,
        guidanceText: _validator.guidanceFor(FaceValidationStatus.noFace),
      ),
    );

    _previousFace = null;
    _alignedSinceMs = null;

    await _cameraService.startImageStream((ProfileCameraFrame frame) {
      add(ProfilePhotoFrameArrived(frame));
    });
  }

  @override
  Future<void> close() async {
    await _cameraService.stopImageStream();
    await _cameraService.dispose();
    await _faceDetectionService.dispose();
    return super.close();
  }
}
