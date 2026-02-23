import 'package:equatable/equatable.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';

enum FuelType { petrol, electric }

enum BikeType { bike, scooter }

enum SeatOption { four, six, eight }

extension FuelTypeExt on FuelType {
  String get label {
    switch (this) {
      case FuelType.petrol:
        return 'Petrol';
      case FuelType.electric:
        return 'Electric';
    }
  }
}

extension BikeTypeExt on BikeType {
  String get label {
    switch (this) {
      case BikeType.bike:
        return 'Bike';
      case BikeType.scooter:
        return 'Scooter';
    }
  }
}

extension SeatOptionExt on SeatOption {
  String get label {
    switch (this) {
      case SeatOption.four:
        return '4 Seater';
      case SeatOption.six:
        return '6 Seater';
      case SeatOption.eight:
        return '8 Seater';
    }
  }
}

class FieldError {
  final String? modelName;
  final String? bikeType;
  final String? seatOption;
  final String? fuelType;
  final String? year;
  final String? photo;

  const FieldError({
    this.modelName,
    this.bikeType,
    this.seatOption,
    this.fuelType,
    this.year,
    this.photo,
  });

  bool get hasErrors =>
      modelName != null ||
      bikeType != null ||
      seatOption != null ||
      fuelType != null ||
      year != null ||
      photo != null;

  FieldError copyWith({
    String? modelName,
    String? bikeType,
    String? seatOption,
    String? fuelType,
    String? year,
    String? photo,
    bool clearModel = false,
    bool clearBikeType = false,
    bool clearSeatOption = false,
    bool clearFuelType = false,
    bool clearYear = false,
    bool clearPhoto = false,
  }) {
    return FieldError(
      modelName: clearModel ? null : (modelName ?? this.modelName),
      bikeType: clearBikeType ? null : (bikeType ?? this.bikeType),
      seatOption: clearSeatOption ? null : (seatOption ?? this.seatOption),
      fuelType: clearFuelType ? null : (fuelType ?? this.fuelType),
      year: clearYear ? null : (year ?? this.year),
      photo: clearPhoto ? null : (photo ?? this.photo),
    );
  }
}

class VehicleDetailsState extends Equatable {
  final VehicleType vehicleType;
  final String modelName;
  final BikeType? selectedBikeType;
  final SeatOption? selectedSeatOption;
  final FuelType? selectedFuelType;
  final String year;
  final bool hasPhoto;
  final bool isSubmitting;
  final bool isSubmitted;
  final FieldError errors;
  final String? successMessage;

  const VehicleDetailsState({
    required this.vehicleType,
    this.modelName = '',
    this.selectedBikeType,
    this.selectedSeatOption,
    this.selectedFuelType,
    this.year = '',
    this.hasPhoto = false,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errors = const FieldError(),
    this.successMessage,
  });

  factory VehicleDetailsState.initial({required VehicleType vehicleType}) =>
      VehicleDetailsState(vehicleType: vehicleType);

  bool get isFormValid =>
      (vehicleType == VehicleType.auto || modelName.trim().isNotEmpty) &&
      (vehicleType != VehicleType.bike || selectedBikeType != null) &&
      (vehicleType != VehicleType.cab || selectedSeatOption != null) &&
      selectedFuelType != null &&
      year.trim().isNotEmpty &&
      _isValidYear(year.trim());

  static bool _isValidYear(String y) {
    final n = int.tryParse(y);
    if (n == null) return false;
    final current = DateTime.now().year;
    return n >= 1980 && n <= current;
  }

  String get bikeTypeDisplay => selectedBikeType?.label ?? '';

  String get seatDisplay => selectedSeatOption?.label ?? '';

  String get fuelTypeDisplay => selectedFuelType?.label ?? '';

  VehicleDetailsState copyWith({
    VehicleType? vehicleType,
    String? modelName,
    BikeType? selectedBikeType,
    SeatOption? selectedSeatOption,
    FuelType? selectedFuelType,
    String? year,
    bool? hasPhoto,
    bool? isSubmitting,
    bool? isSubmitted,
    FieldError? errors,
    String? successMessage,
    bool clearBikeType = false,
    bool clearSeatOption = false,
    bool clearFuelType = false,
    bool clearSuccess = false,
  }) {
    return VehicleDetailsState(
      vehicleType: vehicleType ?? this.vehicleType,
      modelName: modelName ?? this.modelName,
      selectedBikeType:
          clearBikeType ? null : (selectedBikeType ?? this.selectedBikeType),
      selectedSeatOption:
          clearSeatOption ? null : (selectedSeatOption ?? this.selectedSeatOption),
      selectedFuelType:
          clearFuelType ? null : (selectedFuelType ?? this.selectedFuelType),
      year: year ?? this.year,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errors: errors ?? this.errors,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        vehicleType,
        modelName,
        selectedBikeType,
        selectedSeatOption,
        selectedFuelType,
        year,
        hasPhoto,
        isSubmitting,
        isSubmitted,
        errors.modelName,
        errors.bikeType,
        errors.seatOption,
        errors.fuelType,
        errors.year,
        errors.photo,
        successMessage,
      ];
}
