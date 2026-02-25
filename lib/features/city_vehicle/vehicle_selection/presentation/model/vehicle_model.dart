import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum VehicleType { bike, auto, cab }

class Vehicle extends Equatable {
  final VehicleType type;
  final String label;
  final String tier;
  final String seatsDescription;
  final IconData icon;

  const Vehicle({
    required this.type,
    required this.label,
    required this.tier,
    required this.seatsDescription,
    required this.icon,
  });

  String get subtitle => '$tier • $seatsDescription';

  @override
  List<Object?> get props => [type, label, tier, seatsDescription];
}

const List<Vehicle> kVehicles = [
  Vehicle(
    type: VehicleType.bike,
    label: 'Bike',
    tier: 'ELITE TIER',
    seatsDescription: '1 SEATS',
    icon: Icons.two_wheeler_rounded,
  ),
  Vehicle(
    type: VehicleType.auto,
    label: 'Auto',
    tier: 'ELITE TIER',
    seatsDescription: '3 SEATS',
    icon: Icons.electric_rickshaw_rounded,
  ),
  Vehicle(
    type: VehicleType.cab,
    label: 'Cab',
    tier: 'ELITE TIER',
    seatsDescription: '4 TO 8 SEATS',
    icon: Icons.local_taxi_rounded,
  ),
];

class VehicleSelectionState extends Equatable {
  final Vehicle? selectedVehicle;

  const VehicleSelectionState({this.selectedVehicle});

  factory VehicleSelectionState.initial() =>
      const VehicleSelectionState(selectedVehicle: null);

  bool get hasSelection => selectedVehicle != null;

  bool isSelected(Vehicle v) => selectedVehicle?.type == v.type;

  VehicleSelectionState copyWith({
    Vehicle? selectedVehicle,
    bool clearSelection = false,
  }) {
    return VehicleSelectionState(
      selectedVehicle: clearSelection
          ? null
          : (selectedVehicle ?? this.selectedVehicle),
    );
  }

  @override
  List<Object?> get props => [selectedVehicle];
}
