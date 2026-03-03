import 'package:goapp/features/profile/data/models/profile_model.dart';

class UpdateProfileImageRequestModel {
  const UpdateProfileImageRequestModel({
    required this.imagePath,
    this.fileName,
  });

  final String imagePath;
  final String? fileName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'image_path': imagePath,
      if (fileName != null) 'file_name': fileName,
    };
  }
}

class UpdateProfileImageResponseModel {
  const UpdateProfileImageResponseModel({
    this.message,
    this.success,
    this.imageUrl,
    this.status,
  });

  final String? message;
  final bool? success;
  final String? imageUrl;
  final String? status;

  factory UpdateProfileImageResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileImageResponseModel(
      message: json['message']?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
      imageUrl:
          (json['image_url'] ?? json['imageUrl'] ?? json['profile_image_url'])
              ?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (message != null) 'message': message,
      if (success != null) 'success': success,
      if (imageUrl != null) 'image_url': imageUrl,
      if (status != null) 'status': status,
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'success') return true;
      if (normalized == 'false' || normalized == 'failed') return false;
    }
    return null;
  }
}

class UpdateProfileDetailsRequestModel {
  const UpdateProfileDetailsRequestModel({
    this.name,
    this.email,
    this.gender,
    this.dob,
    this.refer,
    this.emergencyContact,
  });

  final String? name;
  final String? email;
  final String? gender;
  final String? dob;
  final String? refer;
  final String? emergencyContact;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (gender != null) 'gender': gender,
      if (dob != null) 'dob': dob,
      if (refer != null) 'refer': refer,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
    };
  }
}

class UpdateProfileDetailsResponseModel {
  const UpdateProfileDetailsResponseModel({
    this.message,
    this.success,
    this.status,
    this.profile,
  });

  final String? message;
  final bool? success;
  final String? status;
  final ProfileModel? profile;

  factory UpdateProfileDetailsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic profileRaw = json['profile'] ?? json['data'];
    return UpdateProfileDetailsResponseModel(
      message: json['message']?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
      status: json['status']?.toString(),
      profile: profileRaw is Map<String, dynamic>
          ? ProfileModel.fromJson(profileRaw)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (message != null) 'message': message,
      if (success != null) 'success': success,
      if (status != null) 'status': status,
      if (profile != null) 'profile': profile!.toJson(),
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'success') return true;
      if (normalized == 'false' || normalized == 'failed') return false;
    }
    return null;
  }
}

