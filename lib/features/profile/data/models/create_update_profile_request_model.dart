class CreateUpdateProfileRequestModel {
  const CreateUpdateProfileRequestModel({
    required this.name,
    required this.gender,
    required this.refer,
    required this.emergencyContact,
    this.email,
    this.phone,
    this.dob,
    this.profileImageUrl,
  });

  final String name;
  final String gender;
  final String refer;
  final String emergencyContact;
  final String? email;
  final String? phone;
  final String? dob;
  final String? profileImageUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'gender': gender,
      'refer': refer,
      'emergency_contact': emergencyContact,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dob != null) 'dob': dob,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
    };
  }
}
