class LocalUserCacheModel {
  const LocalUserCacheModel({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.referCode,
    required this.emergencyContact,
    this.email,
    this.phone,
    this.dob,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.totalYears = 0.0,
  });

  final String id;
  final String fullName;
  final String gender;
  final String referCode;
  final String emergencyContact;
  final String? email;
  final String? phone;
  final String? dob;
  final double rating;
  final int totalTrips;
  final double totalYears;

  LocalUserCacheModel copyWith({
    String? id,
    String? fullName,
    String? gender,
    String? referCode,
    String? emergencyContact,
    String? email,
    String? phone,
    String? dob,
    double? rating,
    int? totalTrips,
    double? totalYears,
  }) {
    return LocalUserCacheModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      referCode: referCode ?? this.referCode,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      totalYears: totalYears ?? this.totalYears,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'gender': gender,
      'referCode': referCode,
      'emergencyContact': emergencyContact,
      'email': email,
      'phone': phone,
      'dob': dob,
      'rating': rating,
      'totalTrips': totalTrips,
      'totalYears': totalYears,
    };
  }

  Map<String, dynamic> toPostJson() => toJson();

  Map<String, dynamic> toPutJson() => toJson();

  factory LocalUserCacheModel.fromJson(Map<String, dynamic> map) {
    return LocalUserCacheModel(
      id: map['id'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      referCode: map['referCode'] as String? ?? '',
      emergencyContact: map['emergencyContact'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      dob: map['dob'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: map['totalTrips'] as int? ?? 0,
      totalYears: (map['totalYears'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory LocalUserCacheModel.fromApi(Map<String, dynamic> map) {
    return LocalUserCacheModel.fromJson(map);
  }
}
