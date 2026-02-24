import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/model/vehicle_details_model.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';

class VehicleDetailsCubit extends Cubit<VehicleDetailsState> {
  VehicleDetailsCubit({required VehicleType vehicleType})
      : super(VehicleDetailsState.initial(vehicleType: vehicleType));

  final ImagePicker _picker = ImagePicker();

  void updateModelName(String value) {
    final err = state.errors.copyWith(
      clearModel: value.trim().isNotEmpty,
    );
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
    final err = state.errors.copyWith(clearYear: true);
    emit(state.copyWith(year: value, errors: err));
  }

  Future<void> pickPhoto({required ImageSource source}) async {
    if (state.errors.photo != null) {
      emit(state.copyWith(errors: state.errors.copyWith(clearPhoto: true)));
    }

    final granted = await _ensurePermission(source);
    if (!granted) {
      emit(
        state.copyWith(
          errors: state.errors.copyWith(
            photo: source == ImageSource.camera
                ? 'Camera permission is required'
                : 'Photo library permission is required',
          ),
        ),
      );
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 100,
    );
    if (picked == null) return;

    final sizeBytes = await _readFileSize(picked);
    const maxBytes = 5 * 1024 * 1024;
    if (sizeBytes <= 0 || sizeBytes > maxBytes) {
      emit(
        state.copyWith(
          hasPhoto: false,
          errors: state.errors.copyWith(
            photo:
                'Image size should not exceed 5MB. Please choose a smaller image.',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        hasPhoto: true,
        errors: state.errors.copyWith(clearPhoto: true),
      ),
    );
  }

  void removePhoto() {
    emit(
      state.copyWith(
        hasPhoto: false,
        errors: state.errors.copyWith(clearPhoto: true),
      ),
    );
  }

  Future<bool> _ensurePermission(ImageSource source) async {
    if (source == ImageSource.gallery && Platform.isAndroid) {
      // Android system picker doesn't require explicit storage permission.
      return true;
    }

    final Permission permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final status = await permission.status;
    if (status.isGranted) return true;

    final result = await permission.request();
    return result.isGranted;
  }

  Future<int> _readFileSize(XFile file) async {
    try {
      final len = await file.length();
      if (len > 0) return len;
    } catch (_) {}
    try {
      final stat = await File(file.path).stat();
      return stat.size;
    } catch (_) {
      return 0;
    }
  }

  bool _validate() {
    FieldError err = const FieldError();

    if (!state.hasPhoto) {
      err = err.copyWith(
        photo:
            'Vehicle photo is required. Please upload a photo under 5MB.',
      );
    }
    if (state.vehicleType != VehicleType.auto && state.modelName.trim().isEmpty) {
      err = err.copyWith(modelName: 'Model name is required');
    }
    if (state.vehicleType == VehicleType.bike && state.selectedBikeType == null) {
      err = err.copyWith(bikeType: 'Please select a bike type');
    }
    if (state.vehicleType == VehicleType.cab && state.selectedSeatOption == null) {
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
    emit(
      state.copyWith(
        isSubmitted: false,
        clearSuccess: true,
      ),
    );
  }
}
