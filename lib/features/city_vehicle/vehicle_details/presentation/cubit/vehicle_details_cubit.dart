import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/service/file_picker_service.dart';
import 'package:goapp/core/service/image_picker_service.dart';
import 'package:goapp/core/service/permission_service.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/model/vehicle_details_model.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';

class VehicleDetailsCubit extends Cubit<VehicleDetailsState> {
  VehicleDetailsCubit({
    required VehicleType vehicleType,
    required ImagePickerService imagePickerService,
    required FilePickerService filePickerService,
    required PermissionService permissionService,
  }) : _imagePickerService = imagePickerService,
       _filePickerService = filePickerService,
       _permissionService = permissionService,
       super(VehicleDetailsState.initial(vehicleType: vehicleType));

  final ImagePickerService _imagePickerService;
  final FilePickerService _filePickerService;
  final PermissionService _permissionService;

  void updateModelName(String value) {
    final err = state.errors.copyWith(clearModel: value.trim().isNotEmpty);
    emit(state.copyWith(modelName: value, errors: err));
  }

  void selectBikeType(BikeType type) {
    final err = state.errors.copyWith(clearBikeType: true);
    emit(state.copyWith(selectedBikeType: type, errors: err));
  }

  void selectSeatOption(SeatOption option) {
    final err = state.errors.copyWith(clearSeatOption: true);
    emit(state.copyWith(selectedSeatOption: option, errors: err));
  }

  void selectFuelType(FuelType type) {
    final err = state.errors.copyWith(clearFuelType: true);
    emit(state.copyWith(selectedFuelType: type, errors: err));
  }

  void updateYear(String value) {
    String? yearError;
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      final n = int.tryParse(trimmed);
      final current = DateTime.now().year;
      if (n == null || n < 1980 || n > current) {
        yearError = 'Enter a valid year (1980-$current)';
      }
    }
    final err = state.errors.copyWith(
      year: yearError,
      clearYear: yearError == null,
    );
    emit(state.copyWith(year: value, errors: err));
  }


  static const int _maxImageBytes = 5 * 1024 * 1024;

  bool _validateFileSize(int sizeBytes) {
    if (sizeBytes <= 0 || sizeBytes > _maxImageBytes) {
      emit(
        state.copyWith(
          hasPhoto: false,
          clearUpload: true,
          errors: state.errors.copyWith(
            photo: 'File size must be under 5 MB.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> pickPhoto({required AppImageSource source}) async {
    if (state.errors.photo != null) {
      emit(state.copyWith(errors: state.errors.copyWith(clearPhoto: true)));
    }

    final granted = await _ensurePermission(source);
    if (!granted) {
      emit(
        state.copyWith(
          errors: state.errors.copyWith(
            photo: source == AppImageSource.camera
                ? 'Camera permission is required'
                : 'Photo library permission is required',
          ),
        ),
      );
      return;
    }


    if (source == AppImageSource.gallery) {
      final file = await _filePickerService.pickImage();
      if (file == null) return;
      if (!_validateFileSize(file.sizeBytes)) return;
      emit(
        state.copyWith(
          hasPhoto: true,
          uploadPath: file.path,
          uploadName: file.name,
          uploadType: VehicleUploadType.image,
          errors: state.errors.copyWith(clearPhoto: true),
        ),
      );
      return;
    } else {
      final picked = await _imagePickerService.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (picked == null) return;
      final sizeBytes = await File(picked.path).length();
      if (!_validateFileSize(sizeBytes)) return;
      emit(
        state.copyWith(
          hasPhoto: true,
          uploadPath: picked.path,
          uploadName: picked.name,
          uploadType: VehicleUploadType.image,
          errors: state.errors.copyWith(clearPhoto: true),
        ),
      );
      return;
    }
  }

  Future<void> pickDocument() async {
    if (state.errors.photo != null) {
      emit(state.copyWith(errors: state.errors.copyWith(clearPhoto: true)));
    }

    final file = await _filePickerService.pickCustom(
      allowedExtensions: const ['pdf', 'doc', 'docx'],
    );
    if (file == null) return;
    if (!_validateFileSize(file.sizeBytes)) return;

    emit(
      state.copyWith(
        hasPhoto: true,
        uploadPath: file.path,
        uploadName: file.name,
        uploadType: VehicleUploadType.document,
        errors: state.errors.copyWith(clearPhoto: true),
      ),
    );
  }

  void removePhoto() {
    emit(
      state.copyWith(
        hasPhoto: false,
        clearUpload: true,
        errors: state.errors.copyWith(clearPhoto: true),
      ),
    );
  }

  Future<bool> _ensurePermission(AppImageSource source) async {
    if (source == AppImageSource.gallery && Platform.isAndroid) {
      return true;
    }

    final AppPermission permission = source == AppImageSource.camera
        ? AppPermission.camera
        : AppPermission.photos;

    final status = await _permissionService.status(permission);
    if (status == AppPermissionStatus.granted) return true;

    final result = await _permissionService.request(permission);
    return result == AppPermissionStatus.granted;
  }

  bool _validate() {
    FieldError err = const FieldError();

    if (state.vehicleType != VehicleType.auto &&
        state.modelName.trim().isEmpty) {
      err = err.copyWith(modelName: 'Model name is required');
    }
    if (state.vehicleType == VehicleType.bike &&
        state.selectedBikeType == null) {
      err = err.copyWith(bikeType: 'Please select a bike type');
    }
    if (state.vehicleType == VehicleType.cab &&
        state.selectedSeatOption == null) {
      err = err.copyWith(seatOption: 'Please select seats');
    }
    if (state.selectedFuelType == null) {
      err = err.copyWith(fuelType: 'Please select a fuel type');
    }
    if (state.year.trim().isEmpty) {
      err = err.copyWith(year: 'Year is required');
    } else {
      final n = int.tryParse(state.year.trim());
      final current = DateTime.now().year;
      if (n == null || n < 1980 || n > current) {
        err = err.copyWith(year: 'Enter a valid year (1980-$current)');
      }
    }
    if (!state.hasPhoto) {
      err = err.copyWith(photo: 'Vehicle photo is required');
    }

    if (err.hasErrors) {
      emit(state.copyWith(errors: err));
      return false;
    }
    return true;
  }

  Future<void> submit() async {
    if (!_validate()) return;

    emit(state.copyWith(isSubmitting: true));

    await Future.delayed(const Duration(seconds: 2));

    emit(
      state.copyWith(
        isSubmitting: false,
        isSubmitted: true,
        successMessage: 'Vehicle "${state.modelName}" registered successfully!',
      ),
    );
  }

  void reset() {
    emit(VehicleDetailsState.initial(vehicleType: state.vehicleType));
  }

  void clearSuccess() {
    emit(state.copyWith(isSubmitted: false, clearSuccess: true));
  }
}
