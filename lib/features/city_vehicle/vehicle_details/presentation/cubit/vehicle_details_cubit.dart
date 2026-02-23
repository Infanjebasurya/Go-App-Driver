import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/model/vehicle_details_model.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';

class VehicleDetailsCubit extends Cubit<VehicleDetailsState> {
  VehicleDetailsCubit({required VehicleType vehicleType})
      : super(VehicleDetailsState.initial(vehicleType: vehicleType));

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

  void pickPhoto() {
    emit(state.copyWith(hasPhoto: true));
  }

  void removePhoto() {
    emit(state.copyWith(hasPhoto: false));
  }

  bool _validate() {
    FieldError err = const FieldError();

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
    emit(state.copyWith(clearSuccess: true));
  }
}
