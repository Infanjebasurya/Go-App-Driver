import 'package:equatable/equatable.dart';

enum ProfileEditStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  error,
  loggedOut,
  deleted,
}

class ProfileEditData extends Equatable {
  const ProfileEditData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
    required this.rating,
    required this.totalTrips,
    required this.totalYears,
  });

  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String dateOfBirth;
  final double rating;
  final int totalTrips;
  final double totalYears;

  ProfileEditData copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? gender,
    String? dateOfBirth,
    double? rating,
    int? totalTrips,
    double? totalYears,
  }) {
    return ProfileEditData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      totalYears: totalYears ?? this.totalYears,
    );
  }

  @override
  List<Object> get props => <Object>[
    fullName,
    email,
    phone,
    gender,
    dateOfBirth,
    rating,
    totalTrips,
    totalYears,
  ];
}

class ProfileEditState extends Equatable {
  const ProfileEditState({
    this.status = ProfileEditStatus.initial,
    this.data,
    this.errorMessage,
  });

  final ProfileEditStatus status;
  final ProfileEditData? data;
  final String? errorMessage;

  ProfileEditState copyWith({
    ProfileEditStatus? status,
    ProfileEditData? data,
    String? errorMessage,
  }) {
    return ProfileEditState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, data, errorMessage];
}
