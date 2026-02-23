import 'package:equatable/equatable.dart';

class CaptainProfile extends Equatable {
  const CaptainProfile({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.isOnline,
  });

  final String id;
  final String name;
  final String vehicleType;
  final bool isOnline;

  @override
  List<Object?> get props => <Object?>[id, name, vehicleType, isOnline];
}
