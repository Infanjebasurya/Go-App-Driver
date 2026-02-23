import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';

class VehicleSelectionCubit extends Cubit<VehicleSelectionState> {
  VehicleSelectionCubit() : super(VehicleSelectionState.initial());

  void selectVehicle(Vehicle vehicle) {
    if (state.isSelected(vehicle)) {
      emit(state.copyWith(clearSelection: true));
    } else {
      emit(state.copyWith(selectedVehicle: vehicle));
    }
  }

  void reset() {
    emit(VehicleSelectionState.initial());
  }
}
