import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
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

  Profile copyWith({
    String? id,
    String? name,
    String? gender,
    String? refer,
    String? emergencyContact,
    String? email,
    String? phone,
    String? dob,
    double? rating,
    int? totalTrips,
    double? totalYears,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      refer: refer ?? this.refer,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      totalYears: totalYears ?? this.totalYears,
    );
  }


  Map<String, dynamic> toMap() {
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


  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      refer: map['refer'] as String? ?? '',
      emergencyContact: map['emergencyContact'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      dob: map['dob'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: map['totalTrips'] as int? ?? 0,
      totalYears: (map['totalYears'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    gender,
    refer,
    emergencyContact,
    email,
    phone,
    dob,
    rating,
    totalTrips,
    totalYears,
  ];

  @override
  String toString() {
    return 'Profile(id: $id, name: $name, email: $email, gender: $gender, '
        'dob: $dob, phone: $phone, refer: $refer, '
        'emergencyContact: $emergencyContact, rating: $rating, '
        'totalTrips: $totalTrips, totalYears: $totalYears)';
  }
}
