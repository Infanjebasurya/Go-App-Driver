import 'package:goapp/features/profile/domain/entities/profile.dart';

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.refer,
    required this.emergencyContact,
    this.email,
    this.phone,
    this.dob,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.totalYears = 0.0,
  });

  final String id;
  final String name;
  final String gender;
  final String refer;
  final String emergencyContact;
  final String? email;
  final String? phone;
  final String? dob;
  final double rating;
  final int totalTrips;
  final double totalYears;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      refer: (json['refer'] ?? json['referCode'] ?? '').toString(),
      emergencyContact:
          (json['emergencyContact'] ?? json['emergency_contact'] ?? '')
              .toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      dob: json['dob']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      totalYears: (json['totalYears'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory ProfileModel.fromEntity(Profile entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      gender: entity.gender,
      refer: entity.refer,
      emergencyContact: entity.emergencyContact,
      email: entity.email,
      phone: entity.phone,
      dob: entity.dob,
      rating: entity.rating,
      totalTrips: entity.totalTrips,
      totalYears: entity.totalYears,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'gender': gender,
      'refer': refer,
      'emergencyContact': emergencyContact,
      'email': email,
      'phone': phone,
      'dob': dob,
      'rating': rating,
      'totalTrips': totalTrips,
      'totalYears': totalYears,
    };
  }

  Profile toEntity() {
    return Profile(
      id: id,
      name: name,
      gender: gender,
      refer: refer,
      emergencyContact: emergencyContact,
      email: email,
      phone: phone,
      dob: dob,
      rating: rating,
      totalTrips: totalTrips,
      totalYears: totalYears,
    );
  }
}
